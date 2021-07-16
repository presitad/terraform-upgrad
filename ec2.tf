resource "tls_private_key" "task1_p_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "task1-key" {
  key_name   = "task1-key"
  public_key = tls_private_key.task1_p_key.public_key_openssh
}

resource "local_file" "private_key" {
  depends_on = [
    tls_private_key.task1_p_key,
  ]
  content  = tls_private_key.task1_p_key.private_key_pem
  filename = "bastion.pem"
}

resource "aws_subnet" "bastion_subnet" {
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = "10.20.100.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.az_list[0]
  tags = {
    Name = "Bastion Subnet"
  }
}

resource "aws_security_group" "bastion_sg" {
  depends_on = [aws_subnet.bastion_subnet]
  name       = "bastion_sg"
  vpc_id     = aws_vpc.myVpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.selfip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
}

resource "aws_instance" "bastion" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.bastion_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = "task1-key"

  tags = {
    Name = "bastion host"
  }
}

resource "aws_security_group" "private_instance_sg" {
  name        = "private_instance_sg"
  description = "allow ssh bositon inbound traffic to private instance"
  vpc_id      = aws_vpc.myVpc.id
  ingress {
    description     = "Only ssh_sql_bositon in private subnet"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_instance_sg"
  }
}

resource "aws_instance" "jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id              = aws_subnet.private_subnet[0].id
  vpc_security_group_ids = [aws_security_group.private_instance_sg.id]
  key_name               = "task1-key"

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_security_group" "public_sg" {
  name   = "allow_http_public_sg"
  vpc_id = aws_vpc.myVpc.id
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_http_public_sg"
  }
}

resource "aws_instance" "app" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet[0].id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = "task1-key"
  tags = {
    Name = "app"
  }
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnet.*.id

  tags = {
    Name = "Load Balancer"
  }
}