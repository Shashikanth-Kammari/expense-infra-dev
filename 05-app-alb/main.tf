resource "aws_lb" "test" {
  name               = "${var.project_name}-${var.environment}-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.app_alb_sg_id]
  subnets            = split(",",data.aws_ssm_parameter.private_subnet_ids.value)

  enable_deletion_protection = flase

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-app-alb"
    }
  )
}