   terraform {
  backend "s3" {
        bucket         = "tilshansanoj-s3" # REPLACE WITH YOUR BUCKET NAME
         key            = "05-file-structures/staging/terraform.tfstate"
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



module "web_app_2" {
    source = "../web-app-module"

    # input variables
    bucket_prefix = "tilshansanoj-s3"
    domain = "staging.wapp23.com"
    app_name = "web-app-staging"
    environment_name = "staging"
    create_dns_zone = true
    db_name       = "mydb_staging"
    db_user       = "faa"
    db_pass =  var.db_pass
}





