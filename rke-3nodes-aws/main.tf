# Configure the Amazon AWS Provider
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# Getting the AMI id 
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# Setting the Security Groups
resource "aws_security_group" "allow-all" {
  name        = "rke-default-security-group"
  description = "rke"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
# Provisioning nodes on AWS
resource "aws_instance" "rke-master" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = var.instance_type
    key_name               = var.ssh_key_name
    vpc_security_group_ids = [aws_security_group.allow-all.id]
    user_data              = file("${path.module}/files/cloud-config.yaml")

    tags = {
      Name  = "rke-master"
    }

    # Waiting for Docker Deamon up and running 
    provisioner "remote-exec" {
      inline = [
        "until [ `sudo systemctl is-active docker` = 'active' ]; do sleep 1; done"
      ]
    }
    connection {
      type  = "ssh"
      host  = "${self.public_ip}"
      user  = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
}
resource "aws_instance" "rke-worker-1" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = var.instance_type
    key_name               = var.ssh_key_name
    vpc_security_group_ids = [aws_security_group.allow-all.id]
    user_data              = file("${path.module}/files/cloud-config.yaml")

    tags = {
      Name  = "rke-worker-1"
    }

    # Waiting for Docker Deamon up and running 
    provisioner "remote-exec" {
      inline = [
        "until [ `sudo systemctl is-active docker` = 'active' ]; do sleep 1; done"
      ]
    }
    connection {
      type  = "ssh"
       host  = "${self.public_ip}"
      user  = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
}
resource "aws_instance" "rke-worker-2" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = var.instance_type
    key_name               = var.ssh_key_name
    vpc_security_group_ids = [aws_security_group.allow-all.id]
    user_data              = file("${path.module}/files/cloud-config.yaml")

    tags = {
      Name  = "rke-worker-2"
    }

    # Waiting for Docker Deamon up and running 
    provisioner "remote-exec" {
      inline = [
        "until [ `sudo systemctl is-active docker` = 'active' ]; do sleep 1; done"
      ]
    }
    connection {
      type  = "ssh"
       host  = "${self.public_ip}"
      user  = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
}

# Installing Kubernetes on nodes

resource "rke_cluster" "cluster" {
  nodes {
      address = aws_instance.rke-master.public_ip
      user    = "ubuntu"
      role    = ["controlplane", "etcd"]
      ssh_key = file("~/.ssh/id_rsa")
      hostname_override = "master"
  }
  nodes {
      address = aws_instance.rke-worker-1.public_ip
      user    = "ubuntu"
      role    = ["worker"]
      ssh_key = file("~/.ssh/id_rsa")
      hostname_override = "worker1"
  }
  nodes {
      address = aws_instance.rke-worker-2.public_ip
      user    = "ubuntu"
      role    = ["worker"]
      ssh_key = file("~/.ssh/id_rsa")
      hostname_override = "worker2"
  }
#kubernetes_version = "v1.15.3-rancher1-1"
}

# Storing the Kube Config file
resource "local_file" "kube_cluster_yaml" {
  filename = "${path.module}/files/kube_config_cluster.yaml"
      role    = ["controlplane", "worker", "etcd"]
      ssh_key = file("~/Documents/Cyrille/ssh-key/id_rsa.pub")
  }
}

resource "local_file" "kube_cluster_yaml" {
  filename = file("${path.module}/files/kube_config_cluster.yml")
  content  = rke_cluster.cluster.kube_config_yaml
}

output "rke_cluster_yaml" {
  sensitive = true
  value = rke_cluster.cluster.rke_cluster_yaml
}

# Deploying and exposing an App on the K8S cluster
provider "kubernetes" {
  host     = rke_cluster.cluster.api_server_url
  username = rke_cluster.cluster.kube_admin_user

  client_certificate     = rke_cluster.cluster.client_cert
  client_key             = rke_cluster.cluster.client_key
  cluster_ca_certificate = rke_cluster.cluster.ca_crt
  # load_config_file =  "${path.module}/files/kube_config_cluster.yaml"
}

# Deploying the application on the K8S cluster
resource "kubernetes_deployment" "nginx-deployment" {
  metadata {
    name = "nginx-deployment"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
        image = "nginx:1.7.9"
        name  = "nginx"
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx-service" {
  metadata {
    name = "nginx-service"
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 80
      node_port   = 32123
      protocol    = "TCP"
    }
    type = "NodePort"
    external_ips = [
        aws_instance.rke-worker-1.public_ip,
        aws_instance.rke-worker-2.public_ip
      ]
  }
}




