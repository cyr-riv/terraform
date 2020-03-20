# Configure the Amazon AWS Provider
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# Setting the Security Groups
resource "aws_security_group" "allow-all" {
  name        = "wordpress-ecs-sg"
  description = "Allow inbound access in all ports"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Get all subnets
data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "ecs-subnets" {
  vpc_id            = "${data.aws_vpc.selected.id}"
}

# ECS execution role
resource "aws_iam_role" "ecs_task_exec_role" {
  name = "ecs-exec-role"

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

# ECS execution policy
resource "aws_iam_policy" "ecs_task_exec_policy" {
  name = "ecs-exec-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# Attach execution policy to execution role
resource "aws_iam_role_policy_attachment" "ecs-role-attach" {
    role       = "${aws_iam_role.ecs_task_exec_role.name}"
    policy_arn = "${aws_iam_policy.ecs_task_exec_policy.arn}"
}

# Creating the ECR repository to store Wordpress image
resource "aws_ecr_repository" "ecr-repo" {
  name = "wordpress-registry"
}

# Creating the ECS cluster
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "wordpress-cluster"
}

# Defining the ECS Task
resource "aws_ecs_task_definition" "ecs-task" {
  family                   = "wordpress"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024 # 1vCPU
  memory                   = 2048 # 2Gb
  execution_role_arn       = "${aws_iam_role.ecs_task_exec_role.arn}"
  container_definitions = <<EOF
  [
    {
      "name": "wordpress",
      "image": "${aws_ecr_repository.ecr-repo.repository_url}:wordpress",
      "cpu": 1024,
      "memory": 2048,
      "networkMode": "awsvpc",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  ]
  EOF
}


# Creating the ECS Service
resource "aws_ecs_service" "wordpress_app" {
  name            = "wordpress-service"
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.ecs-task.family}:${aws_ecs_task_definition.ecs-task.revision}"
  desired_count   = 1
  launch_type     = "FARGATE" # to expose a public ip to reach the deployed container

  network_configuration {
    security_groups  = ["${aws_security_group.allow-all.id}"]
    subnets          = "${data.aws_subnet_ids.ecs-subnets.ids}"
    assign_public_ip = true
  }
}

# Creating the RDS database for Wordpress hosted in ECS
resource "aws_db_instance" "wordpress_db" {
  allocated_storage       = var.db_size
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = var.db_instance
  name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.mysql5.7"
  vpc_security_group_ids  = ["${aws_security_group.allow-all.id}"]
  skip_final_snapshot     = true
}





