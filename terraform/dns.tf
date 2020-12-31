resource "aws_route53_zone" "primary" {
  name = var.domain_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.rankineuk_server.public_ip]
}

resource "aws_route53_record" "root-validation" {
  for_each = {
    for dvo in aws_acm_certificate.root.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = aws_route53_zone.primary.zone_id
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
}


resource "aws_acm_certificate" "root" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "root" {
  certificate_arn         = aws_acm_certificate.root.arn
  validation_record_fqdns = [for record in aws_route53_record.root-validation : record.fqdn]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.rankineuk_server.public_ip]
}

resource "aws_route53_record" "www-validation" {
  for_each = {
    for dvo in aws_acm_certificate.www.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = aws_route53_zone.primary.zone_id
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
}

resource "aws_acm_certificate" "www" {
  domain_name       = "www.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "www" {
  certificate_arn         = aws_acm_certificate.www.arn
  validation_record_fqdns = [for record in aws_route53_record.www-validation : record.fqdn]
}
