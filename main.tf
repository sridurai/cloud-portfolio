resource "aws_vpc" "lcl_vpc_sri" {
cidr_block="10.0.0.0/16"  
enable_dns_support   = true
enable_dns_hostnames = true
tags = {name = "cloud_portfolio_vpc_sridurai"}
}

resource "aws_subnet" "lcl_subnet_sri" {
  vpc_id= aws_vpc.lcl_vpc_sri.id //connect subnets with VPC (lcl_vpc_sri) and creates this subnet inside this VPC
  cidr_block="10.0.0.0/24"  
  availability_zone="us-east-1a"
  map_public_ip_on_launch = true
  tags ={name = "sri-public-subnet"}
}
resource "aws_internet_gateway" "lcl_igw"{
vpc_id= aws_vpc.lcl_vpc_sri.id
tags = {name="sri-public-subnet-igw"}
}
resource "aws_route_table" "lcl_route_table_sri"{
vpc_id= aws_vpc.lcl_vpc_sri.id
route{
cidr_block="0.0.0.0/0"
gateway_id = aws_internet_gateway.lcl_igw.id
}
tags = {name = "sri-route-table"}
}
resource "aws_route_table_association" "lcl_rt_assoc" {
subnet_id= aws_subnet.lcl_subnet_sri.id
route_table_id= aws_route_table.lcl_route_table_sri.id
}
resource "aws_security_group" "lcl_sg" {
  name= "sri-sg"
  vpc_id = aws_vpc.lcl_vpc_sri.id
  ingress { //allow incoming traffic - Allow me (admin) to access the server.
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["103.158.255.200/32"]
  }
  ingress { //allow HTTP traffic - Allow anyone on the internet to view my website.
description = "HTTP"
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
  }
  egress{ //allow all outgoing traffic - Allow my server to access the internet.
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks=["0.0.0.0/0"]
  }
}
data "aws_ami" "amazon_linux" {
  most_recent=true
  owners=["amazon"]
  filter{
    name="name"
    values=["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_instance" "lcl_ec2" {
  ami=data.aws_ami.amazon_linux.id //uses the fetched AMI
  instance_type = "t3.micro"
  subnet_id = aws_subnet.lcl_subnet_sri.id
  vpc_security_group_ids = [aws_security_group.lcl_sg.id]
  key_name="sri_key"
  tags={
    name="Cloud-portfolio-sridurai-ec2"
  }
  
}

