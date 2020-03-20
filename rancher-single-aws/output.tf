output "rancher-url" {
  value = ["https://${aws_instance.rancherserver.public_ip}"]
}