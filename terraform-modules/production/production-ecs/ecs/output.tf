output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "ecsTaskRoleWithS3Access_arn" {
  value = aws_iam_role.ecsTaskRoleWithS3Access.arn
}