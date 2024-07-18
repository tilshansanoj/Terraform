# General Variables

variable "region" {
  description = "Default region for provider"
  type = string
  default = "us-east-1"
}

variable "envrinoment_name" {
    description = "Deployment environment (dev/staging/production)"
    type = string
    default = "dev"  
}

variable "app_name" {
  description = "Name of the web application"
  type        = string
  default     = "web-app"
}

# EC2 variables
variable "ami" {
  description = "Amazon machine image for ec2 instance"
  type = string
  default     = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

# S3 bucket variables

variable "bucket_prefix" {
  description = "prefix of the S3 bucket for the web application"
  type = string
}

# RDS variables

variable "db_name" {
  description = "Name of the database"
  type =  string
}

variable "db_user" {
  description = "Username for the database"
  type = string
}

variable "db_pass" {
  description = "Password for the database"
  type = string
  sensitive = true
}