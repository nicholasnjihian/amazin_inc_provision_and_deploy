#REQUIREMENTS:
#-------------
#1. The IAM User will need permissions to create S3 buckets and DynamoDB tables.


#DESCRIPTION:
#------------
/*
This file describes how terraform will provision an s3 bucket to
act as our version control for our state file 'terraform.tfstate file'
For a personal project, storing state locally in a single terraform.tfstate file on your computer works just fine.
But if you want to use Terraform as a team on a real product, you run into
several problems:
. Shared storage for state files
      To be able to use Terraform to update your infrastructure, each of your
      team members needs access to the same Terraform state files. That
      means you need to store those files in a shared location.
. Locking state files
      As soon as data is shared, you run into a new problem: locking.
      Without locking, if two team members are running Terraform at the
      same time, you can run into race conditions as multiple Terraform
      processes make concurrent updates to the state files, leading to
      conflicts, data loss, and state file corruption.
. Also, importantly, Terraform unfortunately stores any secrets that it reads, even from 
  environment variables, in plain text in the state files. 
  For instance, if you pass it as an argument to a Terraform resource, such as aws_db_instance,   that secret will be stored in the Terraform state file, in plain text.
*/

#CODE:
#-------
provider "aws" {
  region = af-south-1
}


#I am using Amazon S3 (Simple Storage Service), which is Amazon’s managed file store
#as Terraform's remote backend to store state. 
#There are other options, though,like Hashicorp's Terraform Enterprise

resource "aws_s3_bucket" "terraform_state" {
  #The bucket name has to be a very unique name as per AWS preconditions,
  #i.e, globally unique among all AWS customers. 
  bucket = "amazin_inc_state_mngmt_2020_26_June" 

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}



#AWS S3 supports locking via DynamoDB.
#DynamoDB is Amazon’s distributed key–value store.
#It supports consistent reads and conditional writes, 
#all ingredients for a distributed lock system.
#To use DynamoDB for locking with Terraform, 
#you must create a table that 
#has a primary key called LockID (with this exact spelling and capitalization).
resource "aws_dynamodb_table" "terraform_locks" {
  name = "amazin_inc_dynamodb_terraform_lock_state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
#Terraform state will be stored in an S3 bucket backend
#for better version control and consistency and to prevent chaos
terraform {
  backend "s3" {
    bucket = "amazin_inc_state_mngmt_2020_26_June"
    key    = "global/s3/terraform.tfstate"
    region = "af-south-1"
    dynamodb_table = "amazin_inc_dynamodb_terraform_lock_state"
    encrypt        = true
  }
}
