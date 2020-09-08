#
#
# provider creation
#
#
provider "aws" {
  region  = var.region
}

data "aws_caller_identity" "current" {}
#
#
# vpc creation
#
#
resource "aws_key_pair" "public_key" {
  key_name   = "${var.prefix}_public_key"
  public_key = file("~/.ssh/id_rsa.pub")
}
#
resource "aws_vpc" "vpc1" {
  cidr_block       = var.vpc1-cidr

  enable_dns_hostnames = true
  enable_dns_support =true
  instance_tenancy ="default"
  tags = {
    Name = "${var.prefix}-vpc1"
  }
}
/*
resource "aws_vpc" "vpc2" {
  cidr_block       = var.vpc2-cidr

  enable_dns_hostnames = true
  enable_dns_support =true
  instance_tenancy ="default"
  tags = {
    Name = "${var.prefix}-vpc2"
  }
}
*/
#
#
# subnet creation
#
#
resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.vpc1.id
  availability_zone = var.az-1a
  cidr_block        = var.subnet1a-cidr

  tags  = {
    Name = "${var.prefix}-public-1a"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id            = aws_vpc.vpc1.id
  availability_zone = var.az-1b
  cidr_block        = var.subnet1b-cidr

  tags  = {
    Name = "${var.prefix}-public_1b"
  }
}
/*
resource "aws_subnet" "public_2a" {
  vpc_id            = aws_vpc.vpc2.id
  availability_zone = var.az-2a
  cidr_block        = var.subnet2a-cidr

  tags  = {
    Name = "${var.prefix}-public-2a"
  }
}

resource "aws_subnet" "public_2b" {
  vpc_id            = aws_vpc.vpc2.id
  availability_zone = var.az-2b
  cidr_block        = var.subnet2b-cidr

  tags  = {
    Name = "${var.prefix}-public_2b"
  }
}
*/
#
#
# internet gateway creation
#
#
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "${var.prefix}-igw1"
  }
}
/*
resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "${var.prefix}-igw2"
  }
}
*/
#
#
# routing table creation
#
#
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "${var.prefix}-rt1"
  }
}

resource "aws_route_table_association" "rt1_public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rt1_public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.rt1.id
}
/*
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw2.id
  }

  tags = {
    Name = "${var.prefix}-rt2"
  }
}

resource "aws_route_table_association" "rt2_public_2a" {
  subnet_id      = aws_subnet.public_2a.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "rt2_public_2b" {
  subnet_id      = aws_subnet.public_2b.id
  route_table_id = aws_route_table.rt2.id
}
*/
#
#
# default security group creation for alb
#
#
resource "aws_default_security_group" "sg1_default" {
  vpc_id = aws_vpc.vpc1.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-sg1_default"
  }
}
/*
resource "aws_default_security_group" "sg2_default" {
  vpc_id = aws_vpc.vpc2.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-sg2_default"
  }
}
*/
#
#
# s3 creation for alb
#
#
resource "aws_s3_bucket" "images_bucket" {
  bucket = "skcc-${var.prefix}-images-bucket"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "${data.aws_caller_identity.current.account_id}" },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::skcc-${var.prefix}-images-bucket/*"
    }
  ]
}
POLICY

  lifecycle_rule {
    id      = "image"
    prefix  = ""
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_object" "images_object" {
  bucket = aws_s3_bucket.images_bucket.id
  key    = "images/perfect.jpg"
  source = "perfect.jpg"
  content_type = "image/jpg"
  acl    = "public-read"
}

#
#
# alb, alb target group, alb listener creation
#
#
resource "aws_alb" "alb1" {
    name = "${var.prefix}-alb1"
    internal = false
    security_groups = [aws_security_group.sg1_ec2.id]
    subnets = [
        aws_subnet.public_1a.id,
        aws_subnet.public_1b.id
    ]
    /*
    access_logs {
        bucket = aws_s3_bucket.images_bucket.id
        prefix = "frontend-alb1"
        enabled = true
    }
    */
    tags = {
        Name = "${var.prefix}-ALB1"
    }
    lifecycle { create_before_destroy = true }
}

