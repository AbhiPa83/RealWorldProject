resource "aws_autoscaling_group" "asg" {
  desired_capacity = 3
  max_size         = 6
  min_size         = 3

  vpc_zone_identifier = var.subnets

  launch_template {
    id      = var.lt_id
    version = "$Latest"
  }

  target_group_arns = [var.target_group]
}