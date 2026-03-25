
# output variable to display the public IP address of the first EC2 instance
output "instance_public_ip1" { 

  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server1.public_ip
}

# output variable to display the public IP address of the second EC2 instance
output "instance_public_ip2" { 
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server2.public_ip
}

# output variable to display the endpoint of the RDS MySQL database instance
output "RDS_MySQL_Endpoint" { 
  description = "Endpoint of the MySQL Database"
  value       = aws_db_instance.RDS_MySQL.endpoint
}
