### VPC

data "aws_vpc" "pcf" {
  tags {
  Name = "${var.prefix}-terraform-pcf-vpc"
  }
}

### Public subnets

# AZ1
data "aws_subnet" "pcf_public_az1" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
    Name = "${var.prefix}-PcfVpc Public Subnet AZ1"
  }
}

# AZ2
data "aws_subnet" "pcf_public_az2" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
    Name = "${var.prefix}-PcfVpc Public Subnet AZ2"
  }
}

# AZ3
data "aws_subnet" "pcf_public_az3" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
    Name = "${var.prefix}-PcfVpc Public Subnet AZ3"
  }
}

### Private subnets

# PAS

data "aws_subnet" "pcf_pas_az1" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Ert Subnet AZ1"
  }
}

data "aws_subnet" "pcf_pas_az2" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Ert Subnet AZ2"
  }
}

data "aws_subnet" "pcf_pas_az3" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Ert Subnet AZ3"
  }
}

# RDS

data "aws_subnet" "pcf_rds_az1" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Rds Subnet AZ1"
  }
}

data "aws_subnet" "pcf_rds_az2" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Rds Subnet AZ2"
  }
}

data "aws_subnet" "pcf_rds_az3" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Rds Subnet AZ3"
  }
}

# Services

data "aws_subnet" "pcf_services_az1" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Services Subnet AZ1"
  }
}

data "aws_subnet" "pcf_services_az2" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Services Subnet AZ2"
  }
}

data "aws_subnet" "pcf_services_az3" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Services Subnet AZ3"
  }
}

# Dynamic Services

data "aws_subnet" "pcf_dynamic_services_az1" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Dynamic Services Subnet AZ1"
  }
}

data "aws_subnet" "pcf_dynamic_services_az2" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Dynamic Services Subnet AZ2"
  }
}

data "aws_subnet" "pcf_dynamic_services_az3" {
  vpc_id = "${data.aws_vpc.pcf.id}"
  tags {
      Name = "${var.prefix}-PcfVpc Dynamic Services Subnet AZ3"
  }
}

# Infrastructure

data "aws_subnet" "pcf_infra_az1" {
  tags {
    Name = "${var.prefix}-PcfVpc Infrastructure Subnet"
  }
}

### Route Tables

data "aws_route_table" "pcf_public" {
  subnet_id = "${data.aws_subnet.pcf_public_az1.id}"
}

data "aws_route_table" "pcf_private_az1" {
  subnet_id = "${data.aws_subnet.pcf_pas_az1.id}"
}

data "aws_route_table" "pcf_private_az2" {
  subnet_id = "${data.aws_subnet.pcf_pas_az2.id}"
}

data "aws_route_table" "pcf_private_az3" {
  subnet_id = "${data.aws_subnet.pcf_pas_az3.id}"
}
