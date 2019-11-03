data "aws_route53_zone" "dev" {
  name = "dev.banthacloud.com"
}

data "aws_subnet_ids" "alb_subnets" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_route53_record" "dev_github_webhook" {
  zone_id = "${data.aws_route53_zone.dev.zone_id}"
  name    = "githook.dev.banthacloud.com"
  type    = "A"

  alias {
    name                   = "${aws_lb.dev_lambda_alb.dns_name}"
    zone_id                = "${aws_lb.dev_lambda_alb.zone_id}"
    evaluate_target_health = false
  }
}



resource "aws_lb" "dev_lambda_alb" {
  name               = "DevLambdaALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.sg_id}"]
  subnets            = "${data.aws_subnet_ids.alb_subnets.ids}"

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "github_hook" {
  name        = "github-webhook"
  target_type = "lambda"
}

data "aws_acm_certificate" "dev" {
  domain      = "*.dev.banthacloud.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "github_webhook_https" {
  load_balancer_arn = "${aws_lb.dev_lambda_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.dev.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.github_hook.arn}"
  }
}

resource "aws_lb_listener" "github_webhook_http" {
  load_balancer_arn = "${aws_lb.dev_lambda_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.github_hook.arn}"
  }
}

