# Provision AWS PostgreSQL Dev Database
provider "aws" {
  region = "af-south-1"
}
resource "aws_db_instance" "amazin_inc_db" {
  identifier            = "amazin_inc_postgres_rds_instance"
  allocated_storage     = 10
  #For autoscaling uncomment:
  #max_allocated_storage = 100

  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "11.8"
  port                  = 1433
  instance_class        = "db.t2.micro"
  username              = "dbadmin"
  password              = "myadminpassword"
}

terraform {
  backend "s3" {
    bucket = "amazin_inc_state_mngmt_2020_26_June"
    key = "stage/data-stores/postgresql/terraform.tfstate"
    region = "af-south-1"
    dynamodb_table = "amazin_inc_dynamodb_terraform_lock_state"
    encrypt = true
}
