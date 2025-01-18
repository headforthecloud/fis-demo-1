output "cloudfront_url" {
  description = "URL for the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.cf_dist.domain_name}"
}

output "lb_url" {
  description = "value of the load balancer URL"
  value       = "http://${aws_elb.this.dns_name}"
}

output "template_url" {
  description = "Console access URL for the FIS template"
  value       = "https://${var.region}.console.aws.amazon.com/fis/home?region=${var.region}#ExperimentTemplateDetails:ExperimentTemplateId=${aws_fis_experiment_template.this.id}"
}