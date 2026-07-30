module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-${var.common_tags.component}"

  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]

  # converting string list to list and get first elementelement(split("," , data.aws_ssm_parameter.public_subnet_id.value), 0)

  subnet_id     = local.private_subnet_id
  ami = data.aws_ami.ami_info.id
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    }
  )
}

resource "null_resource" "backend_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_ids = module.backend.instance_id
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = "Needto_give_password"
    host        = module.backend.private_ip
  }
  # provisioner "file" {
  #   source      = "${var.common_tags.component}.sh"
  #   destination = "/tmp/${var.common_tags.component}.sh"
  # }


  provisioner "local-exec" {
      command = "aws ec2 terminate-instances --instance-ids ${module.backend.backend_id}"
    }
    depends_on = [aws-ami_from_instance.backend]
}  

resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state       = "stopped"
  #stop the server only after when null resource provisioning is completed
  depends_on = [null_resource.backend]
}


resource "aws_ami_from_instance" "backend" {
  name               = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  source_instance_id = module.backend.id
  depends_on = [aws_ec2_instance_state.backend]
}