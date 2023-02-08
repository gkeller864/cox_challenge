/*=========================================
                AWS Route53
==========================================*/

resource "aws_route53_zone" "main" {
  name         = "example.com"
}

# Route53 record for acm validation
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# Route53 record for ALB
resource "aws_route53_record" "main" {
  zone_id         = aws_route53_zone.main.zone_id
  name            = "${var.route_53_name}.example.com"
  type            = "CNAME"
  ttl             = 60
  allow_overwrite = true
  records         = [var.record]
}

# ACM certificate for ALB HTTPS
resource "aws_acm_certificate" "main" {
  domain_name       = "${var.route_53_name}.example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
 
# ACM certificate validation
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
