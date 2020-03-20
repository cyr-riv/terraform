# DevOps Tech Test

The goal is to setup a Wordpress container on an ECS cluster with tools like Terraform, Packer and Ansible.

## Project Description

Each tool covers a key deployment stage such as:

* Terraform: provision and configure the AWS infrastructure components,
* Packer: build and store the artifact for deploying the application,
* Ansible: setup and configure the application prior his containerization.

### Installing and configuring the setup

The project contains 3 folders:

* folder ***ansible*** contains the *playbook.yml* file which describe the configuration of app components: nginx, php-fpm, supervisord and wordpress,
* folder ***packer*** contains the *wordpress.json* file which detail the build of the Docker image configured with Ansible. Then the just built image is pushed to AWS ECR repository.
* folder ***terraform*** contains the *main.tf* file which describe all resources provisoned for the project, such as:

  * Network rules: security groups, subnets,
  * IAM role and policy,
  * ECR repository
  * ECS cluster, task definition, service
  * RDS MySQL.

### Running the project

#### Prerequisites

You need to install on your local machine: Packer, Ansible and Terraform.
You need to get an AWS account (free tier subscription).

#### Installation

First, you have to run Terraform templates as follows:

1. Complete the AWS values in *terraform/terraform.tfvars* file
2. Deploy the infrastructure by executing the commands: `terraform init`, `terraform plan`, `terraform apply` from inside the *terraform* folder.

Then, once completed you can build the wordpress application (Docker image):

1. Update values in *ansible/group_vars/all* file, for variables *db_name*, *db_user*, *db_password* and *db_host* with the AWS RDS endpoint name.
2. Update values in *packer/wordpress.json* file, for variables *aws_access_key*, *aws_secret_key* and *aws_ecr_repository* with the AWS ECR endpoint name.
3. Initiate packer and upload the Docker image to AWS ECR by running the command: `packer build wordpress.json` from inside the *packer* folder.

### Sequencing tools interaction

Terraform has created all infrastructure components enumerated above. The ECS service is awaiting for the image (build by Packer) stored in the ECR and then run the container. The ECS task definition exposes a public ip (Fargate) for accessing the Wordpress app.
Once the ECS cluster up and running, Wordpress container will connect the MySQL DB provided, externally, by RDS.

## Project challenges

What problems did you encounter ?

* Ansible dependencies for CentOS7, including supervisord tool.
* To get a public ip for exposing the container application, the ECS Task Definition must of type FARGATE. This mode enforces the settings of several AWS components such as cpu, mem, arn, network settings...

## Next steps

### Project resilience

The project setup works fine for a development sandbox because some steps require manual operations for updating credentials. In particular, passwords appear in clear text rather than encoded or hashed. 
Also, to automate the CD tools chain with *Zero-Touch Deployment* aspect, it is judicious to use an orchestrator solution which will take care to sequence all manual ops with a secret management tool (e.g. Vault) for managing credentials.

### Improving the architecture

Some recommendations for making a production-ready infrastructure:

* HA/DR: set a Load Balancer for the ECS service,
* Security: secure communications (Wordpress/RDS) by configuring SSL terminations,
* Monitoring: use a AWS service (CloudWatch) or set your own solution (e.g. Prometheus/Grafana).
* Logging: set a tool for collecting, aggreging, displaying the logs from the containers and DB (e.g. ELK stack). 
* Container Management Platform: use Kubernetes for orchestrating and managing the containers by using the AWS EKS service. Or set your own K8S cluster on AWS EC2 like describe in my project [**rke-3nodes-aws**](https://github.com/cyr-riv/terraform/tree/master/rke-3nodes-aws).