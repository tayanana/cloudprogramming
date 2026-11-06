output "cloudfront_domain_name" {
  description = "Public CloudFront domain that viewers should open."
  value       = aws_cloudfront_distribution.web.domain_name
}

output "alb_dns_name" {
  description = "DNS name of the origin load balancer. Direct access is limited to CloudFront by SG-ALB."
  value       = aws_lb.web.dns_name
}

output "vpc_id" {
  description = "ID of the custom VPC."
  value       = aws_vpc.main.id
}

output "s3_bucket_name" {
  description = "Private encrypted bucket for shared assets."
  value       = aws_s3_bucket.assets.bucket
}
