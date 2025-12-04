resource "random_integer" "random_public_subnet_index" {
  min = 0
  max = length(aws_subnet.public_subnet.*.id) - 1
}

resource "random_integer" "random_private_subnet_1_index" {
  min = 0
  max = length(aws_subnet.private_subnet_1.*.id) - 1
}

resource "random_integer" "random_private_subnet_2_index" {
  min = 0
  max = length(aws_subnet.private_subnet_2.*.id) - 1
}

resource "random_integer" "random_ecs_index" {
  min = 0
  max = length(aws_security_group.ecs.*.id) - 1
}

resource "random_integer" "random_db_index" {
  min = 0
  max = length(aws_security_group.db.*.id) - 1
}
output "public_subnet_id" {
    value = aws_subnet.public_subnet.*.id[random_integer.random_public_subnet_index.result]
}

output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.*.id[random_integer.random_private_subnet_1_index.result]
}

output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.*.id[random_integer.random_private_subnet_2_index.result]
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.*.id[random_integer.random_ecs_index.result]
}

output "db_security_group_id" {
  value = aws_security_group.db.*.id[random_integer.random_db_index.result]
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "app_url" {
  value = aws_lb.load_balancer.dns_name
}

output "sg_id" {
    value = aws_security_group.sg.id
}