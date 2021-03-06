#These outputs provide the web cluster with the address & port
#required to enable communication with the database from the web server cluster

output "address" {
  value = aws_db_instance.amazin_inc_db.address
  description = "Connect to the database at this endpoint"
}
output "port" {
  value = aws_db_instance.amazin_inc_db.port
  description = "The port the database is listening on"
}
