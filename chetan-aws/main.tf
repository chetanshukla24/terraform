provider "aws" {

  region = "ap-southeast-2"
 }

#data "aws_availability_zones" "available" {}

resource "aws_subnet" "main" {
  vpc_id     = "vpc-1fd78d78"
  cidr_block = "172.31.50.0/24"
  #map_public_ip_on_launch = true

  tags = {
    Name = "default"
  }
}


resource "aws_security_group" "allow" {
  name        = "ssh-vms"
  description = "Allow SSH inbound traffic for virtual machines"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["155.143.35.110/32"]
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["155.143.35.110/32"]
    source_security_group_id = "${aws_security_group.elb.id}"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }
  }

resource "aws_security_group" "elb" {
  name        = "elb-example"
  description = "Allowing ELB traffic"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["155.143.35.110/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }
  } 

resource "aws_launch_configuration" "server" {
  name = "server"
  image_id = "ami-0b76c3b150c6b1423"
  #ami = "${var.image}"
  instance_type = "t2.micro"
  #subnet_id = "${aws_subnet.main.id}"
  associate_public_ip_address = "true"
  security_groups = ["${aws_security_group.allow.id}"]
  enable_monitoring = true


  user_data = <<-EOF
                #!/bin/bash
                echo "Hello Chetan"  > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF
                
  key_name = "terraform"
  

  lifecycle {
    create_before_destroy = true
  }

 }
 data "aws_availability_zones" "available" {}

  resource "aws_autoscaling_group" "example"{
    launch_configuration = "${aws_launch_configuration.server.id}"
    availability_zones   = ["${data.aws_availability_zones.available.names}"]
     min_size = 3
     max_size = 5
     #vpc_zone_identifier = ["${aws_subnet.main.id}"]
    vpc_zone_identifier = ["${aws_subnet.main.id}" , "subnet-57929030" , "subnet-58fec111"]
     load_balancers = ["${aws_elb.example.name}"]
     tag {
        key = "Name"
        value = "asg-group"
        propagate_at_launch = true
     }

  }


  resource "aws_elb"  "example" {
     name = "terraform-elb"
     availability_zones   = ["${data.aws_availability_zones.available.names}"]
     security_groups = ["${aws_security_group.elb.id}"]
     listener {
         lb_port = 80
         lb_protocol = "http"
         instance_port = "${var.server_port}"
         instance_protocol = "http"
     } 
    
      health_check {
          healthy_threshold  = 2
          unhealthy_threshold  = 4
          timeout = 10
          interval =  15
          target = "HTTP:${var.server_port}/"

         }    
    }
  
  
