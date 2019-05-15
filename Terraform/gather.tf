data "aws_ami" "amicall" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name = "tag:Find"
    values = ["Packer"]
  }

  filter {
    name = "tag:Release"
    values = ["Latest"]
  }

  filter {
    name = "tag:OS_Version"
    values = ["Ubuntu"]
  }
}
data "aws_security_group" "sg" {
  name = "all tcp"
  vpc_id = "${data.aws_vpc.vpc_select.id}"
}
data "aws_vpc" "vpc_select" {
  id = "${var.vpcid}"
}