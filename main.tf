terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 3.27"
      }
    }

    required_version = ">= 0.14.9"
  }

  provider "aws" {
    profile = "default"
    region  = "us-east-2"
  }

  resource "aws_instance" "app_server" {
    ami           = "ami-0dd0ccab7e2801812"
    instance_type = "t2.micro"

    tags = {
      Name = "grupojh"
    }
  iam_instance_profile = "List_S3"
  user_data = <<EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install git -y
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
  #https://stackoverflow.com/questions/54415841/nodejs-not-installed-successfully-in-aws-ec2-inside-user-data
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install 7
  nvm install node -y
  node -e "console.log('Running Node.js ' + process.version)"
  #mkdir /tmp/proyecto #Comando para crear carpetas
  cd
  git clone https://github.com/abkunal/Chat-App-using-Socket.io.git
  git clone 
  cd /Chat-App-using-Socket.io
  pwd
  npm install
  npm install -g pm2
  pm2 start app.js
  sudo amazon-linux-extras list | grep nginx
  sudo amazon-linux-extras enable nginx1
  sudo yum clean metadata
  sudo yum -y install nginx
  nginx -v
  cd /etc/nginx
  sudo aws s3 cp s3://nginx-ceutec-infra/nginx.conf nginx.conf
  sudo service nginx restart
  EOF
  }
  resource "aws_security_group" "grupojh" {
          name = "sg_jh2"
  ingress {
          from_port = 80
          to_port = 80
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          }

      egress {
          from_port = 0
          to_port = 0
          protocol = "-1"
          cidr_blocks = ["0.0.0.0/0"]
      }
  }
  resource "aws_eip" "bar" {
    instance                  = aws_instance.app_server.id
  }



resource "aws_launch_template" "lt_jh2" {
    name_prefix   = "lt_jh2"
    image_id      = "ami-002068ed284fb165b"
    instance_type = "t2.micro"
    security_group_names = [aws_security_group.grupomw.name]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
    }
  }

    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "grupojh"
        }
      }
      tag_specifications {
        resource_type = "volume"
        tags = {
          Name = "grupojh"
        }
    }
        user_data = filebase64("${path.module}/Script_Inf_App/script.sh")
  }


  resource "aws_autoscaling_group" "ag_tarea_jh2" {
    availability_zones = ["us-east-2a"]
    desired_capacity   = 1
    max_size           = 1
    min_size           = 1

    launch_template {
      id      = aws_launch_template.lt_jh2.id
      version = "$Latest"
    }
  }

resource "aws_vpc" "vpc_jh" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw_jh2" {
  vpc_id = aws_vpc.vpc_mw.id
}


resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc_jh.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_lb" "lbjh2" {
  name               = "lbjh2"
  internal           = false
  load_balancer_type = "network"
  enable_deletion_protection = true
  subnets            = aws_subnet.public.*.id
  tags = {
    Environment = "production"
  }
}
