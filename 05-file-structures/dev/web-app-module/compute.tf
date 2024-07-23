
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


