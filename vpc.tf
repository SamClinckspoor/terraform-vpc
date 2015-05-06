# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_block}"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.environment} VPC"
    Environment = "${var.environment}"
  }
}

# Create subnets
resource "aws_subnet" "main" {
  count = "${var.amount_subnets}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${element(split(",", var.subnets_cidr_block), count.index)}"
  availability_zone = "${concat(var.aws_region, lookup(var.subnets, count.index))}"

  tags {
    Name = "${var.environment} subnet ${concat(var.aws_region, lookup(var.subnets, count.index))}"
    Environment = "${var.environment}"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.environment} internet gateway"
    Environment = "${var.environment}"
  }
}

# Create route table
resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "${var.environment} route table"
    Environment = "${var.environment}"
  }
}

# Associate route table to subnets
resource "aws_route_table_association" "main" {
  count = "${var.amount_subnets}"
  subnet_id = "${element(split(",", var.subnets_cidr_block), count.index)}"
  route_table_id = "${aws_route_table.main.id}"
}
