resource "aws_security_group" "ec2_sg" {
  name        = "${var.resource_prefix}_ec2_sg"
  description = "Security Group for EC2 instances"
  vpc_id      = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "ec2_allow_http_in" {
  security_group_id = aws_security_group.ec2_sg.id

  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.elb_sg.id
  description                  = "Allowing HTTP traffic from ELB"
}

resource "aws_vpc_security_group_egress_rule" "ec2_allow_https_out" {
  security_group_id = aws_security_group.ec2_sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
  description = "Allow outgoing HTTPS traffic to anywhere"
}

resource "aws_launch_template" "this" {
  name          = "${var.resource_prefix}_lt"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.nano"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  user_data = base64encode(local.cloud_config)

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Project = "${var.resource_prefix}"
      Name    = "${var.resource_prefix}_ec2"
    }
  }

  depends_on = [aws_security_group.ec2_sg]
}

resource "aws_autoscaling_group" "this" {
  name = "${var.resource_prefix}_asg"

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  vpc_zone_identifier = aws_subnet.public.*.id

  min_size         = 3
  max_size         = 9
  desired_capacity = 3

  load_balancers = [aws_elb.this.id]

  health_check_type         = "ELB"
  health_check_grace_period = 50

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances"
  ]
}

locals {
  cloud_config = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/run/myserver/template.html"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/ec2_files/template.html")
    },
    {
      path        = "/run/myserver/healthcheck.html"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/ec2_files/healthcheck.html")
    }
  ],
  runcmd = [
    "yum update -y",
    "yum install -y httpd",
    "systemctl stop httpd",
    "export ec2_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)",
    "export ec2_name=$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/Name)",
    "export ec2_az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)",
    "envsubst < /run/myserver/template.html > /var/www/html/index.html",
    "envsubst < /run/myserver/healthcheck.html > /var/www/html/healthcheck.html",
    "sleep 60",
    "systemctl start httpd",
    "systemctl enable httpd",
  ],
})}
  END
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "asg_cpu_upscaling_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 30
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name        = "asg_scale_up_alarm"
  alarm_description = "Scale up ASG when CPU exceeds threshold"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]

  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.this.name }
  statistic           = "Average"
  period              = "30"
  evaluation_periods  = 2
  threshold           = 40
  comparison_operator = "GreaterThanOrEqualToThreshold"
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asg_cpu_downscaling_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 30
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name        = "asg_scale_down_alarm"
  alarm_description = "Scale down ASG when CPU drops below threshold"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]

  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.this.name }
  statistic           = "Average"
  period              = "30"
  evaluation_periods  = 2
  threshold           = 10
  comparison_operator = "LessThanOrEqualToThreshold"
}