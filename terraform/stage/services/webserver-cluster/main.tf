#Terraform Config File written in HCL language, 
a declarative language makes it easy to 
describe exactly the infrastructure you want to create.
To deploy, enter this commands in succession:
terraform init
terraform plan
terraform apply
#--------------------------------------------------------

#Single-line comments

/*
Multi-line Comments
*/ 


#We will provision on AWS(AWS is our provider of resources such as EC2 & RDS.)
#----------------------------------------------------------------------------
provider "aws" {
  profile = "default"
  region  = "${var.region}"
}

##Port number for server defined as a variable for use anywhere in the code 
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}
#Define local variables:
locals {
  http_port    = 80
  any_port     = 0
  any_protocol = -1
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

#Specifying an EC2 Instance provisioned with a machine image(AMI) from
#availability zone/region Africa(South Africa)
#------------------------------------------------
resource "aws_instance" "base" {
  ami           = "ami-0ec47ddb564d75b64"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sec_instance.id]  

  tags = {
    Name = "amazin_inc_ec2_instance"
  }
}


#The following resource specifies that this group allows 
#incoming TCP requests on port 8080
# from CIDR block 0.0.0.0/0 i.e. from any IP
#-------------------------------------------
resource "aws_security_group" "sec_instance" {
  name = "amazin_inc_sec_instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol 
    cidr_blocks = local.all_ips 
  }
}


#Create an auto-scaling group for our EC2 instance
#to ensure high-availability. Clusters of our servers are needed for redundancy.
#The first step in creating an ASG is to create a launch configuration,
#which specifies how to configure each EC2 Instance in the Auto-Scaling Group.
resource "aws_launch_configuration" "amazin_inc_launch_config" {
  image_id = "ami-0ec47ddb564d75b64"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]
}

#We need to query AWS about VPC information needed by the autoscaling group
#To query any provider(whether its AWS or Oracle or Azure) we use data blocks in Terraform
data "aws_vpc" "default" {
  default = true
}

#We will look up the subnets within this default VPC
data "aws_subnet_ids" "default" {
 vpc_id = data.aws_vpc.default.id
}


/*
Create a target group for the auto-scaling group which 
will health check your Instances by periodically
sending an HTTP request to each Instance and will consider the Instance
“healthy” only if the Instance returns a response that matches the
configured matcher (e.g., you can configure a matcher to look for a 200
OK response).
*/
resource "aws_lb_target_group" "amazin_target_group_asg" {
  name = "terraform-asg-example"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id 

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#The following code adds a listener rule that send requests
#that match any path to the target group that contains your ASG.
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    field  = "path-pattern"
    values = ["*"]
  }
  action {
    type = "forward"
    target_group_arn = 	aws_lb_target_group.amazin_target_group_asg.arn
  }
}


#Now Creating the aws_autoscaling_group resource:
resource "aws_autoscaling_group" "amazin_inc_asg" {
  launch_configuration = aws_launch_configuration.amazin_inc_launch_config.name

  #Specify minimum and maximum number of instances that 
  #auto-scaler should run 
  min_size = 2
  max_size = 4

  #Target group will send requests to EC2 instances given by auto-scaler
  target_group_arns = [aws_lb_target_group.amazin_target_group_asg.arn] 
  
  #Target group will perform robust "ELB" health checks
  # and it will instruct auto-scaling group to "put down" unhealthy instances
  health_check_type = "ELB"

  vpc_zone_identifier = data.aws_subnet_ids.default.ids   
  tag {
    key	                = "Name"
    value               = "terraform-auto-scaling-group-amazin"
    propagate_at_launch = true
    # Required when using a launch configuration with an auto scaling group.
    lifecycle {
      create_before_destroy = true
    }
}

#First Let us configure a Security Group for this Load Balancer
#So that it can talk to the public internet on TCP port 80(HTTP).
resource "aws_security_group" "sec_alb" {
  name = "terraform-example-alb"
  # Allow inbound HTTP Requests
  ingress {
    from_port   = local.http_port 
    to_port     = local.http_port 
    protocol    = local.tcp_protocol 
    cidr_blocks = local.all_ips 
  }

  # Allow all outbound requests
  egress {
    from_port = 0
    to_port = 0
    protocol = local.any_protocol 
    cidr_blocks = local.all_ips 
  }
}


#Deploying a Load Balancer(LB->Application Load Balancer
resource "aws_lb" "amazin_inc_load_balancer" {
  name = "terraform-lb-amazin-inc"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.sec_alb.id]
}


#The next step is to define a listener for this AWS Application Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.amazin_inc_load_balancer.arn
  port = local.http_port 
  protocol = "HTTP"
  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page Not Found!"
      status_code  = 404
    }
  }
}


output "alb_dns_name" {
  value = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

#Terraform state will be stored in an S3 bucket backend
#for better version control and consistency and to prevent chaos
terraform {
  backend "s3" {
    bucket = "amazin_inc_state_mngmt_2020_26_June"
    key    = "stage/webserver-cluster/terraform.tfstate"
    region = "${var.region}"
    dynamodb_table = "amazin_inc_dynamodb_terraform_lock_state"
    encrypt        = true 
  }
}

/*The following 'terraform_remote_state' data source below configures the web server
cluster code to read the state file from the same S3 bucket and folder
where the database stores its state.
*/
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "amazin_inc_state_mngmt_2020_26_June"
    key = "stage/data-stores/postgresql/terraform.tfstate"
    region = "${var.region}"
  }
}
