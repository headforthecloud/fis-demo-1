resource "aws_cloudwatch_log_group" "this" {
  name              = "/var/fis/${var.resource_prefix}"
  retention_in_days = 1
}
