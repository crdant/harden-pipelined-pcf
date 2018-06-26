data "aws_instance" "opsman_az1" {
  filter {
    name   = "tag:Name"
    values = [ "${var.prefix}-OpsMan az1" ]
  }
}

data "aws_eip" "opsman" {
  public_ip = "${data.aws_instance.opsman_az1.public_ip}"
}
