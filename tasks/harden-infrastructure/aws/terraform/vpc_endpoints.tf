resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = "${data.aws_vpc.pcf_vpc.id}"
  service_name      = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    "${data.aws_security_group.opsman_security_group.id}"
  ]

  subnet_ids = [
    "${aws_subnet.pcf_infra_az1.id}"
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id             = "${data.aws_vpc.pcf_vpc.id}"
  service_name       = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type  = "Gateway"

  route_table_ids    = [
    "${data.aws_route_table.pcf_public.id}",
    "${data.aws_route_table.pcf_private_az1.id}",
    "${data.aws_route_table.pcf_private_az2.id}",
    "${data.aws_route_table.pcf_private_az3.id}"
  ]
}
