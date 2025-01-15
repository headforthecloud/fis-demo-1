resource "aws_fis_experiment_template" "this" {

  tags = {
    Name = "${var.resource_prefix}_template"
  }

  description = "Demo experiment to test resilience of Auto Scaling Group"

  role_arn = aws_iam_role.fis_role.arn

  stop_condition {
    source = "none"
  }

  log_configuration {
    log_schema_version = 2
    cloudwatch_logs_configuration {
      log_group_arn = "${aws_cloudwatch_log_group.this.arn}:*"
    }
  }

  experiment_options {
    account_targeting            = "single-account"
    empty_target_resolution_mode = "fail"
  }

  target {
    name           = "all_asg_instances"
    resource_type  = "aws:ec2:instance"
    selection_mode = "ALL"

    resource_tag {
      key   = "Project"
      value = var.resource_prefix
    }
  }

  action {
    name        = "CPU_stress_test_for_EC2"
    description = "Use ssm CPU stress document to increase load on all cpus to 50%"
    action_id   = "aws:ssm:send-command"

    parameter {
      key   = "documentArn"
      value = "arn:aws:ssm:${var.region}::document/AWSFIS-Run-CPU-Stress"
    }

    parameter {
      key = "documentParameters"
      value = jsonencode(
        {
          DurationSeconds = "480"
          LoadPercent     = "50"
        }
      )
    }

    parameter {
      key   = "duration"
      value = "PT15M"
    }

    target {
      key   = "Instances"
      value = "all_asg_instances"
    }
  }

  target {
    name           = "ec2_2_azs"
    resource_type  = "aws:ec2:instance"
    selection_mode = "ALL"

    resource_tag {
      key   = "Project"
      value = var.resource_prefix
    }

    filter {
      path = "Placement.AvailabilityZone"
      values = [
        "${var.region}a",
        "${var.region}b",
      ]
    }
  }

  action {
    name        = "Kill_two_AZs"
    description = "Kill ec2 instances in asg in two AZs"
    action_id   = "aws:ec2:terminate-instances"

    target {
      key   = "Instances"
      value = "ec2_2_azs"
    }

    start_after = [
      "CPU_stress_test_for_EC2"
    ]
  }

}