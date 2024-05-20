# doormat aws tf-push --workspace tfe-ecs-setup --organization srahul3 --account 980777455695
resource "aws_vpc" "tfe" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "tfe"
  }
}
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.tfe.id
  cidr_block              = cidrsubnet(aws_vpc.tfe.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones_1
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.tfe.id
  cidr_block              = cidrsubnet(aws_vpc.tfe.cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones_2
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.tfe.id
  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.tfe.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "subnet_route" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_route" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table.id
}

# setting up security group
resource "aws_security_group" "security_group" {
  name   = "tfe-ecs-security-group"
  vpc_id = aws_vpc.tfe.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "tfe-agent-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "tfe-agent"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  # execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn            = aws_iam_role.ecs_task_role.arn
  # runtime_platform {
  #   operating_system_family = "LINUX"
  #   cpu_architecture        = "X86_64"
  # }
  container_definitions = jsonencode([
    {
      name      = "tfe-agent"
      image     = "amazon/amazon-ecs-agent"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name                = "tfe-agent-ecs-service"
  cluster             = aws_ecs_cluster.ecs_cluster.id
  task_definition     = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count       = 1
  launch_type         = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
    security_groups  = [aws_security_group.security_group.id]
    assign_public_ip = false
  }
}
