
#---------------------------------------------
# IAM Role attachment for task_definition
#---------------------------------------------
resource "aws_iam_role" "ecs_role_for_task" {
  name               = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-role_for_task"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "for_task_role" {
  role = aws_iam_role.ecs_role_for_task.name
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
