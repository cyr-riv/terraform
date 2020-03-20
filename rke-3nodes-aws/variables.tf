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

variable "instance_type" {
  default     = "t2.micro"
  description = "Amazon AWS Instance Type"
}
variable "ssh_key_name" {
  default     = ""
  description = "Amazon AWS Key Pair Name"
}