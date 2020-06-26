variable "region" {
  type = "string"
  description = "The AWS region."
  default = "af-south-1"
}

#this variable does not have a default . This is intentional. 
#You should not store your database password or any sensitive information in
#plain text. Instead, you’ll set this variable using an environment variable.
#i.e., TF_VAR_db_password
#For example: `$ export TF_VAR_db_password="(YOUR_DB_PASSWORD)"`
variable "db_password" {
  description = "The password for the database"
  type = string
}
