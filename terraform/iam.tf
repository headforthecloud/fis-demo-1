# create an iam role to act as ec2 instance profile
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.resource_suffix}_ec2_iam_role"
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
  name       = "ec2_instance_policy_attachment_${var.resource_suffix}"
  roles      = [aws_iam_role.ec2_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile_${var.resource_suffix}"
  role = aws_iam_role.ec2_instance_role.name
}
