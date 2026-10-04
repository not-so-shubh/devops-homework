#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_DIR="$ROOT_DIR/19-monitoring-observability-gitops"
PROJECT="session20-evidence"
TRACE_ID="0123456789abcdef0123456789abcdef"
SPAN_ID="0123456789abcdef"

section() { printf '\n===== %s =====\n' "$1"; }
cleanup() { docker compose -p "$PROJECT" -f "$STACK_DIR/docker-compose.yml" down -v >/dev/null 2>&1 || true; }
trap cleanup EXIT

cleanup
section "OBSERVABILITY STACK START"
docker compose -p "$PROJECT" -f "$STACK_DIR/docker-compose.yml" up -d
for endpoint in \
  http://127.0.0.1:9090/-/ready \
  http://127.0.0.1:9093/-/ready \
  http://127.0.0.1:3001/api/health \
  http://127.0.0.1:3100/ready \
  http://127.0.0.1:3200/ready; do
  curl -fsS --retry 40 --retry-all-errors --retry-delay 2 "$endpoint" >/dev/null
  echo "HTTP 200: $endpoint"
done
docker compose -p "$PROJECT" -f "$STACK_DIR/docker-compose.yml" ps

section "PROMETHEUS TARGETS AND RULES"
curl -fsS http://127.0.0.1:9090/api/v1/targets | jq -r '.data.activeTargets[] | [.labels.job,.health,.scrapeUrl] | @tsv'
curl -fsS http://127.0.0.1:9090/api/v1/rules | jq -r '.data.groups[] | .name as $g | .rules[] | [$g,.name,.type,.state] | @tsv'

section "OTLP METRIC AND FIRING ALERT"
NOW_NS="$(python3 -c 'import time; print(time.time_ns())')"
curl -fsS -X POST http://127.0.0.1:4318/v1/metrics -H 'Content-Type: application/json' --data-binary @- <<JSON
{"resourceMetrics":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"devops-homework-demo"}}]},"scopeMetrics":[{"scope":{"name":"assignment-evidence"},"metrics":[{"name":"devops_homework_demo_health","description":"Synthetic assignment health signal","gauge":{"dataPoints":[{"attributes":[{"key":"environment","value":{"stringValue":"evidence"}}],"timeUnixNano":"$NOW_NS","asDouble":0}]}}]}]}]}
JSON
echo
for _ in $(seq 1 20); do
  VALUE="$(curl -fsS -G http://127.0.0.1:9090/api/v1/query --data-urlencode 'query=devops_homework_demo_health' | jq -r '.data.result[0].value[1] // empty')"
  [[ -n "$VALUE" ]] && break
  sleep 3
done
echo "Prometheus metric devops_homework_demo_health=$VALUE"
[[ "$VALUE" == "0" ]] || { echo "Metric was not scraped by Prometheus" >&2; exit 1; }
for _ in $(seq 1 20); do
  ALERT_STATE="$(curl -fsS http://127.0.0.1:9090/api/v1/alerts | jq -r '.data.alerts[]? | select(.labels.alertname=="HomeworkApplicationUnhealthy") | .state' | head -1)"
  [[ "$ALERT_STATE" == "firing" ]] && break
  sleep 3
done
echo "Prometheus alert HomeworkApplicationUnhealthy=$ALERT_STATE"
[[ "$ALERT_STATE" == "firing" ]] || { echo "Alert did not enter firing state" >&2; exit 1; }
ALERTMANAGER_RESULT="$(curl -fsS http://127.0.0.1:9093/api/v2/alerts | jq -r '.[] | select(.labels.alertname=="HomeworkApplicationUnhealthy") | [.labels.alertname,.status.state,.annotations.summary] | @tsv' | head -1)"
echo "$ALERTMANAGER_RESULT"
[[ -n "$ALERTMANAGER_RESULT" ]] || { echo "Alertmanager did not receive the alert" >&2; exit 1; }

section "LOKI LOG QUERY"
curl -fsS http://127.0.0.1:3100/loki/api/v1/labels | jq -r '.data[]'
END_NS="$(python3 -c 'import time; print(time.time_ns())')"
START_NS="$((END_NS - 600000000000))"
LOG_RESULT="$(curl -fsS -G http://127.0.0.1:3100/loki/api/v1/query_range \
  --data-urlencode 'query={container=~".+"}' \
  --data-urlencode "start=$START_NS" --data-urlencode "end=$END_NS" --data-urlencode 'limit=5' \
  | jq -r '.data.result[]? | .stream.container as $name | .values[] | [$name,.[1]] | @tsv' | head -8)"
echo "$LOG_RESULT"
[[ -n "$LOG_RESULT" ]] || { echo "Loki returned no Docker logs" >&2; exit 1; }

section "TEMPO TRACE QUERY"
START_TRACE_NS="$(python3 -c 'import time; print(time.time_ns())')"
END_TRACE_NS="$((START_TRACE_NS + 250000000))"
curl -fsS -X POST http://127.0.0.1:4318/v1/traces -H 'Content-Type: application/json' --data-binary @- <<JSON
{"resourceSpans":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"devops-homework-demo"}}]},"scopeSpans":[{"scope":{"name":"assignment-evidence"},"spans":[{"traceId":"$TRACE_ID","spanId":"$SPAN_ID","name":"assignment-evidence-request","kind":2,"startTimeUnixNano":"$START_TRACE_NS","endTimeUnixNano":"$END_TRACE_NS","status":{"code":1}}]}]}]}
JSON
echo
for _ in $(seq 1 20); do
  TRACE_NAME="$(curl -fsS "http://127.0.0.1:3200/api/traces/$TRACE_ID" 2>/dev/null | jq -r '.batches[0].scopeSpans[0].spans[0].name // empty' 2>/dev/null || true)"
  [[ -n "$TRACE_NAME" ]] && break
  sleep 2
done
echo "Tempo trace $TRACE_ID: $TRACE_NAME"
[[ "$TRACE_NAME" == "assignment-evidence-request" ]] || { echo "Tempo did not return the submitted trace" >&2; exit 1; }

section "GRAFANA DATASOURCES AND DASHBOARD"
curl -fsS -u admin:devops-lab-change-me http://127.0.0.1:3001/api/datasources | jq -r '.[] | [.name,.type,.url] | @tsv'
curl -fsS -u admin:devops-lab-change-me -G http://127.0.0.1:3001/api/search --data-urlencode 'query=DevOps Homework Observability' | jq -r '.[] | [.title,.uid,.url] | @tsv'
echo "PASS: metrics, alert delivery, logs, trace retrieval and dashboard provisioning were verified."

section "STACK CLEANUP"
cleanup
trap - EXIT
echo "PASS: the disposable Compose stack and named volumes were removed."
