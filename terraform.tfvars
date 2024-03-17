project_name = {
  test_ecs = {
    tentative    = "test"
    service_name = "fargate"
  }
}

availability_zones = [
  "ap-northeast-1a",
  "ap-northeast-1c"
]

zones = [
  "1a",
  "1c"
]

alarm_config = {
  enable = false
}

