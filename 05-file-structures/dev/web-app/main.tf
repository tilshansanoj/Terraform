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

variable "db_pass" {
  description = "password for the database"
  type = string
  sensitive = true
}


module "web_app_dev" {
    source = "../web-app-module"

    # input variables
    bucket_prefix = "tilshansanoj-s3"
    domain = "dev.wapp23.com"
    app_name = "web-app-dev"
    environment_name = "dev"
    create_dns_zone = true
    db_name       = "mydb_dev"
    db_user       = "foo"
    db_pass =  var.db_pass
}






