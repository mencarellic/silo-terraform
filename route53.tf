data "aws_route53_zone" "public" {
  name         = "carlo-mencarelli.xyz"
  private_zone = false
}

resource "aws_route53_record" "acm-validation" {
  for_each = {
    for dvo in aws_acm_certificate.public.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.public.zone_id
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "www.${data.aws_route53_zone.public.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.public.domain_name
    zone_id                = aws_cloudfront_distribution.public.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = data.aws_route53_zone.public.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.public-www-redirect.domain_name
    zone_id                = aws_cloudfront_distribution.public-www-redirect.hosted_zone_id
    evaluate_target_health = false
  }
}
