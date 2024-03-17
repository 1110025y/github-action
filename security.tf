#---------------------------------------------
# Security group for ECS
#---------------------------------------------
resource "aws_security_group" "ecs_sg" {
  name   = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-sg"
  }
}

resource "aws_security_group_rule" "in_http" {
  security_group_id = aws_security_group.ecs_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  #cidr_blocks       = ["0.0.0.0/0"]
  #cidr_blocks       = ["49.105.103.0/24"]
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "out_http" {
  security_group_id = aws_security_group.ecs_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}



#---------------------------------------------
# Security group for ALB
#---------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-alb-sg"
  description = "security group for alb"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_in_http" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}



resource "aws_security_group_rule" "alb_out_http" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}


