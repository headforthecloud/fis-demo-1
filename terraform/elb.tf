resource "aws_security_group" "elb_sg" {
  name        = "${var.resource_suffix}_elb_sg"
  description = "Security Group for the ELB"
  vpc_id      = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "elb_allow_http_in" {
  security_group_id = aws_security_group.elb_sg.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
  description = "Allow HTTP traffic from anywhere"
}

resource "aws_vpc_security_group_egress_rule" "elb_allow_http_out" {
  security_group_id = aws_security_group.elb_sg.id

  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2_sg.id
  description                  = "Allow outgoing HTTP traffic to EC2 SG"
}

resource "aws_elb" "this" {
  name    = replace("${var.resource_suffix}-elb", "_", "-")
  subnets = aws_subnet.public.*.id

  security_groups = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.resource_suffix}_elb"
  }

  depends_on = [aws_security_group.elb_sg]

}