resource "aws_alb_target_group" "frontend1" {
    name = "frontend1-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.vpc1.id
    health_check {
        interval = 30
        path = "/"
        healthy_threshold = 3
        unhealthy_threshold = 3
    }
    tags = { Name = "${var.prefix}-Frontend1 Target Group" }
}

resource "aws_alb_listener" "http1" {
    load_balancer_arn = aws_alb.alb1.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        target_group_arn = aws_alb_target_group.frontend1.arn
        type = "forward"
    }
}
/*
resource "aws_alb" "alb2" {
    name = "${var.prefix}-alb2"
    internal = false
    security_groups = [aws_security_group.sg2_ec2.id]
    subnets = [
        aws_subnet.public_2a.id,
        aws_subnet.public_2b.id
    ]
    tags = {
        Name = "${var.prefix}-ALB2"
    }
    lifecycle { create_before_destroy = true }
}
*/
/*
resource "aws_alb_target_group" "frontend2" {
    name = "frontend2-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.vpc2.id
    health_check {
        interval = 30
        path = "/"
        healthy_threshold = 3
        unhealthy_threshold = 3
    }
    tags = { Name = "${var.prefix}-Frontend2 Target Group" }
}

resource "aws_alb_listener" "http2" {
    load_balancer_arn = aws_alb.alb2.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        target_group_arn = aws_alb_target_group.frontend2.arn
        type = "forward"
    }
}
*/
#
#
# ec2 security group creation
#
#
resource "aws_security_group" "sg1_ec2" {
  name        = "allow_http_ssh"
  description = "Allow HTTP/SSH inbound connections"
  vpc_id = aws_vpc.vpc1.id

  //allow http 80 port from alb
  ingress { 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //allow ssh 22 port from my_ip(cloud9)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cloud9-cidr]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP/SSH Security Group"
  }
}
/*
resource "aws_security_group" "sg2_ec2" {
  name        = "allow_http_ssh"
  description = "Allow HTTP/SSH inbound connections"
  vpc_id = aws_vpc.vpc2.id

  //allow http 80 port from alb
  ingress { 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //allow ssh 22 port from my_ip(cloud9)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cloud9-cidr]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP/SSH Security Group"
  }
}
*/
#
#
# ec2 autoscaling configuration
#
#
resource "aws_iam_instance_profile" "web1_profile" {
  name = "web1_profile"
  role = aws_iam_role.WebAppRole.name
}

