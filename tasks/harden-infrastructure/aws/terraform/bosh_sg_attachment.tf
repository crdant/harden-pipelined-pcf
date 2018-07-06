data "aws_instances" "bosh" {
  instance_tags {
    deployment = "p-bosh"
    instance_group = "bosh"
    job = "bosh"
  }

  instance_state_names = [ "running", "stopped" ]
}

resource "aws_network_interface_sg_attachment" "bosh" {
  security_group_id    = "${data.aws_security_group.opsman.id}"
  network_interface_id = "${data.aws_instances.bosh.*.primary_network_interface_id}"
}
