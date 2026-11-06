variable "project_name" {
  description = "Short name used in resource names and tags."
  type        = string
  default     = "globaledge-ha-web"
}

variable "aws_region" {
  description = "AWS region for the VPC, load balancer, and compute resources."
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per Availability Zone, in the same order as the private list."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per Availability Zone, in the same order as the public list."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Provide exactly two private subnet CIDRs."
  }
}

variable "instance_type" {
  description = "EC2 instance type used by the launch template."
  type        = string
  default     = "t3.micro"
}

variable "asg_min" {
  description = "Minimum number of Nginx instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "asg_desired" {
  description = "Desired number of Nginx instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "asg_max" {
  description = "Maximum number of Nginx instances in the Auto Scaling Group."
  type        = number
  default     = 6
}

variable "domain_name" {
  description = "Optional Route 53 hosted zone name. Leave empty to skip the alias record."
  type        = string
  default     = ""
}

check "asg_capacity_order" {
  assert {
    condition     = var.asg_min <= var.asg_desired && var.asg_desired <= var.asg_max
    error_message = "Auto Scaling capacity must satisfy min <= desired <= max."
  }
}
