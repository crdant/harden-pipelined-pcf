### Variables
variable "github_ips" {
  type = "list"
}

variable "ec2_ips" {
  type = "list"
}

variable "cloudfront_ips" {
  type = "list"
}

### Extant Security Groups
data "aws_security_group" "opsman" {
  name = "${var.prefix}-pcf_opsman_sg"
}

data "aws_security_group" "pcf_http_lb" {
  name = "${var.prefix}-pcf_PcfHttpElb_sg"
}

data "aws_security_group" "pcf_ssh_lb" {
  name = "${var.prefix}-pcf_PcfSshElb_sg"
}

data "aws_security_group" "pcf_tcp_lb" {
  name = "${var.prefix}-pcf_PcfTcpElb_sg"
}

## Added rules

# opsman/director
resource "aws_security_group_rule" "opsman_ingress_default" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["${data.aws_vpc.pcf_vpc.cidr_block}"]
    security_group_id = "${data.aws_security_group.opsman.id}"
}

resource "aws_security_group_rule" "opsman_egress_default" {
  type            = "egress"
  protocol        = "-1"
  from_port       = "0"
  to_port         = "0"
  cidr_blocks     = ["${data.aws_vpc.pcf_vpc.cidr_block}"]
  security_group_id = "${data.aws_security_group.opsman.id}"
}

resource "aws_security_group_rule" "opsman_egress_dns" {
  type            = "egress"
  protocol        = "udp"
  from_port       = "53"
  to_port         = "53"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${data.aws_security_group.opsman.id}"
}

resource "aws_security_group_rule" "opsman_egress_ntp" {
  type            = "egress"
  protocol        = "udp"
  from_port       = "123"
  to_port         = "123"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${data.aws_security_group.opsman.id}"
}

resource "aws_security_group_rule" "opsman_egress_for_s3" {
  type            = "egress"
  protocol        = "-1"
  from_port       = "0"
  to_port         = "0"
  prefix_list_ids = [ "${aws_vpc_endpoint.s3.prefix_list_id}" ]

  security_group_id = "${data.aws_security_group.opsman.id}"
}

resource "aws_security_group_rule" "opsman_egress_for_cloudfront" {
  type        = "egress"
  protocol    = "tcp"
  from_port   = "443"
  to_port     = "443"
  cidr_blocks = [ "${var.cloudfront_ips}" ]

  security_group_id = "${data.aws_security_group.opsman.id}"
}

resource "aws_security_group_rule" "opsman_egress_for_github" {
  type        = "egress"
  protocol    = "tcp"
  from_port   = "443"
  to_port     = "443"
  cidr_blocks = [ "${var.github_ips}" ]

  security_group_id = "${data.aws_security_group.opsman.id}"
}

# PCF

resource "aws_security_group_rule" "pcf_ingress" {
  type            = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["${data.aws_vpc.pcf_vpc.cidr_block}"]

  security_group_id = "${aws_security_group.pcfSG.id}"
}

resource "aws_security_group_rule" "pcf_egress_pcf" {
  type            = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["${data.aws_vpc.pcf_vpc.cidr_block}"]

  security_group_id = "${aws_security_group.pcfSG.id}"
}

resource "aws_security_group_rule" "pcf_egress_PcfHttpElbSg_443" {
  type            = "egress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  source_security_group_id = "${aws_elb.PcfHttpElb.source_security_group_id}"
  security_group_id = "${aws_security_group.pcfSG.id}"
}

resource "aws_security_group_rule" "pcf_egress_PcfHttpElbSg_4443" {
  type            = "egress"
  from_port       = 4443
  to_port         = 4443
  protocol        = "tcp"
  source_security_group_id = "${aws_elb.PcfHttpElb.source_security_group_id}"
  security_group_id = "${aws_security_group.pcfSG.id}"
}

### Additional security groups

resource "aws_security_group" "cloud_controller" {
  name        = "cloud-controller-security-group"
  description = "Allow cloud controller to access EC2 and S3"
  vpc_id      = "${data.aws_vpc.pcf_vpc.id}"

  tags {
    Name = "cloud-controller-security-group"
  }

  lifecycle {
    ignore_changes = ["name"]
  }
}

resource "aws_security_group_rule" "cloud_controller_ingress" {
  type            = "ingress"
  protocol        = -1
  from_port       = 0
  to_port         = 0
  cidr_blocks     = [ "${aws_vpc.PcfVpc.cidr_block}" ]

  security_group_id = "${aws_security_group.cloud_controller.id}"
}

resource "aws_security_group_rule" "cloud_controller_pcf_egress" {
  type            = "egress"
  protocol        = -1
  from_port       = 0
  to_port         = 0
  cidr_blocks     = [ "${aws_vpc.PcfVpc.cidr_block}" ]

  security_group_id = "${aws_security_group.cloud_controller.id}"
}

resource "aws_security_group_rule" "cloud_controller_egress_for_s3_tls" {
  type            = "egress"
  protocol        = "tcp"
  from_port       = "443"
  to_port         = "443"
  prefix_list_ids = [ "${aws_vpc_endpoint.s3.prefix_list_id}" ]

  security_group_id = "${aws_security_group.cloud_controller.id}"
}

resource "aws_security_group_rule" "cloud_controller_egress_for_s3" {
  type            = "egress"
  protocol        = "tcp"
  from_port       = "80"
  to_port         = "80"
  prefix_list_ids = [ "${aws_vpc_endpoint.s3.prefix_list_id}" ]

  security_group_id = "${aws_security_group.cloud_controller.id}"
}

### Outputs for scripts to use

output "cloud_controller_security_group_id" {
  value = "aws_security_group.cloud_controller.id"
}
