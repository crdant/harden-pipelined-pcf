/*
  Security Group Definitions
*/

/*
  Ops Manager Security group
*/
resource "aws_security_group" "directorSG" {
    name = "${var.prefix}-pcf_director_sg"
    description = "Allow incoming connections for Ops Manager."
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.prefix}-Ops Manager Director Security Group"
    }
}

resource "aws_security_group_rule" "allow_directorsg_ingress_default" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["${var.vpc_cidr}"]
    security_group_id = "${aws_security_group.directorSG.id}"
}

resource "aws_security_group_rule" "director_egress_default" {
  type            = "egress"
  protocol        = "-1"
  from_port       = "0"
  to_port         = "0"
  cidr_blocks     = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.directorSG.id}"
}

resource "aws_security_group_rule" "director_egress_dns" {
  type            = "egress"
  protocol        = "udp"
  from_port       = "53"
  to_port         = "53"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.directorSG.id}"
}

resource "aws_security_group_rule" "director_egress_ntp" {
  type            = "egress"
  protocol        = "udp"
  from_port       = "123"
  to_port         = "123"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.directorSG.id}"
}

resource "aws_security_group_rule" "director_egress_for_s3" {
  type            = "egress"
  protocol        = "-1"
  from_port       = "0"
  to_port         = "0"
  prefix_list_ids = [ "${aws_vpc_endpoint.s3.prefix_list_id}" ]

  security_group_id = "${aws_security_group.directorSG.id}"
}

/*
resource "aws_security_group_rule" "director_egress_for_ec2" {
  type            = "egress"
  protocol        = "tcp"
  from_port       = "443"
  to_port         = "443"

  security_group_id = "${aws_security_group.directorSG.id}"
}
*/

resource "aws_security_group_rule" "director_egress_for_cloudfront" {
  type        = "egress"
  protocol    = "tcp"
  from_port   = "443"
  to_port     = "443"
  cidr_blocks = [ "${var.cloudfront_ips}" ]

  security_group_id = "${aws_security_group.directorSG.id}"
}

resource "aws_security_group_rule" "director_egress_for_github" {
  type        = "egress"
  protocol    = "tcp"
  from_port   = "443"
  to_port     = "443"
  cidr_blocks = [ "${var.github_ips}" ]

  security_group_id = "${aws_security_group.directorSG.id}"
}


resource "aws_security_group_rule" "allow_ssh" {
    count           = "${var.opsman_allow_ssh}"
    type            = "ingress"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = "${var.opsman_allow_ssh_cidr_ranges}"

    security_group_id = "${aws_security_group.directorSG.id}"
}

resource "aws_security_group_rule" "allow_https" {
    count           = "${var.opsman_allow_https}"
    type            = "ingress"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = "${var.opsman_allow_https_cidr_ranges}"

    security_group_id = "${aws_security_group.directorSG.id}"
}

/*
  RDS Security group
*/
resource "aws_security_group" "rdsSG" {
    name = "${var.prefix}-pcf_rds_sg"
    description = "Allow incoming connections for RDS."
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.prefix}-RDS Security Group"
    }
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
}

/*
  PCF VMS Security group
*/
resource "aws_security_group" "pcfSG" {
    name = "${var.prefix}-pcf_vms_sg"
    description = "Allow connections between PCF VMs."
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.prefix}-PCF VMs Security Group"
    }
}

resource "aws_security_group_rule" "pcfSG_ingress" {
  type            = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["${var.vpc_cidr}"]

  security_group_id = "${aws_security_group.pcfSG.id}"
}

resource "aws_security_group_rule" "pcfSG_egress_pcf" {
  type            = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["${var.vpc_cidr}"]

  security_group_id = "${aws_security_group.pcfSG.id}"
}

resource "aws_security_group_rule" "pcfSG_egress_PcfHttpElbSg_443" {
  type            = "egress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  source_security_group_id = "${aws_elb.PcfHttpElb.source_security_group_id}"
  security_group_id = "${aws_security_group.pcfSG.id}"
}

resource "aws_security_group_rule" "pcfSG_egress_PcfHttpElbSg_4443" {
  type            = "egress"
  from_port       = 4443
  to_port         = 4443
  protocol        = "tcp"
  source_security_group_id = "${aws_elb.PcfHttpElb.source_security_group_id}"
  security_group_id = "${aws_security_group.pcfSG.id}"
}

resource "aws_security_group" "cloud_controller" {
  name        = "cloud-controller-security-group"
  description = "Allow cloud controller to access EC2 and S3"
  vpc_id      = "${aws_vpc.PcfVpc.id}"

  tags {
    Name = "cloud-controller-security-group"
  }

  lifecycle {
    ignore_changes = ["name"]
  }
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

output "director_security_group" {
  value = "${aws_security_group.directorSG.id}"
}

output "cloud_controller_security_group" {
  value = "${aws_security_group.cloud_controller.id}"
}
