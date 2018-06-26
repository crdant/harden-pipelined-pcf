datasource "aws_instance" "opsman_az1" {
  filter {
    name   = "tag:Name"
    values = [ "${var.prefix}-OpsMan az1" ]
  }
}

resource "aws_eip" "opsman" {
  instance = "${aws_instance.opsman_az1.id}"
  vpc      = true
}
