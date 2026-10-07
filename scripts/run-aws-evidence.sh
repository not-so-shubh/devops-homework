#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: CONFIRM_AWS_CHARGES=yes ./scripts/run-aws-evidence.sh session18|session19|final

Runs one Terraform project through init, validate, plan, apply, outputs, a destroy
plan and destroy. The script refuses to touch a directory with existing local
state and always attempts cleanup if apply starts. Session 19 creates EC2 and a
public IPv4 address; the final project creates ECR/S3/VPC resources and keeps EKS
disabled according to terraform.tfvars.

Set OUTPUT_FILE to select the transcript path. The default is a temporary file.
Review/redact account IDs and resource identifiers before publishing evidence.
Set PAUSE_FOR_SCREENSHOTS=yes to pause after apply and outputs so AWS console
screenshots can be captured before the guarded destroy.
USAGE
}

TARGET="${1:-}"
case "$TARGET" in
  session18) PROJECT="17-terraform-aws/terraform-s3-demo" ;;
  session19) PROJECT="18-cloud-terraform-project" ;;
  final) PROJECT="20-final-devops-project/final-devops-project/terraform" ;;
  *) usage >&2; exit 2 ;;
esac

if [[ "${CONFIRM_AWS_CHARGES:-}" != "yes" ]]; then
  echo "Refusing to create billable AWS resources without CONFIRM_AWS_CHARGES=yes." >&2
  exit 2
fi

for command_name in aws terraform; do
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "Required command is missing: $command_name" >&2
    exit 1
  }
done

if [[ -e "$PROJECT/terraform.tfstate" || -e "$PROJECT/terraform.tfstate.backup" ]]; then
  if [[ -n "$(terraform -chdir="$PROJECT" state list 2>/dev/null)" ]]; then
    echo "Refusing to use $PROJECT because existing managed resources were found in local state." >&2
    exit 1
  fi
  echo "Existing local state is empty; continuing safely."
fi

AWS_ACCOUNT="$(aws sts get-caller-identity --query Account --output text)"
[[ "$AWS_ACCOUNT" =~ ^[0-9]{12}$ ]] || {
  echo "AWS identity validation failed." >&2
  exit 1
}

OUTPUT_FILE="${OUTPUT_FILE:-/tmp/devops-homework-${TARGET}-aws-evidence.txt}"
PLAN_FILE="$(mktemp -t "devops-${TARGET}-plan.XXXXXX")"
DESTROY_PLAN_FILE="$(mktemp -t "devops-${TARGET}-destroy.XXXXXX")"
cleanup_needed=false
LIVE_TAIL_PID=""

cleanup() {
  status=$?
  if [[ "$cleanup_needed" == true ]]; then
    echo
    echo "Attempting guarded Terraform cleanup after an interrupted or failed run..."
    terraform -chdir="$PROJECT" destroy -auto-approve || true
  fi
  rm -f "$PLAN_FILE" "$DESTROY_PLAN_FILE"
  if [[ -n "$LIVE_TAIL_PID" ]]; then
    kill "$LIVE_TAIL_PID" 2>/dev/null || true
    wait "$LIVE_TAIL_PID" 2>/dev/null || true
  fi
  trap - EXIT
  exit "$status"
}
trap cleanup EXIT

: > "$OUTPUT_FILE"
exec 3>&1
tail -n 0 -f "$OUTPUT_FILE" >&3 &
LIVE_TAIL_PID=$!
exec > "$OUTPUT_FILE" 2>&1
echo "AWS identity verified for an authorized 12-digit account (identifier withheld)."
echo "Project: $PROJECT"
echo "Transcript: $OUTPUT_FILE"

terraform -chdir="$PROJECT" init -input=false
terraform -chdir="$PROJECT" fmt -check
terraform -chdir="$PROJECT" validate
terraform -chdir="$PROJECT" plan -input=false -out="$PLAN_FILE"
terraform -chdir="$PROJECT" show -no-color "$PLAN_FILE"

cleanup_needed=true
terraform -chdir="$PROJECT" apply -input=false "$PLAN_FILE"
terraform -chdir="$PROJECT" state list
terraform -chdir="$PROJECT" output

if [[ "$TARGET" == "session19" ]]; then
  echo
  echo "Checking the live Session 19 web server..."
  curl --fail --retry 30 --retry-delay 5 --retry-connrefused \
    --connect-timeout 5 --max-time 10 \
    "$(terraform -chdir="$PROJECT" output -raw application_url)"
  echo
fi

if [[ "${PAUSE_FOR_SCREENSHOTS:-}" == "yes" ]]; then
  echo
  echo "Resources are live. Capture the required AWS console screenshots now."
  echo "Do not close this terminal; cleanup will continue after Enter is pressed."
  read -r -p "Press Enter to create and apply the destroy plan... " _
fi

terraform -chdir="$PROJECT" plan -destroy -input=false -out="$DESTROY_PLAN_FILE"
terraform -chdir="$PROJECT" show -no-color "$DESTROY_PLAN_FILE"
terraform -chdir="$PROJECT" apply -input=false "$DESTROY_PLAN_FILE"
cleanup_needed=false

echo "PASS: Terraform apply, output and destroy completed for $TARGET."
echo "Review and redact the transcript before copying it into the repository."
