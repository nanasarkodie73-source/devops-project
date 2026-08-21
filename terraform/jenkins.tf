data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}



resource "aws_security_group" "jenkins" {
  name        = "devops-jenkins-sg"
  description = "Security group for Jenkins EC2 server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-jenkins-sg"
  }
}




resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.small"

  subnet_id = aws_subnet.public_1.id

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]

  key_name = "NanaKeyPair"

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash

              dnf update -y

              dnf install -y java-21-amazon-corretto

              wget -O /etc/yum.repos.d/jenkins.repo \
                https://pkg.jenkins.io/redhat-stable/jenkins.repo

              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key

              dnf install -y jenkins

              systemctl enable jenkins
              systemctl start jenkins
              EOF

  tags = {
    Name = "devops-jenkins-server"
  }
}



output "jenkins_public_ip" {
  description = "Public IP address of Jenkins"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "Jenkins web interface"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}
