provider "aws" {
}

resource "random_id" "id" {
  byte_length = 8
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = replace(module.apigw_origin.api_endpoint, "/^https?://([^/]*).*/", "$1")
    origin_id   = "apigw"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "apigw"

    default_ttl = 0
    min_ttl     = 0
    max_ttl     = 0

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "apigw"


    default_ttl = 0
    min_ttl     = 0
    max_ttl     = 0

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    path_pattern     = "/api_rewrite/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "apigw"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrite_uri.arn
    }


    default_ttl = 0
    min_ttl     = 0
    max_ttl     = 0

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "https-only"
  }
  price_class     = "PriceClass_100"
  is_ipv6_enabled = true
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_function" "rewrite_uri" {
  name    = "rewrite-request-${random_id.id.hex}"
  runtime = "cloudfront-js-1.0"
  code    = <<EOF
function handler(event) {
	var request = event.request;
	request.uri = request.uri.replace(/^\/[^/]*\//, "/");
	return request;
}
EOF
}

output "domain" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

module "apigw_origin" {
  source = "./modules/apigw_origin"
}

