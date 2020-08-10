locals {
  container_name = var.app_name
}

resource "aws_ecr_repository" "this" {
  name = "${var.namespace}/${local.container_name}"

  tags = {
    App = var.app_name
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "${local.container_name}-log-group"
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.38.0"

  container_name  = local.container_name
  container_image = "${aws_ecr_repository.this.repository_url}:${var.container_image_tag}"

  port_mappings = [
    {
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    },
  ]

  map_environment = {
    "PORT" = 8080
  }

  log_configuration = {
    "logDriver" = "awslogs"
    "options" = {
      "awslogs-region"        = var.logs_region
      "awslogs-group"         = aws_cloudwatch_log_group.this.name
      "awslogs-stream-prefix" = var.app_name
    }
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.app_name}-cluster"

  tags = {
    Name = "${var.app_name}-ecs-cluster"
    App  = var.app_name
  }
}

data "aws_iam_policy_document" "assume_by_ecs" {
  statement {
    sid     = "AllowAssumeByEcsTasks"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "execution_role" {
  statement {
    sid    = "AllowECRPull"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]

    resources = [aws_ecr_repository.this.arn]
  }

  statement {
    sid    = "AllowECRAuth"
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    sid    = "AllowLogging"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "task_role" {
  statement {
    sid    = "AllowDescribeCluster"
    effect = "Allow"

    actions = ["ecs:DescribeClusters"]

    resources = [aws_ecs_cluster.this.arn]
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.app_name}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "execution_role" {
  role   = aws_iam_role.execution_role.name
  policy = data.aws_iam_policy_document.execution_role.json
}

resource "aws_iam_role" "task_role" {
  name               = "${var.app_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "task_role" {
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_role.json
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.app_name}-green-blue-ecs-task"
  container_definitions    = module.container_definition.json_map_encoded_list
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
}

resource "aws_security_group" "this" {
  name   = "${var.app_name}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.container_port
    protocol        = "tcp"
    to_port         = var.container_port
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs-sg"
    App  = var.app_name
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.app_name}-service"
  task_definition = aws_ecs_task_definition.this.id
  cluster         = aws_ecs_cluster.this.arn

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  launch_type   = "FARGATE"
  desired_count = var.desired_tasks_count

  network_configuration {
    subnets         = split(",", var.subnet_ids)
    security_groups = [aws_security_group.this.id]

    assign_public_ip = true
  }
}