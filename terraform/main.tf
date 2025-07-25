provider "aws" {
  region = "ap-south-1"
}


resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_ip
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

resource "aws_subnet" "public_subnet-1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "12.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet-1"
  }
}

resource "aws_subnet" "public_subnet-2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "12.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet-2"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "rt_assoc_public-1" {
  subnet_id      = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rt_assoc_public-2" {
  subnet_id      = aws_subnet.public_subnet-2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "12.0.3.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "rt_assoc_private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}



resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

resource "aws_instance" "web-app-1" {
  ami                    = var.instance_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet-1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "ec2-testing-key"

  tags = {
    Name = "web-server-1"
  }
}
resource "aws_instance" "web-app-2" {
  ami                    = var.instance_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet-2.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "ec2-testing-key"

  tags = {
    Name = "web-server-2"
  }
}
resource "aws_instance" "web-app-3" {
  ami                    = var.instance_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet-1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "ec2-testing-key"

  tags = {
    Name = "web-server-3"
  }
}
resource "aws_instance" "web-app-4" {
  ami                    = var.instance_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet-2.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "ec2-testing-key"

  tags = {
    Name = "web-server-4"
  }
}

# resource "aws_launch_template" "web_template"{
#   name_prefix = "web-template-"
#   image_id = var.instance_ami
#   instance_type = var.instance_type
#   key_name = "ec2-testing-key"

#   network_interfaces {
    
#   }

#   tag_specifications {
    
#   }

# }

# resource "aws_autoscaling_group" "web_asg" {
#   desired_capacity = 2
#   max_size = 4
#   min_size = 2
#   vpc_zone_identifier = [ aws_subnet.public_subnet-1, aws_subnet.public_subnet-2 ]
#   health_check_type = "EC2"

#   launch_template {
#     id = aws_launch_template.web_template.id
#   }
# }

# resource "aws_autoscaling_policy" "scale_up" {
#   name = "scale-up-policy"
#   scaling_adjustment = 1
#   adjustment_type = "ChangeInCapacity"
#   cooldown = 300
#   autoscaling_group_name = aws_autoscaling_group.web_asg.name
# }

# resource "aws_autoscaling_policy" "scale_up" {
#   name = "scale-up-policy"
#   scaling_adjustment = -1
#   adjustment_type = "ChangeInCapacity"
#   cooldown = 300
#   autoscaling_group_name = aws_autoscaling_group.web_asg.name
# }


