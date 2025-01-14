resource "aws_cloudwatch_log_group" "this" {
  name              = "/var/fis/${var.resource_prefix}"
  retention_in_days = 1
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "fis_elb_dashboard"

  dashboard_body = jsonencode(
    {
      widgets = [
        {
          type   = "text"
          width  = 16
          height = 1
          x      = 0
          y      = 0


          properties : {
            markdown = "# Load Balancer Metrics"
          }

        },
        {
          type   = "metric"
          width  = 6
          height = 6
          x      = 0
          y      = 1


          properties = {
            metrics = [
              [
                "AWS/ELB",
                "RequestCount",
                "LoadBalancerName",
                aws_elb.this.name,
                {
                  label   = aws_elb.this.name
                  visible = true
                },
              ],
            ]
            period = 60
            region = var.region
            stat   = "Sum"
            title  = "Loadbalancer Request Count"
          }

        },
        {
          type   = "metric"
          width  = 6
          height = 6
          x      = 6
          y      = 1

          properties = {
            metrics = [
              [
                "AWS/ELB",
                "HealthyHostCount",
                "LoadBalancerName",
                aws_elb.this.name,
                {
                  label   = aws_elb.this.name
                  visible = true
                },
              ],
            ]
            period = 60
            region = var.region
            stat   = "Average"
            title  = "Healthy Hosts"
          }

        },
        {
          type   = "metric"
          width  = 6
          height = 6
          x      = 12
          y      = 1

          properties = {
            metrics = [
              [
                "AWS/ELB",
                "Latency",
                "LoadBalancerName",
                aws_elb.this.name,
                {
                  label   = aws_elb.this.name
                  visible = true
                },
              ],
            ]
            period = 60
            region = var.region
            stat   = "Average"
            title  = "Average latency"
            yAxis = {
              left = {
                min = 0
              }
            }
          }

        },
        {
          type   = "text"
          width  = 16
          height = 1
          x      = 0
          y      = 7


          properties : {
            markdown = "# ASG Metrics"
          }

        },
        {
          type   = "metric"
          width  = 6
          height = 6
          x      = 0
          y      = 8

          properties = {
            metrics = [
              [
                "AWS/AutoScaling",
                "GroupDesiredCapacity",
                "AutoScalingGroupName",
                aws_autoscaling_group.this.name,
                {
                  label   = aws_autoscaling_group.this.name
                  visible = true
                },
              ],
            ]
            period = 60
            region = var.region
            stat   = "Average"
            title  = "Desired Capacity"
            yAxis = {
              left = {
                min = 0
              }
            }
          }

        },
        {
          type   = "metric"
          width  = 6
          height = 6
          x      = 6
          y      = 8

          properties = {
            metrics = [
              [
                "AWS/AutoScaling",
                "GroupInServiceInstances",
                "AutoScalingGroupName",
                aws_autoscaling_group.this.name,
                {
                  label   = aws_autoscaling_group.this.name
                  visible = true
                },
              ],
            ]
            period = 60
            region = var.region
            stat   = "Average"
            title  = "In Service Instances"
            yAxis = {
              left = {
                min = 0
              }
            }
          }

        },
        {
          type   = "metric"
          width  = 6
          height = 6
          x      = 12
          y      = 8

          properties = {
            metrics = [
              [
                "AWS/EC2",
                "CPUUtilization",
                "AutoScalingGroupName",
                aws_autoscaling_group.this.name,
                {
                  label   = aws_autoscaling_group.this.name
                  visible = true
                },
              ],
            ]
            period = 60
            region = var.region
            stat   = "Average"
            title  = "CPU Utilization"
            yAxis = {
              left = {
                min = 0
              }
            }
          }

        },
      ]
    }
  )
}