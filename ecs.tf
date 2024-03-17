#---------------------------------------------
# ECS Cluster
#---------------------------------------------
resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = "FARGATE_SPOT"
  }
}


#---------------------------------------------
# ECS Task Definition
#---------------------------------------------
//containerの80ポートをEC2(hostPort)の80番ポートにマッピング
// containerPortと serviceのcontainer_portは一緒
// hostPortとtarget_groupのPortは一緒
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "test-fargate"
  requires_compatibilities = ["FARGATE"]
  # Fargateを使用する場合は"awsvpc"のみ
  network_mode       = "awsvpc"
  cpu                = 1024
  memory             = 2048
  execution_role_arn = aws_iam_role.ecs_role_for_task.arn
  #task_role_arn        = aws_iam_role.ecs_role_for_task.arn
  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "nginx",
    "image": "nginx:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
TASK_DEFINITION
}



#---------------------------------------------
# ECS Service
#---------------------------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "service" {
  name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-service"

  cluster = aws_ecs_cluster.cluster.name

  // capacity providerを設定している場合は launch_typeの設定は必要なし
  #launch_type = "FARGATE"

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 0
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 1
  }

  // ECSタスクの起動数を定義
  desired_count = "0"

  task_definition = aws_ecs_task_definition.task_definition.arn

  // bridgeの場合は設定しない
  network_configuration {
    subnets = [
      aws_subnet.public[0].id,
      aws_subnet.public[1].id
    ]
    security_groups = ["${aws_security_group.ecs_sg.id}"]

    // publicIP付与　publicに配置する場合は必要
    assign_public_ip = "true"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = "nginx"
    // コンテナが受け付けるポート番号
    container_port = "80"
  }
  // タスク定義でネットワークモードを使用しない場合に設定が必要
  #iam_role        = 

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy
    ]
  }
}


#---------------------------------------------
# ECS Autoscaling
#---------------------------------------------
resource "aws_appautoscaling_target" "ecs_scaling" {
  // AWSサービスの名前空間(ドキュメント参照)
  service_namespace = "ecs"
  // 一意のリソースIDを作成
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 2

  // ECSのAutoscaling用のロールを指定する
  // 只、ここで指定しなくてもAWS側で設定されるみたい？？(AWSServiceRoleForECS)
  #role_arn = 

}


resource "aws_appautoscaling_policy" "scaling_out_policy" {
  name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-scaling_out"
  // 一意のリソースIDを作成
  resource_id = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  // 対象スケーラブルターゲット
  scalable_dimension = aws_appautoscaling_target.ecs_scaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling.service_namespace

  policy_type = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    // CPUの平均使用率が70%-80%の場合コンテナを3つ増やす
    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 10
      scaling_adjustment          = 1
    }

    // CPUの平均使用率が80%-90%の場合コンテナを5つ増やす
    step_adjustment {
      metric_interval_lower_bound = 10
      metric_interval_upper_bound = 20
      scaling_adjustment          = 2
    }

    // CPUの平均使用率が90%-の場合コンテナを10増やす
    step_adjustment {
      metric_interval_lower_bound = 20
      scaling_adjustment          = 3
    }
  }
}

// 起動しているコンテナのCPU使用率をみて
// アラーム発報させてオートスケールターゲットを起動
resource "aws_cloudwatch_metric_alarm" "out" {
  count = var.alarm_config["enable"] ? 1 : 0

  alarm_name          = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    ClusterName = aws_ecs_cluster.cluster.name
    ServiceName = aws_ecs_service.service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scaling_out_policy.arn]
}
