#---------------------------------------------
# ALB
#---------------------------------------------
resource "aws_lb" "alb" {
  name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-alb"
  // 内部的なロードバランサーにするかどうか
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.alb_sg.id
  ]
  subnets = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  tags = {
    Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-alb"
  }
}


#---------------------------------------------
# target group
#---------------------------------------------
resource "aws_lb_target_group" "alb_target_group" {
  name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-alb-tg"

  ## ALBからECSタスクのコンテナへトラフィックを振り分ける設定
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-alb-tg"
  }

  depends_on = [
    aws_lb.alb
  ]
}


#---------------------------------------------
# Listener
#---------------------------------------------
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

