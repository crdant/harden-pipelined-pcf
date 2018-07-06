data "aws_instance" "bosh" {
  instance_tags {
    deployment = "p-bosh"
    instance_group = "bosh"
    job = "bosh"
  }

  filter {
    name = "instance-state-name"
    values = [ "running" ]
  }
}

resource "aws_network_interface_sg_attachment" "bosh" {
  security_group_id    = "${data.aws_security_group.opsman.id}"
  network_interface_id = "${data.aws_instance.bosh.network_interface_id}"
}
