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
    component = "web-alb"
  }
}

variable "zone_name" {
  default = "shashikanth.online"
}

variable "zone_id" {
  default = "Z0433999PFN006E2ZQ5H"
}
