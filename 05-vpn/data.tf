data "aws_ssm_parameter" "vpn_sg_id_sg_id" {
  name = "/${var.project_name}/${var.environment}/vpn_sg_id"
}


data "aws_ssm_parameter" "public_subnet_id" {
  name = "/${var.project_name}/${var.environment}/public_sg_id"
}


data "aws_ami" "ami_info" {
  most_recent = true
  owners = ["620549678005"]
  filter {
    name = "name"
    values = ["ami name"] # we need to take ami id name it unique name so it will filter out the ami
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