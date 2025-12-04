# Data source to get the Route53 hosted zone
data "aws_route53_zone" "domain" {
  count = var.create_certificate && var.route53_zone_name != "" ? 1 : 0

  name         = var.route53_zone_name
  private_zone = false
}

# ACM Certificate
resource "aws_acm_certificate" "certificate" {
  count = var.create_certificate ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method

  dynamic "options" {
    for_each = var.certificate_transparency_logging_preference != null ? [1] : []
    content {
      certificate_transparency_logging_preference = var.certificate_transparency_logging_preference
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.domain_name}-certificate"
  })
}

# Route53 validation records
resource "aws_route53_record" "certificate_validation" {
  for_each = var.create_certificate && var.validation_method == "DNS" && var.route53_zone_name != "" ? {
    for dvo in aws_acm_certificate.certificate[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain[0].zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "certificate_validation" {
  count = var.create_certificate && var.validation_method == "DNS" && var.route53_zone_name != "" && var.wait_for_validation ? 1 : 0

  certificate_arn         = aws_acm_certificate.certificate[0].arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]

  timeouts {
    create = var.validation_timeout
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Import existing certificate (if not creating new one)
data "aws_acm_certificate" "existing" {
  count = !var.create_certificate && var.existing_certificate_domain != "" ? 1 : 0

  domain      = var.existing_certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
} 