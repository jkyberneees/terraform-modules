data "aws_subnet_ids" "this" {
  vpc_id = var.vpc_id
}

resource "aws_security_group" "this" {
  name   = "${var.app_name}-alb-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.app_name}-alb-sg"
    App  = var.app_name
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "this" {
  name               = "${var.app_name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]
  subnets            = data.aws_subnet_ids.this.ids

  tags = {
    Name = "${var.app_name}-alb"
    App  = var.app_name
  }
}

locals {
  target_groups = [
    "green",
    "blue",
  ]
}

resource "aws_lb_target_group" "this" {
  count = length(local.target_groups)

  name = "${var.app_name}-tg-${element(local.target_groups, count.index)}"

  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = var.target_group_hcheck_path
    port = var.target_group_hcheck_port
  }

  tags = {
    Name = "${var.app_name}-tg"
    App  = var.app_name
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.*.arn[0]
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_lb_listener.this.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.*.arn[0]
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}