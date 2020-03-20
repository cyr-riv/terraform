variable "aws_access_key" {
  default     = "xxx"
  description = "Amazon AWS Access Key"
}

variable "aws_secret_key" {
  default     = "xxx"
  description = "Amazon AWS Secret Key"
}
variable "region" {
  default     = "eu-west-3"
  description = "Amazon AWS Region for deployment"
}
variable "region_az" {
  default     = "eu-west-3a"
  description = "Amazon AWS Availability in the Region"
}
variable "vpc_id" {
  default     = "xxx"
  description = "Amazon AWS VPC id"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Amazon AWS Instance Type"
}
variable "ssh_key_name" {
  default     = ""
  description = "Amazon AWS Key Pair Name"
}
variable "db_size" {
  default     = 20
  description = "Amazon AWS RDS storage"
}
variable "db_instance" {
  default     = "db.t2.micro"
  description = "Amazon AWS RDS instance"
}
variable "db_name" {
  default     = "wordpress"
  description = "Amazon AWS RDS DB name"
}
variable "db_username" {
  default     = "wordpress"
  description = "Amazon AWS RDS DB username"
}
variable "db_password" {
  default     = "m0t2Passe"
  description = "Amazon AWS RDS DB password"
}