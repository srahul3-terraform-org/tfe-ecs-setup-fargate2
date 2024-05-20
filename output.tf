output "subnets" {
  value = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
}

output "region" {
  value = var.aws_region
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}

output "ecs_service_id" {
  value = aws_ecs_service.ecs_service.id
}

output "ecs_task_definition_id" {
  value = aws_ecs_task_definition.ecs_task_definition.id
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.ecs_task_definition.arn
}

output "ecs_service_cluster" {
  value = aws_ecs_service.ecs_service.cluster
}