data "aws_instances" "bosh" {
  instance_tags {
    deployment = "p-bosh"
    instance_group = "bosh"
    job = "bosh"
  }

  instance_state_names = [ "running", "stopped" ]
}

resource "aws_network_interface_sg_attachment" "bosh_sg_attachment" {
  security_group_id    = "${aws_security_group.opsman.id}"
  network_interface_id = "${aws_instance.bosh.*.primary_network_interface_id}"
}
