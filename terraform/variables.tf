variable "access_key" {
  description = "aws access key"
}

variable "secret_key" {
  description = "aws secret key"
}

variable "region" {
  default = "us-east-1"
  description = "aws region"
}

variable "domain_name" {
  default = "www.mokbel.io"
  description = "the sub domain that traffic will be redirect to."
}

variable "redirected_domain_name" {
  default = "mokbel.io"
  description = "the domain that will redirected to domain_name"
}

variable "hosted_zone_id" {
  description = "hosted zone to add route 53 records to"
}

variable "ssl_cert_arn" {
  description = "ACM certificate ARN"
}