resource "aws_launch_configuration" "web1" {
  name_prefix = "${var.prefix}-autoscaling-web1-"
  iam_instance_profile = aws_iam_instance_profile.web1_profile.name

  image_id = var.amazon_linux
  instance_type = "t2.micro"
  key_name = aws_key_pair.public_key.key_name
  security_groups = [
    "${aws_security_group.sg1_ec2.id}",
    "${aws_default_security_group.sg1_default.id}",
  ]
  associate_public_ip_address = true
    
  lifecycle {
    create_before_destroy = true
  }
  user_data = <<EOF
    #!/bin/bash
    sudo yum install -y aws-cli
    sudo yum install -y git
    cd /home/ec2-user/
    sudo wget https://aws-codedeploy-${var.region}.s3.amazonaws.com/latest/codedeploy-agent.noarch.rpm
    sudo yum install -y ruby
    sudo yum -y install codedeploy-agent.noarch.rpm
    sudo yum -y install tomcat
    sudo ln -s /usr/sbin/tomcat /usr/sbin/tomcat7
    sudo mv /usr/share/tomcat /usr/share/tomcat7
    sudo systemctl start codedeploy-agent.service
	EOF
}
/*
resource "aws_launch_configuration" "web2" {
  name_prefix = "${var.prefix}-autoscaling-web2-"

  image_id = var.amazon_linux
  instance_type = "t2.micro"
  key_name = aws_key_pair.public_key.key_name
  security_groups = [
    "${aws_security_group.sg2_ec2.id}",
    "${aws_default_security_group.sg2_default.id}",
  ]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
  user_data = <<EOF
    #!/bin/bash
    sudo timedatectl set-timezone Asia/Seoul
    sudo yum install -y httpd
    sudo echo "Hostname : <b>$(hostname)</b><br>" >> /var/www/html/index.html
    sudo echo "Region : ${var.region}<br>" >> /var/www/html/index.html
    sudo echo "Create Time : $(date +%Y'-'%m'-'%d' '%H':'%M':'%S)<br>" >> /var/www/html/index.html
    sudo echo "<img src=http://${aws_s3_bucket.images_bucket.bucket_regional_domain_name}/${aws_s3_bucket_object.images_object.key}>" >> /var/www/html/index.html
    sudo systemctl enable httpd
    sudo systemctl start httpd
	EOF

}
*/
#
#
# autoscaling group creation
#
#
resource "aws_autoscaling_group" "web1" {
  name = "${aws_launch_configuration.web1.name}-asg"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 4

  health_check_type    = "ELB"
  #target_group_arns   = [aws_alb_target_group.frontend1.arn]

  launch_configuration = aws_launch_configuration.web1.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity="1Minute"

  vpc_zone_identifier  = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1b.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-web1-autoscaling"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg1-attachment" {
  autoscaling_group_name = aws_autoscaling_group.web1.id
  alb_target_group_arn   = aws_alb_target_group.frontend1.arn
}
/*
resource "aws_autoscaling_group" "web2" {
  name = "${aws_launch_configuration.web2.name}-asg"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 4

  health_check_type    = "ELB"
  #target_group_arns   = [aws_alb_target_group.frontend2.arn]

  launch_configuration = aws_launch_configuration.web2.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity="1Minute"

  vpc_zone_identifier  = [
    aws_subnet.public_2a.id,
    aws_subnet.public_2b.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-web2-autoscaling"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg2-attachment" {
  autoscaling_group_name = aws_autoscaling_group.web2.id
  alb_target_group_arn   = aws_alb_target_group.frontend2.arn
}
*/
#
#  autoscaling policy SK.LEE
#
resource "aws_autoscaling_policy" "web1_scaling_policy" {
  name                      = "${var.prefix}-web1-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.web1.name
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${aws_alb.alb1.arn_suffix}/${aws_alb_target_group.frontend1.arn_suffix}"
    }
    
    target_value = "1" #ALBRequestCountPerTarget Request 1
  }
}
#
/*
resource "aws_autoscaling_policy" "web2_scaling_policy" {
  name                      = "${var.prefix}-web2-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.web2.name
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${aws_alb.alb2.arn_suffix}/${aws_alb_target_group.frontend2.arn_suffix}"
    }
    
    target_value = "1" #ALBRequestCountPerTarget Request 1
  }
}
*/
/*

#
#
# vpc peering connection creation
#
#

resource "aws_vpc_peering_connection" "vpc_peer" {
  peer_vpc_id   = aws_vpc.vpc2.id
  vpc_id        = aws_vpc.vpc1.id
  auto_accept   = true
  
  tags = {
    Name = "${var.prefix} VPC Peering between vpc1 and vpc2"
  }
}

resource "aws_route" "vpc1_route" {
  route_table_id            = aws_route_table.rt1.id
  destination_cidr_block    = var.vpc2-cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}

resource "aws_route" "vpc2_route" {
  route_table_id            = aws_route_table.rt2.id
  destination_cidr_block    = var.vpc1-cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}

resource "aws_security_group_rule" "sg1_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.vpc2.cidr_block]
  security_group_id = aws_security_group.sg1_ec2.id
}

resource "aws_security_group_rule" "sg2_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.vpc1.cidr_block]
  security_group_id = aws_security_group.sg2_ec2.id
}
*/

#
#
# endpoint for s3 creation
#
#

# resource "aws_vpc_endpoint" "endpoint1" {
#   vpc_id       = aws_vpc.vpc1.id
#   service_name = "com.amazonaws.${var.region}.s3"
  
#   tags = {
#     Name = "${var.prefix} VPC1 endpoint"
#   }
# }

# resource "aws_vpc_endpoint" "endpoint2" {
#   vpc_id       = aws_vpc.vpc2.id
#   service_name = "com.amazonaws.${var.region}.s3"
  
#   tags = {
#     Name = "${var.prefix} VPC2 endpoint"
#   }
# }