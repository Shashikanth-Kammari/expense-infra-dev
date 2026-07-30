module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-${var.common_tags.component}"

  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]

  # converting string list to list and get first elementelement(split("," , data.aws_ssm_parameter.public_subnet_id.value), 0)

  subnet_id     = local.private_subnet_id
  ami = data.aws_ami.ami_info.id
  user_data = file("ansible.sh")
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    }
  )
}