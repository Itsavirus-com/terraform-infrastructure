
resource "aws_lb" "load_balancer" {
  name = "${var.PROJECT}-production-alb"
  load_balancer_type = "application"
  internal = false
  security_groups = [aws_security_group.lb.id]
  subnets = [for subnet in aws_subnet.public_subnet : subnet.id]

  tags = {
    Environment = "production"
  }
}

# resource "aws_lb_target_group" "target_group" {
#   name = "${var.PROJECT}-lb-target-group"
#   port = 80
#   protocol = "HTTP"
#   vpc_id = aws_vpc.vpc.id
# }

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = "${aws_lb.load_balancer.arn}" #  load balancer
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = "${aws_lb_target_group.target_group.arn}" # target group
#   }
# }