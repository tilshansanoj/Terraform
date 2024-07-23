   terraform {
  backend "s3" {
        bucket         = "tilshansanoj-s3" # REPLACE WITH YOUR BUCKET NAME
        key            = "04-modules/web-app/terraform.tfstate"
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

variable "db_pass_1" {
  description = "password for the database"
  type = string
  sensitive = true
}

variable "db_pass_2" {
  description = "password for the database"
  type = string
  sensitive = true
}

module "web_app_1" {
    source = "../web-app-module"

    # input variables
    bucket_prefix = "tilshansanoj-s3"
    domain = "production.wapp23.com"
    app_name = "web-app-1"
    environment_name = "production"
    create_dns_zone = true
    db_name       = "mydb1"
    db_user       = "foo"
    db_pass =  var.db_pass_1
}


module "web_app_2" {
    source = "../web-app-module"

    # input variables
    bucket_prefix = "tilshansanoj-s3"
    domain = "dev.wapp23.com"
    app_name = "web-app-2"
    environment_name = "dev"
    create_dns_zone = true
    db_name       = "mydb2"
    db_user       = "faa"
    db_pass =  var.db_pass_2
}





