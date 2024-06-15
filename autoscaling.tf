resource "aws_launch_template" "ami" {
  name_prefix   = var.asg_name_prefix
  image_id      = data.aws_ami.ec2_ami.id
  instance_type = var.asg_instance_type
  user_data     = filebase64("user_data.sh")

  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.app_az_a.id
    security_groups             = [aws_security_group.app.id]
    delete_on_termination       = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  block_device_mappings {
    device_name = var.ebs_device_name
    ebs {
      volume_size = var.ebs_volume_size
      volume_type = var.ebs_volume_type
    }
  }
}

resource "aws_autoscaling_group" "app" {
  vpc_zone_identifier = [aws_subnet.app_az_a.id, aws_subnet.app_az_b.id]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  target_group_arns = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.ami.id
    version = "$Latest"
  }
}