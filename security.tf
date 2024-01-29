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
