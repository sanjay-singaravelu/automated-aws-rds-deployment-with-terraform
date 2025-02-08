# Configure the AWS provider
provider "aws" {
  region = "ap-south-1"  # Set to the region of your choice
}

# Create an RDS instance
resource "aws_db_instance" "mydb" {
  allocated_storage    = 20 # 20 GB of storage
  storage_type         = "gp2"  # General purpose SSD storage
  engine               = "mysql"  # Choose MySQL, PostgreSQL, etc.
  engine_version       = "8.0.40"   # MySQL version
  instance_class       = "db.t3.micro"  # Free tier eligible instance
  db_name              = "mydatabase"  # Database name
  username             = "admin"  # Master username
  password             = "yourpassword123"
  backup_retention_period = 7 # 7 days of backups
  multi_az             = false  # No multi-AZ for free tier
  publicly_accessible  = true  # Make it publicly accessible for testing (be careful!)
  tags = {
    Name = "MyRDSInstance"
  }

}
