terraform {
  backend "s3" {
    bucket = "mokbel.tfstate"
    key    = "www.mokbel.io.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
    region = "${var.region}"
}

module "s3" {
    source = "./modules/s3"
    domain_name = "${var.domain_name}"
    redirected_domain_name = "${var.redirected_domain_name}"
}

module "networking" {
    source = "./modules/networking"
    domain_name = "${var.domain_name}"
    domain_website = "${module.s3.domain_website}"
    redirected_domain_name = "${var.redirected_domain_name}"
    redirected_domain_website = "${module.s3.redirected_domain_website}"
    ssl_cert_arn = "${var.ssl_cert_arn}"
    hosted_zone_id = "${var.hosted_zone_id}"
}