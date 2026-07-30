module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-${var.common_tags.component}"

  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]

  # converting string list to list and get first elementelement(split("," , data.aws_ssm_parameter.public_subnet_id.value), 0)

  subnet_id     = local.public_subnet_id
  ami = data.aws_ami.ami_info.id
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    }
  )
}

resource "null_resource" "frontend_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_ids = module.frontend.instance_id
#   }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = "Needto_give_password"
    host        = module.frontend.public_ip
  }
  provisioner "file" {
    source      = "${var.common_tags.component}.sh"
    destination = "/tmp/${var.common_tags.component}.sh"
  }


  provisioner "local-exec" {
      command = "aws ec2 terminate-instances --instance-ids ${module.frontend.frontend_id}"
    }
    depends_on = [aws-ami_from_instance.backend]
}  

resource "aws_ec2_instance_state" "frontend" {
  instance_id = module.frontend.id
  state       = "stopped"
  #stop the server only after when null resource provisioning is completed
  depends_on = [null_resource.frontend]
}


resource "aws_ami_from_instance" "frontend" {
  name               = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  source_instance_id = module.frontend.id
  depends_on = [aws_ec2_instance_state.frontend]
}

#teraget group creation for backend service
resource "aws_lb_target_group" "frontend" {
  name     = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    path                = "/health"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

#aws launch template creation for backend service
resource "aws_launch_template" "frontend" {
  name          = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  image_id      = aws_ami_from_instance.frontend.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  update_default_version = true #sets the latest version as default version for the launch template
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
      }
    )
  }
}

#auto scaling group creation for frontend service
resource "aws_autoscaling_group" "frontend" {
  name                      = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  target_group_arns         = [aws_lb_target_group.frontend.arn]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }
  health_check_type         = "ELB"
  health_check_grace_period = 60
  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  } 
  tag {
    key                 = "Project"
    value               = "${project_name}"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_policy" "backend_scale_up" {
  name                   = "${var.project_name}-${var.environment}-${var.common_tags.component}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 100 #less the number higher the priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.app-${var.environment}.${var.zone_name}"]
    }
  }
}