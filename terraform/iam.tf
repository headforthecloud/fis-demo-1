# create an iam role to act as ec2 instance profile
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.resource_prefix}_ec2_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_instance_policy_attachment" {
  name       = "ec2_instance_policy_attachment_${var.resource_prefix}"
  roles      = [aws_iam_role.ec2_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile_${var.resource_prefix}"
  role = aws_iam_role.ec2_instance_role.name
}

# create an iam role for FIS to use
resource "aws_iam_role" "fis_role" {
  name = "${var.resource_prefix}_fis_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "fis.amazonaws.com",
            "delivery.logs.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_fis_policy_attachment" {
  name       = "${var.resource_prefix}_ec2_fis_policy"
  roles      = [aws_iam_role.fis_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEC2Access"
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${var.resource_prefix}_fis_logs_policy"
  description = "Policy to allow CloudWatch log group and log stream access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:Describe*",
          "logs:Create*",
          "logs:Put*"
        ],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "cloudwatch_logs_policy_attachment" {
  name       = "${var.resource_prefix}_fis_logs_policy_attachment"
  roles      = [aws_iam_role.fis_role.name]
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
