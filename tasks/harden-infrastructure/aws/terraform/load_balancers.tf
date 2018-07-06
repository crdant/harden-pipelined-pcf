### Load balancers

data "aws_elb" "pcf_http" {
  name = "${var.prefix}-Pcf-Http-Elb"
}

data "aws_elb" "pcf_ssh" {
  name = "${var.prefix}-Pcf-Ssh-Elb"
}

data "aws_elb" "pcf_tcp" {
  name = "${var.prefix}-Pcf-Tcp-Elb"
}
