# GlobalEdge HA Web

Terraform configuration for Task 1 of Cloud Programming (DLBSEPCP01_E). It builds the Phase 1 design in `eu-central-1`: Route 53 (optional), CloudFront, an Internet Gateway, a two AZ VPC, an Application Load Balancer, private Nginx instances, and an Auto Scaling Group.

## Architecture

- VPC `10.0.0.0/16` with DNS support and hostnames.
- Public subnets `10.0.1.0/24` and `10.0.2.0/24`, one in each Availability Zone, routed through an Internet Gateway.
- Private subnets `10.0.11.0/24` and `10.0.12.0/24`. Each has its own NAT Gateway so outbound patching survives the loss of one AZ.
- Gateway VPC endpoint `com.amazonaws.eu-central-1.s3` on the private route tables.
- SG-ALB accepts TCP 80 only from the CloudFront origin facing prefix list.
- SG-Web accepts TCP 80 only from SG-ALB.
- Internet facing ALB in the public subnets, target group health check on `/`.
- Auto Scaling Group in the private subnets (`min` 2, `desired` 2, `max` 6) with target tracking at 50 percent average CPU.
- CloudFront in front of the ALB. Viewers are redirected to HTTPS. The origin connection is HTTP so the stack works before a paid domain and certificate exist.
- Private S3 bucket with AES256 encryption and all public access blocks enabled.
- Route 53 alias record is created only when `domain_name` is not empty.

## Prerequisites

- Terraform 1.5.0 or newer.
- AWS credentials with permission to create VPC, EC2, ELB, Auto Scaling, CloudFront, S3, and (only if you set a domain) Route 53 resources.
- The AWS CLI is useful for checking the account, but Terraform talks to AWS directly.

```bash
aws sts get-caller-identity
```

## Cost note

Two NAT Gateways and an Application Load Balancer are billed per hour. They are not covered by the usual free tier in a way I can rely on for a long test. Run `terraform destroy` when you are finished so the hourly resources do not keep running.

## Commands

From this directory:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform destroy
```

`terraform validate` checks the configuration without creating resources. `terraform plan` shows the create actions. `terraform apply` builds them. `terraform destroy` removes them.

## Optional domain

Leave the default `domain_name` empty if you do not have a hosted zone. To add the alias record, pass the hosted zone name:

```bash
terraform plan -var 'domain_name=example.com'
```

The value must match an existing public hosted zone in this account. The record is an A alias to the CloudFront distribution.

## Files

| File | Role |
| --- | --- |
| versions.tf | Terraform and provider version constraints |
| providers.tf | AWS provider for eu-central-1 and the us-east-1 alias |
| variables.tf | Inputs and the Auto Scaling size check |
| vpc.tf | VPC, subnets, gateways, routes, S3 endpoint |
| security.tf | SG-ALB and SG-Web |
| alb.tf | Load balancer, target group, listener |
| compute.tf | AMI, launch template, Auto Scaling Group, CPU policy |
| edge.tf | S3, CloudFront, conditional Route 53 record |
| outputs.tf | CloudFront domain, ALB DNS name, VPC id, bucket name |

State is stored locally in `terraform.tfstate`. Do not commit that file. The S3 bucket in `edge.tf` is for shared assets. It is not the Terraform remote backend, because the bucket does not exist until the first apply.
