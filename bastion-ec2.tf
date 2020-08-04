
resource "aws_instance" "bastion" {
  ami                         = "ami-0a13d44dccf1f5cf6"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.connectivity_subnet.0.id
  associate_public_ip_address = true

 tags = {
    Name = "bastion ec2"
  }
}



resource "aws_key_pair" "bastion_key" {
  key_name   = "your_key_name"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZlrIVR9gEYn+Fqt8DNTiQuYzuHYIynwc9/cvjib6b6Ry4RCmcE87oh7ZGFkBuLiTcY3znJS6hu0Uy+tP7ZNy5+MWq/iY/l7ZRwpJ2c827gMguetHhZ6SPohzJK3kRQbHR4wCwKDE7OoefIKdT7okdmqA+j7YMkvvpKpaSq+0lxEDd1gb6cVTxz2R5ZB2SlNLJBFEAafRo/RT+1gztemgF+KAl/4DyNVh8WjzDRbo8XAagVWnWVL3//Kjd0/o07r8YuXkRDV3Y1KlIuSA/rz+lFNvmA7t6E3h4SfjYtI4PRh4zkf01SI/ABIBs8zFGyHvLk4TEkhR6VbJDZ4C/maveBD2GEspXt620oVpu9Ntu2vfQ/SUNf2XK20SJStjTTAuf/kMYDxpWL55jg8wsNm6FguAl73iRHFTv+s8HScxUo+9gCbjylg3Tak6Kdk/luvMuMT9zhDs4SjB3JHsg6faURDwh8GglM2Fq4aoLEvuQYK+pkTAjPL1D94NdA54qEVUTBmBuHZnTjSRXN69OTWNDZYDV9fF2THC9U+XsQvxz1eggO/B/8DknoUxeTzIxBFdGG5lzfLeOC2VS/ztr4gXxlJUeNk3Qqx8iuxuKvHRij9EZE3p6Xfxq5FbBwKp9p9IZbROF5sh+m0Z1lvRNxvzGsSPnfPOfIH/e+gZU2i6O2w== nandwa.moses@gmail.com "
}

output "bastion_public_dns" {
  value = "${aws_instance.bastion.public_dns}"
}


resource "aws_internet_gateway" "bastion_internet_gateway" {
  vpc_id = aws_vpc.connectivity_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}





resource "aws_route_table" "bastion_route_table" {
  vpc_id = aws_vpc.connectivity_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bastion_internet_gateway.id
  }
}

resource "aws_route_table_association" "bastion_rta" {
  count = 3

  subnet_id      = aws_subnet.connectivity_subnet.*.id[count.index]
  route_table_id = aws_route_table.bastion_route_table.id
}