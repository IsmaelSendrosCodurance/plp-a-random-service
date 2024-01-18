terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_iam_role" "isendros-plp-ecs-service-role-tf" {
  name                = "isendros-plp-ecs-service-role-tf"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "isendros-plp-iam-policy-attachment-tf" {
  role = aws_iam_role.isendros-plp-ecs-service-role-tf.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "isendros-plp-iam-policy-tf" {
  name = "isendros-plp-iam-policy-tf"
  role = aws_iam_role.isendros-plp-ecs-service-role-tf.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
        ],
        "Resource": "arn:aws:ecr:eu-west-3:300563897675:repository/isendros-plp"
      }
    ]
  })
}

resource "aws_ecs_cluster" "isendros-plp-ecs-cluster-tf" {
  name = "isendros-plp-ecs-cluster-tf"
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
          containerPort = 80
          hostPort      = 80
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

variable "desired_count" {
  type        = number
}
data "aws_subnet" "subnet_1" {
  id ="subnet-075cbc4a"
}
data "aws_subnet" "subnet_2" {
  id ="subnet-72b47f09"
}
data "aws_subnet" "subnet_3" {
  id ="subnet-e060d189"
}
data "aws_security_group" "sg_1" {
  id ="sg-951261fc"
}
data "aws_security_group" "sg_2" {
  id ="sg-0b4207a15d05501c6"
}


resource "aws_ecs_service" "isendros-plp-ecs-service-tf" {
  name            = "isendros-plp-ecs-service-tf"
  cluster         = aws_ecs_cluster.isendros-plp-ecs-cluster-tf.name
  task_definition = aws_ecs_task_definition.isendros-plp-ecr-task-definition-tf.arn
  desired_count   = var.desired_count
  depends_on      = [aws_iam_role_policy.isendros-plp-iam-policy-tf]
  launch_type = "FARGATE"
  network_configuration {
    subnets = [data.aws_subnet.subnet_1.id,data.aws_subnet.subnet_2.id,data.aws_subnet.subnet_3.id]
    security_groups = [data.aws_security_group.sg_1.id, data.aws_security_group.sg_2.id]
    assign_public_ip = true
  }

}

resource "aws_appautoscaling_target" "isendros-plp-ecs-autoscaling-target-tf" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/isendros-plp-ecs-cluster-tf/isendros-plp-ecs-service-tf"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "isendros-plp-ecs-policy-scale-down-tf"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.isendros-plp-ecs-autoscaling-target-tf.resource_id
  scalable_dimension = aws_appautoscaling_target.isendros-plp-ecs-autoscaling-target-tf.scalable_dimension
  service_namespace  = aws_appautoscaling_target.isendros-plp-ecs-autoscaling-target-tf.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}