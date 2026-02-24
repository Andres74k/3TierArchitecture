resource "aws_alb" "public" {
  name               = "public"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_alb.id]
  subnets            = [aws_subnet.public_a.id,aws_subnet.public_b.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "web" {
  name     = "web-lb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path = "/"
    protocol = "HTTP"
  }
} 

# resource "aws_lb_target_group_attachment" "web" {
#   target_group_arn = aws_lb_target_group.web.arn
#   for_each = aws_instance.web
#   target_id        = each.value.id
#   port             = 3000
# }

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_alb.public.arn
  port              = 80
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
  # default_action {
  #   type = "redirect"
  # #   redirect {
  # #     port        = "443"
  # #     protocol    = "HTTPS"
  # #     status_code = "HTTP_301"
  # #   }
  # # }
  # }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_alb.public.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = aws_acm_certificate.cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.web.arn
#   }
# }

#----------------------------------------------------

resource "aws_alb" "private" {
  name               = "private"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb.id]
  subnets            = [aws_subnet.private_a.id,aws_subnet.private_b.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app" {
  name     = "app-lb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path = "/"
    protocol = "HTTP"
  }
} 

# resource "aws_lb_target_group_attachment" "app" {
#   target_group_arn = aws_lb_target_group.app.arn
#   for_each = aws_instance.app
#   target_id        = each.value.id
#   port             = 3000
# }

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_alb.private.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

