# VPC Module ###############
module "vpc" {
source  = "terraform-aws-modules/vpc/aws"
version = "6.6.0"

name = "Terraform_VPC"

  cidr = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  # To assign Auto-assigned IP address to EC2 instances in public subnets
  map_public_ip_on_launch = true 
  
  # DNS options are checked automatically when creating VPC manually
  # Required for common configurations
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project = "Terraform Assignment VPC"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}


resource "aws_instance" "web_server1" {
  ami           = "ami-05024c2628f651b80"
  instance_type = "t2.micro"
  subnet_id = module.vpc.public_subnets[0] #get the first public subnet from the VPC module
  vpc_security_group_ids = [aws_security_group.Webserver_SG.id] #attach the Webserver_SG to the EC2 instance
  
  user_data     = file("${path.module}/install_httpd.sh") #execute the install_httpd.sh script to install Apache HTTP Server on the EC2 instance

  tags = {
    Name = var.instance1_name
  }
}

resource "aws_instance" "web_server2" {
  ami           = "ami-05024c2628f651b80"
  instance_type = "t2.micro"
  subnet_id = module.vpc.public_subnets[1] #get the second public subnet from the VPC module
  vpc_security_group_ids = [aws_security_group.Webserver_SG.id] #attach the Webserver_SG to the EC2 instance
  
  user_data     = file("${path.module}/install_httpd.sh") #execute the install_httpd.sh script to install Apache HTTP Server on the EC2 instance

  tags = {
    Name = var.instance2_name
  }
}

# WebServers SG ###############

resource "aws_security_group" "Webserver_SG" {
  name        = "Webserver_SG"
  description = "allow http to anywhere"
  vpc_id      = module.vpc.vpc_id #get the VPC ID from the VPC module

  # Ingress rule to allow HTTP traffic from anywhere
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Webserver_SG"
  }
}


# RDS SubnetGroup ###############

resource "aws_db_subnet_group" "RDSSubnetGroup" {
  name       = "dbsubnetgroup"
  # The subnet IDs for the RDS subnet group are obtained from the private subnets of the VPC module
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tags = {
    Name = "DB subnet group"
  }
}


# RDS-DB Security Group ###############

resource "aws_security_group" "RDS_DB_SG" {
  name        = "RDS_DB_SG"
  description = "allow port 3306 to Webserver_SG"
  vpc_id      = module.vpc.vpc_id #get the VPC ID from the VPC module
  tags = {
    Name = "RDS_DB_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "RDS_DB_SG" {
  security_group_id = aws_security_group.RDS_DB_SG.id
  # The referenced security group ID is obtained from the Webserver_SG security group, 
  # allowing traffic from the Webserver_SG to the RDS_DB_SG on port 3306 (MySQL)
  referenced_security_group_id = aws_security_group.Webserver_SG.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

# RDS MySQL Database Instance ###############
resource "aws_db_instance" "RDS_MySQL" {
  allocated_storage    = 100
  db_name              = "MySQLDB"
  engine               = "mysql"
  engine_version       = "8.4.7"
  instance_class       = "db.t3.micro"
  username             = "dbadmin"
  password             = "ljabadpw"
  vpc_security_group_ids = [aws_security_group.RDS_DB_SG.id] #attach the RDS_DB_SG to the RDS MySQL database instance
  db_subnet_group_name = aws_db_subnet_group.RDSSubnetGroup.name #get the name of the RDS subnet group created earlier
  skip_final_snapshot  = true # Skip the final snapshot when deleting the RDS instance

}

