resource "aws_acm_certificate" "expense" {
  domain_name       = "*.shashikanth.online"
  validation_method = "DNS"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-expense-acm"
    }
  )
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.example.zone_id
}
