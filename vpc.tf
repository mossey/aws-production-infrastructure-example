#
# VPC Resources
#  * VPCs
#  * Subnets
#  * Internet Gateway
#  * Route Table in the compute subnet
#

resource "aws_vpc" "compute_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = map(
    "Name", "compute-vpc",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_vpc" "database_vpc" {
  cidr_block = "10.2.0.0/16"

  tags = map(
    "Name", "databse-vpc"
  )
}

resource "aws_vpc" "connectivity_vpc" {
  cidr_block = "10.3.0.0/16"

  tags = map(
    "Name", "connectivity-vpc"
  )
}

resource "aws_subnet" "compute_subnet" {
  count = 3

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.1.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.compute_vpc.id
  tags = map(
    "Name", "compute-subnet",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}


resource "aws_subnet" "database_subnet" {
  count = 3

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.2.${count.index}.0/24"
  vpc_id                  = aws_vpc.database_vpc.id
  tags = map(
    "Name", "database-subnet")
}

resource "aws_subnet" "connectivity_subnet" {
  count = 3

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.3.${count.index}.0/24"
  vpc_id                  = aws_vpc.connectivity_vpc.id
  tags = map(
    "Name", "connectivity-subnet")
}






resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.compute_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.compute_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
}

resource "aws_route_table_association" "demo" {
  count = 3

  subnet_id      = aws_subnet.compute_subnet.*.id[count.index]
  route_table_id = aws_route_table.demo.id
}


resource "aws_vpc_peering_connection" "compute_database_peering_connection" {
  peer_vpc_id   = aws_vpc.compute_vpc.id
  vpc_id        = aws_vpc.database_vpc.id
  auto_accept   = true

  tags = {
    "Name" = "compute-database-peering-connection"
  }

  
}

resource "aws_vpc_peering_connection" "compute_connectivity_peering_connection" {
  peer_vpc_id   = aws_vpc.compute_vpc.id
  vpc_id        = aws_vpc.connectivity_vpc.id
  auto_accept   = true

  
  tags = {
    Name = "compute-connectivity-peering-connection"
  }
  
}