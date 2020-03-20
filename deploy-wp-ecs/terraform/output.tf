output "wordpress_endpoint" {
  value = "https://${aws_ecs_service.wordpress_app.cluster}"
}
output "database_endpoint" {
  value = "https://${aws_db_instance.wordpress_db.endpoint}"
}