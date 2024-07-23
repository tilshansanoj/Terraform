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
