resource "aws_security_group" "ecs_alb" {
  description = "Balancer for ${app_name}"

  vpc_id = "${var.vpc}"
  name   = "${var.app_name}-alb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_target_group" "main" {
  name     = "${var.app_name}"
  port     = "${var.app_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc}"
}

resource "aws_alb" "main" {
  name            = "${var.app_name}"
  subnets         = "${var.subnets}"
  security_groups = ["${aws_security_group.ecs_alb.id}"]
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "${var.app_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.main.id}"
    type             = "forward"
  }
}
