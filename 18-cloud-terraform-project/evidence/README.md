# Session 19 Evidence

This evidence was captured from an authorized live AWS deployment in `ap-southeast-2` on 7 October 2026. Terraform applied all 11 planned resources, the Nginx endpoint returned the expected Session 19 page, and Terraform destroyed all 11 resources after capture. The sanitized [complete Terraform transcript](aws-session19-live.txt) contains `init`, validation, saved plan, apply, state, outputs, HTTP verification, destroy plan and successful cleanup.

## EC2 instance

The live `t3.micro` instance passed all three EC2 status checks. The terminated row is the automatically cleaned first readiness attempt and incurred no further compute time.

![Running Session 19 EC2 instance](01-ec2-running.png)

## Live application

![Nginx page served by the Terraform EC2 instance](02-live-web-page.png)

## Artifact bucket

![Session 19 S3 artifact bucket in Sydney](03-s3-artifact-bucket.png)

## VPC architecture

The live resource map proves the public subnet, route table and Internet Gateway connection in the custom VPC.

![VPC resource map with subnet routing and Internet Gateway](04-vpc-resource-map.png)

## Network security

The security group exposes only the assignment-required HTTP port; SSH is not opened.

![Security group allowing TCP port 80](05-security-group-http.png)
