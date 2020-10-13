//APPLICATION LOAD BALANCER
resource "aws_lb" "test" {
  name               = "flask-react-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0257a296c349723ea", "sg-83f80bf7"]
  subnets            = ["subnet-6a1fb50c", "subnet-3152946b"]

  enable_deletion_protection = false
}


resource "aws_default_vpc" "adopted" {
  tags = {
    Name = "Default VPC"
  }
}


//LISTENER
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client.arn
  }
}

//Target Group
resource "aws_lb_target_group" "client" {
  name     = "flask-react-client-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.adopted.id
}

//Target Group
resource "aws_lb_target_group" "users" {
  name     = "flask-react-users-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.adopted.id
  health_check {
    path = "/ping"
  }
}

//RULES
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.test.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.users.arn
  }

  condition {
    path_pattern {
      values = ["/users*", "/ping", "/auth*", "/doc/", "/swagger*"]
    }
  }

}
