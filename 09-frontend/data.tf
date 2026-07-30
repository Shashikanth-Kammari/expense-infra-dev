data "aws_ssm_parameter" "backend_sg_id" {
  name = "/${var.project_name}/${var.environment}/backend_sg_id"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id"
}
data "aws_ssm_parameter" "public_subnet_id" {
  name = "/${var.project_name}/${var.environment}/public_subnet_id"
}

data "aws_ssm_parameter" "app_alb_listener_arn_https" {
  name = "/${var.project_name}/${var.environment}/app_alb_listener_arn_https"
}


data "aws_ami" "ami_info" {
  most_recent = true
  owners = ["620549678005"]
  filter {
    name = "name"
    values = ["Devops"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

}