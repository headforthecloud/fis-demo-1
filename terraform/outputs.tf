output "cloudfront_url" {
  description = "URL for the CloudFront distribution"
  value = "https://${aws_cloudfront_distribution.cf_dist.domain_name}"
}