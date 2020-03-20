output "rke-master" {
  value = "https://${aws_instance.rke-master.public_ip}"
}
output "rke-worker-1" {
  value = "https://${aws_instance.rke-worker-1.public_ip}"
}
output "rke-worker-2" {
  value = "https://${aws_instance.rke-worker-2.public_ip}"
}

output "deploy-nginx" {
  value = "http://${aws_instance.rke-worker-1.public_ip}:${kubernetes_service.nginx-service.spec[0].port[0].node_port}"
}
