resource "aws_key_pair" "MyKeyPair" {
  key_name = "MyKeyPair"
  public_key = file("./mykeypair.pub")
}

resource "aws_vpc" "MyVPC" {
    cidr_block = "10.1.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_internet_gateway" "MyInternetGateway" {
  vpc_id = aws_vpc.MyVPC.id
}

resource "aws_subnet" "MyPublicSubnet" {
  cidr_block = "10.1.0.0/21"
  vpc_id = aws_vpc.MyVPC.id
  map_public_ip_on_launch = true
}

resource "aws_route_table" "MyPublicRouteTable" {
  vpc_id = aws_vpc.MyVPC.id
}

resource "aws_route" "MyPublicRoute" {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyInternetGateway.id
    route_table_id = aws_route_table.MyPublicRouteTable.id
}

resource "aws_route_table_association" "MySUbnetRouteTableAssociation" {
    subnet_id = aws_subnet.MyPublicSubnet.id
    route_table_id = aws_route_table.MyPublicRouteTable.id
}

resource "aws_security_group" "MySG" {
  name = "terraform-security-group"
  vpc_id = aws_vpc.MyVPC.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "InboundRule" {
    type = "ingress"
    count = var.securitygrouprule_count
    cidr_blocks = ["0.0.0.0/0"]
    from_port = element(var.from_port,count.index)
    to_port = element(var.to_port,count.index)
    protocol = "tcp"
    security_group_id = aws_security_group.MySG.id
}

resource "aws_instance" "MyInstance"{
    count = var.instance_count
    instance_type = element(var.instance_types,count.index)
    ami = var.image
    key_name = aws_key_pair.MyKeyPair.key_name
    subnet_id = aws_subnet.MyPublicSubnet.id
    vpc_security_group_ids = [ aws_security_group.MySG.id ]
    provisioner "remote-exec" {
      
      inline = [
        # "sudo su",
        "sudo git clone https://github.com/wangso/KubeEdge-demo.git /root/KubeEdge-demo",
        "sudo sed -i \"s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g\" /etc/ssh/sshd_config",
        "sudo sed -i \"s/PasswordAuthentication no/PasswordAuthentication yes/g\" /etc/ssh/sshd_config",
        "sudo systemctl restart sshd",
        "echo ${var.pwd}\"\\n\"${var.pwd} | sudo passwd",
        # "cd /root",
        "echo | ${element(var.command1,count.index)} ${self.public_ip} -P ''"
      ]
      
      connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("./mykeypair")
      host = self.public_ip
      }
    }
    tags = {
        Name = element(var.instance_names,count.index)
    }
}
