   terraform {
  backend "s3" {
        bucket         = "tilshansanoj-s3" # REPLACE WITH YOUR BUCKET NAME
        key            = "05-file-structures/production/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "tf-state-locks"
        encrypt        = true
   }


   required_providers {
     aws = {
        source = "hashicorp/aws"
        version = "~> 3.0"
     }
   }
}

provider "aws" {
  region = "us-east-1"
}

variable "db_pass" {
  description = "password for the database"
  type = string
  sensitive = true
}



module "web_app_production" {
    source = "../web-app-module"

    # input variables
    bucket_prefix = "tilshansanoj-s3"
    domain = "production.wapp23.com"
    app_name = "web-app-production"
    environment_name = "production"
    create_dns_zone = true
    db_name       = "mydb_production"
    db_user       = "foo"
    db_pass =  var.db_pass
}





