resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "rankine.uk"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.rankineuk_server.public_ip]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.rankine.uk"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.rankineuk_server.public_ip]
}
