# **RDS with Terraform: MySQL Setup and Connection Guide**

This guide demonstrates how to set up an **AWS RDS MySQL instance** using **Terraform** and connect to it from a local machine or EC2 instance.

---

## **Prerequisites**

- **AWS Account**: Set up an AWS account if you don't have one.
- **AWS CLI**: Install and configure the AWS CLI with access to your AWS account.
- **Terraform**: Install Terraform on your local machine or EC2 instance.
- **MySQL Client**: Install MySQL client (or MySQL Workbench) to connect to the RDS instance.

---

## **Step 1: Install Terraform**

To begin, install Terraform on your local machine.

- **MacOS**: You can install Terraform via Homebrew:
  
  ```bash
  brew install terraform
  ```

- **Windows/Linux**: Follow the instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli) for your platform.

---

## **Step 2: Set Up AWS Account and IAM Permissions**

- Make sure your AWS credentials are configured using the AWS CLI:
  
  ```bash
  aws configure
  ```

- You should have IAM credentials with sufficient permissions for creating RDS instances.

---

## **Step 3: Create Terraform Configuration Files**

1. Go to the automated-aws-rds-deployment-with-terraform directory for your Terraform project:

   ```bash
   cd automated-aws-rds-deployment-with-terraform
   ```

2. Create a `main.tf` file for your Terraform configuration:

   ```hcl
   provider "aws" {
     region = "ap-south-1"  # Use your desired AWS region
   }

   resource "aws_db_instance" "mydb" {
     identifier        = "terraform-mysql-db"
     engine            = "mysql"
     instance_class    = "db.t2.micro"   # Use the free-tier instance
     allocated_storage = 20               # 20 GB storage
     storage_type      = "gp2"            # General Purpose SSD
     username          = "admin"
     password          = "your_password"
     db_name           = "mydatabase"
     skip_final_snapshot = true

     vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]

     publicly_accessible = true

     tags = {
       Name = "MyRDSInstance"
     }
   }

   resource "aws_security_group" "rds_sg" {
     name        = "rds-security-group"
     description = "Allow MySQL access"
     ingress {
       from_port   = 3306
       to_port     = 3306
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs (use your local IP for better security)
     }
   }
   ```

---

## **Step 4: Initialize Terraform and Apply Configuration**

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Apply the Terraform configuration to create the RDS instance:

   ```bash
   terraform apply
   ```

   - Review the proposed changes and type `yes` to confirm.
   - This will create the RDS instance and the necessary security group.

---

## **Step 5: Connect to the RDS Instance**

### **Option 1: Connect from Local Machine (if RDS is publicly accessible)**

1. **Find the RDS Endpoint**:
   - In the AWS Management Console, go to **RDS** > **Databases** > Select your RDS instance.
   - Copy the **endpoint** (without `http://` or `https://`) under the **Connectivity & Security** tab.

2. **Connect Using MySQL Client**:

   ```bash
   mysql -h <RDS-endpoint> -P 3306 -u admin -p
   ```

   - Replace `<RDS-endpoint>` with the actual endpoint from the previous step.

### **Option 2: Connect from EC2 Instance**

If your RDS instance is **inside a VPC** and **not publicly accessible**, you need to connect from an **EC2 instance** in the same VPC.

1. **Launch EC2**: Launch an EC2 instance in the **same VPC** as the RDS instance.
2. **Connect to EC2** via SSH:

   ```bash
   ssh -i <your-key.pem> ec2-user@<EC2-public-IP>
   ```

3. **Install MySQL Client on EC2** (if not already installed):

   ```bash
   sudo yum install mysql -y
   ```

4. **Connect to RDS from EC2**:

   ```bash
   mysql -h <RDS-endpoint> -P 3306 -u admin -p
   ```

---

## **Troubleshooting**

### **1. Connection from Local Machine**

If you're unable to connect to RDS from your local machine, verify the following:
- **RDS is publicly accessible**: Check if the RDS instance is set to **Publicly Accessible** in the AWS Console.
- **Security Group Settings**: Ensure that the security group associated with RDS allows inbound connections on port `3306` from your local machine's IP.
- **Network Blockage**: Ensure that your local firewall or network is not blocking outgoing connections on port `3306`.
- **Endpoint Format**: Ensure you're using the correct RDS endpoint and port (`3306`).

### **2. Connection from EC2**

If you're connecting from an EC2 instance:
- **Security Group**: The RDS security group should allow traffic on port `3306` from the EC2 instance's security group.
- **VPC Configuration**: Ensure that the EC2 instance is in the same VPC and subnet (or has the appropriate route to connect to the RDS).

---

## **main.tf File Breakdown**

### **Provider Block**

```hcl
provider "aws" {
  region = "ap-south-1"  # Use your desired AWS region
}
```

- **provider "aws"**: Specifies the AWS provider to interact with AWS services.
- **region = "ap-south-1"**: The region where your resources will be created. `ap-south-1` is the Asia Pacific (Mumbai) region. You can change it based on your preference.

---

### **RDS Instance Resource**

```hcl
resource "aws_db_instance" "mydb" {
  identifier        = "terraform-mysql-db"
  engine            = "mysql"
  instance_class    = "db.t2.micro"   # Use the free-tier instance
  allocated_storage = 20               # 20 GB storage
  storage_type      = "gp2"            # General Purpose SSD
  username          = "admin"
  password          = "your_password"
  db_name           = "mydatabase"
  skip_final_snapshot = true
```

- **resource "aws_db_instance" "mydb"**: Defines the RDS MySQL instance.
- **identifier**: The unique identifier for the RDS instance.
- **engine**: Specifies the database engine (`mysql`).
- **instance_class**: Defines the type of instance (`db.t2.micro` for free-tier).
- **allocated_storage**: Amount of storage allocated to the instance (20 GB).
- **storage_type**: The storage type (`gp2` for General Purpose SSD).
- **username**: The master username for the database (`admin`).
- **password**: The password for the master user (`your_password`).
- **db_name**: The name of the database created (`mydatabase`).
- **skip_final_snapshot**: Skips taking a final snapshot when the instance is deleted.

---

### **Security Group Resource**

```hcl
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow MySQL access"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs (use your local IP for better security)
  }
}
```

- **resource "aws_security_group" "rds_sg"**: Defines a security group for the RDS instance.
- **ingress**: Allows inbound traffic on port `3306` (MySQL) from the specified IP range (`0.0.0.0/0` means open to all, but you should restrict this to your IP or network).

---