variable "aws_access_key" {
  default     = "xxx"
  description = "Amazon AWS Access Key"
}

variable "aws_secret_key" {
  default     = "xxx"
  description = "Amazon AWS Secret Key"
}

variable "prefix" {
  default     = "myname"
  description = "Cluster Prefix - All resources created by Terraform have this prefix prepended to them"
}

variable "rancher_version" {
  default     = "latest"
  description = "Rancher Server Version"
}

variable "count_agent_all_nodes" {
  default     = "1"
  description = "Number of Agent All Designation Nodes"
}

variable "count_agent_etcd_nodes" {
  default     = "0"
  description = "Number of etcd Nodes"
}

variable "count_agent_controlplane_nodes" {
  default     = "0"
  description = "Number of K8s Control Plane Nodes"
}

variable "count_agent_worker_nodes" {
  default     = "0"
  description = "Number of Worker Nodes"
}

variable "admin_password" {
  default     = "admin"
  description = "Password to set for the admin account in Rancher"
}

variable "cluster_name" {
  default     = "default"
  description = "Kubernetes Cluster Name"
}

variable "region" {
  default     = "eu-west-3"
  description = "Amazon AWS Region for deployment"
}

variable "type" {
  default     = "t2.micro"
  description = "Amazon AWS Instance Type"
}

variable "docker_version_server" {
  default     = "18.09"
  description = "Docker Version to run on Rancher Server"
}

variable "docker_version_agent" {
  default     = "18.09"
  description = "Docker Version to run on Kubernetes Nodes"
}

variable "ssh_key_name" {
  default     = ""
  description = "Amazon AWS Key Pair Name"
}