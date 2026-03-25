#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Welcome to the Terraform AWS EC2 Web Server</h1><h2>Terraform Assignment - Lester John Abad</h2>" | tee /var/www/html/index.html
