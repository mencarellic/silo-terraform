resource "aws_cloudfront_distribution" "public" {
  enabled             = true
  aliases             = ["www.${data.aws_route53_zone.public.name}"]
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.public.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  origin {
    origin_id   = aws_s3_bucket.artifacts.id
    domain_name = aws_s3_bucket.artifacts.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.public.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.artifacts.id
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  tags = {
    Name = "silo-web-app"
  }
}

resource "aws_cloudfront_distribution" "public-www-redirect" {
  enabled         = true
  aliases         = ["${data.aws_route53_zone.public.name}"]
  is_ipv6_enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.public.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  default_cache_behavior {
    target_origin_id       = aws_cloudfront_distribution.public.id
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.www-redirect.website_endpoint
    origin_id   = aws_cloudfront_distribution.public.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  tags = {
    Name = "silo-web-www-redirect"
  }
}

resource "aws_cloudfront_origin_access_identity" "public" {
  comment = "Public Origin Access Identity for Silo web app"
}
