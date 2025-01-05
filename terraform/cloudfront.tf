data "aws_cloudfront_response_headers_policy" "simpleCORS" {
  name = "Managed-CORS-With-Preflight"
}

resource "aws_cloudfront_distribution" "cf_dist" {
  enabled     = true
  price_class = "PriceClass_100"

  origin {
    domain_name = aws_elb.this.dns_name
    origin_id   = aws_elb.this.dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_elb.this.dns_name
    viewer_protocol_policy = "redirect-to-https"
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.simpleCORS.id  
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}