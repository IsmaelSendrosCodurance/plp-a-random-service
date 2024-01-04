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

resource "aws_ecs_service" "isendros-plp-ecs-service" {
  name            = "isendros-plp-ecs-service"
  cluster         = "isendros-plp"
  task_definition = "isendros-plp-ecr-task-definition"
  desired_count   = 2
  iam_role        = "arn:aws:iam::300563897675:user/ismael.sendros@codurance.com"
}