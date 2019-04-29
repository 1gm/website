output "domain_website" {
    value = "${aws_s3_bucket.domain.website_endpoint}"
}

output "redirected_domain_website" {
    value = "${aws_s3_bucket.redirected-domain.website_endpoint}"
}