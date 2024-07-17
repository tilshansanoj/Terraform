terraform {
  backend "s3" {
        bucket         = "tilshansanoj-s3" # REPLACE WITH YOUR BUCKET NAME
        key            = "03-variables/web-app/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "tf-state-locks"
        encrypt        = true
   }

   required_providers {
     aws = {
        source = "hashicorp/aws"
        version = "~> 3.0"
     }
   }
}

provider "aws" {
  region = var.region
}

#configuration of ec2 instance
resource "aws_instance" "instance_1" {
  ami = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.instances.name]
  user_data = <<-E0F
            #!/bin/bash
            echo "hello world 1" > index.html
            python3 -m http.server 8080 &
            E0F
}

#configuration of ec2 instance
resource "aws_instance" "instance_2" {
  ami = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.instances.name]
  user_data = <<-E0F
            #!/bin/bash
            echo "hello world 2" > index.html
            python3 -m http.server 8080 &
            E0F
}

#configuration of s3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket_prefix =  var.bucket_prefix
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_crypto_conf" {
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#use of default vpc
data "aws_vpc" "default_vpc" {
    default = true
}

#use of default subnet ids
data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

#creation of new security group
resource "aws_security_group" "instances" {
    name = "instance-security-group"  
}

#creation of new security group rule
resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

#configuration of load balancer listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn

  port = 80

  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      
      content_type = "text/plain"
      message_body = "404 : Page not found"
      status_code = 404
    }
  }
}

#specify target group for traffic
resource "aws_lb_target_group" "instances" {
  name = "instance-target-group"
  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default_vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

#attaching ec2 instance for the target groups
resource "aws_lb_target_group_attachment" "instance_1" {
    target_group_arn = aws_lb_target_group.instances.arn
    target_id = aws_instance.instance_1.id
    port = 8080  
}

#attaching ec2 instance for the target groups
resource "aws_lb_target_group_attachment" "instance_2" {
    target_group_arn = aws_lb_target_group.instances.arn
    target_id = aws_instance.instance_2.id
    port = 8080  
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = [ "*" ]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

#configuration of load balancer security group 
resource "aws_security_group" "aws_lb" {
  name = "alb-security-group"
}

#rule for inbound traffic for load balancer
resource "aws_security_group_rule" "alb_allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.aws_lb.id

  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

#rule for all outbound traffic for load balancer
resource "aws_security_group_rule" "alb_allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.aws_lb.id

  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
}

#configuration of load balancer
resource "aws_lb" "load_balancer" {
  name = "web-app-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default_subnet.ids
  security_groups = [ aws_security_group.aws_lb.id ]
}

resource "aws_db_instance" "db_instance" {
  allocated_storage   = 5
  storage_type        = "standard"
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.t3.micro"
  name                = var.db_name
  username            = var.db_user
  password            = var.db_pass
  skip_final_snapshot = true
}

