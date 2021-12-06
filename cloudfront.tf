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
    origin_id   = "frontend_static_content"
    domain_name = aws_s3_bucket.artifacts.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.public.cloudfront_access_identity_path
    }

  }

  default_cache_behavior {
    target_origin_id       = "frontend_static_content"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "allow-all"
  }

  tags = {
    Name = "silo-web-app"
  }
}

resource "aws_cloudfront_origin_access_identity" "public" {
  comment = "Public Origin Access Identity for Silo web app"
}
