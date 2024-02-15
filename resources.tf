resource "aws_ecs_cluster" "isendros-plp-ecs-cluster-tf" {
  name = "isendros-plp-ecs-cluster-tf"
}

resource "aws_ecs_service" "isendros-plp-ecs-service-tf" {
  name            = "isendros-plp-ecs-service-tf"
  cluster         = aws_ecs_cluster.isendros-plp-ecs-cluster-tf.name
  task_definition = aws_ecs_task_definition.isendros-plp-ecr-task-definition-tf.arn
  desired_count   = var.desired_count
  depends_on      = [aws_iam_role_policy.isendros-plp-iam-policy-tf, aws_lb_listener.isendros-plp-lb-listener-tf]
  launch_type = "FARGATE"
  network_configuration {
    subnets = [data.aws_subnet.subnet_1.id,data.aws_subnet.subnet_2.id,data.aws_subnet.subnet_3.id]
    security_groups = [data.aws_security_group.sg_1.id, data.aws_security_group.sg_2.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.isendros-plp-lb-target-group-tf.id
    container_name   = "isendros-plp-ecr-task-definition-tf"
    container_port   = 8080
  }
}

resource "aws_ecs_task_definition" "isendros-plp-ecr-task-definition-tf" {
  family = "isendros-plp-ecr-task-definition-tf"
  task_role_arn = "${aws_iam_role.isendros-plp-ecs-service-role-tf.arn}"
  execution_role_arn = "${aws_iam_role.isendros-plp-ecs-service-role-tf.arn}"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu       = 512
  memory    = 1024
  container_definitions = jsonencode([
    {
      name      = "isendros-plp-ecr-task-definition-tf"
      image     = "300563897675.dkr.ecr.eu-west-3.amazonaws.com/isendros-plp:a-random-service-latest"
      cpu       = 0
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          appProtocol = "http"
        }
      ]
      logConfiguration: {
        logDriver: "awslogs",
        options: {
          awslogs-create-group: "true",
          awslogs-group: "/ecs/isendros-plp-ecr-task-definition-tf",
          awslogs-region: "eu-west-3",
          awslogs-stream-prefix: "ecs"
        },
        secretOptions: []
      }
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_appautoscaling_target" "isendros-plp-ecs-autoscaling-target-tf" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/isendros-plp-ecs-cluster-tf/isendros-plp-ecs-service-tf"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on          = [aws_ecs_service.isendros-plp-ecs-service-tf]
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "isendros-plp-ecs-policy-scale-down-tf"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.isendros-plp-ecs-autoscaling-target-tf.resource_id
  scalable_dimension = aws_appautoscaling_target.isendros-plp-ecs-autoscaling-target-tf.scalable_dimension
  service_namespace  = aws_appautoscaling_target.isendros-plp-ecs-autoscaling-target-tf.service_namespace
  depends_on         = [aws_appautoscaling_target.isendros-plp-ecs-autoscaling-target-tf]

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_lb" "isendros-plp-lb-tf" {
  name            = "isendros-plp-lb-tf"
  subnets         = [data.aws_subnet.subnet_1.id,data.aws_subnet.subnet_2.id,data.aws_subnet.subnet_3.id]
  security_groups = [data.aws_security_group.sg_1.id, data.aws_security_group.sg_2.id]
}

resource "aws_lb_target_group" "isendros-plp-lb-target-group-tf" {
  name        = "isendros-plp-lb-target-group-tf"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vcp_1.id
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "isendros-plp-lb-listener-tf" {
  load_balancer_arn = aws_lb.isendros-plp-lb-tf.id
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.isendros-plp-lb-target-group-tf.id
    type             = "forward"
  }
  depends_on = [aws_lb_target_group.isendros-plp-lb-target-group-tf]
}