variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project ="expense"
    Environment = "dev"
    Terraform = "true"
  }
}

variable "db_sg_description" {
  default = "Sg group for DB mysql instances"
}

variable "backend_sg_description" {
  default = "Sg group for backend instances"
}

variable "frontend_sg_description" {
  default = "Sg group for frontend instances"
}

variable "bastion_sg_description" {
  default = "Sg group for bastion instances"
}

variable "ansible_sg_description" {
  default = "Sg group for ansible instances"
}

variable "app_alb_description" {
  default = "Sg group for APP ALB instances"
}

variable "vpn_description" {
  default = "Sg group for APP ALB instances"
}

variable "vpn_sg_rules" {
  default = [
    {
      from_port = 943
      to_port = 943
      protocol = "tcp" # all ports and all protocols
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port = 443
      to_port = 443
      protocol = "tcp" # all ports and all protocols
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port = 22
      to_port = 22
      protocol = "tcp" # all ports and all protocols
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port = 1194
      to_port = 1194
      protocol = "udp" # all ports and all protocols
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}