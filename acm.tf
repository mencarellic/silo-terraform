resource "aws_acm_certificate" "public" {
  domain_name       = data.aws_route53_zone.public.name
  validation_method = "DNS"
  subject_alternative_names = [
    "www.${data.aws_route53_zone.public.name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "public" {
  certificate_arn = aws_acm_certificate.public.arn
  validation_record_fqdns = [
    for record in aws_route53_record.acm-validation : record.fqdn
  ]
}
