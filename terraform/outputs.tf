output "cloudfront_url" {
  description = "URL for the CloudFront distribution"
  value = "https://${aws_cloudfront_distribution.cf_dist.domain_name}"
}

output "lb_url" {
  description = "value of the load balancer URL"
  value = "http://${aws_elb.this.dns_name}"
}