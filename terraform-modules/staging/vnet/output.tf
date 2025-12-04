output "sg_id" {
    value = aws_security_group.sg.id
}

resource "random_integer" "random_public_subnet_index" {
  min = 0
  max = length(aws_subnet.public_subnet.*.id) - 1
}
output "public_subnet_id" {
    value = aws_subnet.public_subnet.*.id[random_integer.random_public_subnet_index.result]
}