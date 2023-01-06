variable "image" {
  type = string
  default = "ami-0c7cb70d3eb61492b"
}

variable "instance_count" {
  default = "3"
}

variable "instance_names" {
    type = list
    default = ["Master Cloud","Edge Cloud 1","Edge Cloud 2"]
}

variable "instance_types" {
    type = list
    default = ["t2.medium","t2.micro","t2.large"]
}

variable "securitygrouprule_count" {
  default = "8"
}

variable "from_port" {
  type = list
  default = [8080,10000,2379,10002,6443,22,30000,10249]
}

variable "to_port" {
  type = list
  default = [8080,10000,2380,10002,6443,22,32767,10253]
}

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

# resource "aws_key_pair" "NewKeyPair" {
#   key_name   = "NewTerraformKeyPair"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCEIsB9im2NUCKk41j2wSqUU5sl+sbQn5W/96B+QRXUMtxWzPMKR1yzOfFYFF3t4FnyrTj1rez84Ae0kGKbWfFkni9YbaAmYNBEp2Yuw4N1NmlbF9xHsKAGmOHqqfn4RnkXJB6/ZoCUqEpyMza+Zlrb9UHOr2plzPk9hJoWb5XqejQRFhFBv1MnlQp7sDGC9kM009T7uGIDabtNGVcW3qH3a4doMVEq0fH1FrWdwusqPOin4mAy1GLPz1HNGBOtBVzib4B2xM6W20Ph2ZgbbcLXQMw4AujFQyXF8NkZqNPWbICQSE9szsdHED0oq3TL6Kyivlgp8wLfMdZdcNB/HTVN"
# }

resource "aws_instance" "MyInstance"{
    count = var.instance_count
    instance_type = element(var.instance_types,count.index)
    ami = var.image
    key_name = aws_key_pair.MyKeyPair.key_name
    subnet_id = aws_subnet.MyPublicSubnet.id
    # provisioner "remote-exec" {
      
    #   inline = [
    #     # "yum update -y",
    #     # "yum install -y httpd",
    #     # "systemctl start httpd",
    #     # "systemctl enable httpd",
    #     # "cd /var/www/html",
    #     # "echo \"<br>\" >> index.html",
    #     # "echo \"<h1>Hello World\" > /var/www/html/index.html",
    #   "sudo amazon-linux-extras install -y nginx1.12",
    #   "sudo systemctl start nginx",
    #   "echo 'Hello Master'"
    #   ]
      
    #   connection {
    #   type = "ssh"
    #   user = "ubuntu"
    #   private_key = file("./mykeypair")
    #   host = self.public_ip
    #   }
    # }
    tags = {
        Name = element(var.instance_names,count.index)
    }
}