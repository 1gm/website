// CLOUDFRONT
resource "aws_cloudfront_distribution" "redirected_distribution" {
  comment = "${var.redirected_domain_name} -> ${var.domain_name}"

  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    domain_name = "${var.redirected_domain_website}"
    origin_id   = "${var.redirected_domain_name}"
  }

  enabled             = true
  default_root_object = "index.html"
  wait_for_deployment = false 
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.redirected_domain_name}"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["${var.redirected_domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.ssl_cert_arn}"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "domain_distribution" {
  comment = "${var.domain_name} -> s3 bucket"

  // origin is where CloudFront gets its content from.
  origin {
    // We need to set up a "custom" origin because otherwise CloudFront won't
    // redirect traffic from the root domain to the www domain, that is from
    // runatlantis.io to www.runatlantis.io.
    custom_origin_config {
      // These are all the defaults.
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    // Here we're using our S3 bucket's URL!
    domain_name = "${var.domain_website}"
    // This can be any name to identify this origin.
    origin_id   = "${var.domain_name}"
  }

  enabled             = true
  default_root_object = "index.html"
  wait_for_deployment = false 
  
  // All values are defaults from the AWS console.
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    // This needs to match the `origin_id` above.
    target_origin_id       = "${var.domain_name}"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  // Here we're ensuring we can hit this distribution using www.runatlantis.io
  // rather than the domain name CloudFront gives us.
  aliases = ["${var.domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Here's where our certificate is loaded in!
  viewer_certificate {
    acm_certificate_arn = "${var.ssl_cert_arn}"
    ssl_support_method  = "sni-only"
  }
}

// ROUTE53


// We want AWS to host our zone so its nameservers can point to our CloudFront
// distribution.
# resource "aws_route53_zone" "zone" {
#   name = "${var.redirected_domain_name}"
# }

// This Route53 record will point at our CloudFront distribution.
resource "aws_route53_record" "domain" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.domain_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.domain_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirected" {
  zone_id = "${var.hosted_zone_id}"

  // NOTE: name is blank here.
  name = ""
  type = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.redirected_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirected_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}