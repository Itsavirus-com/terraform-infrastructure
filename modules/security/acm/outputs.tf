output "certificate_arn" {
  description = "ARN of the certificate"
  value       = var.create_certificate ? aws_acm_certificate.certificate[0].arn : (var.existing_certificate_domain != "" ? data.aws_acm_certificate.existing[0].arn : "")
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = var.create_certificate ? aws_acm_certificate.certificate[0].domain_name : (var.existing_certificate_domain != "" ? data.aws_acm_certificate.existing[0].domain : "")
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = var.create_certificate ? aws_acm_certificate.certificate[0].status : (var.existing_certificate_domain != "" ? data.aws_acm_certificate.existing[0].status : "")
}

output "certificate_subject_alternative_names" {
  description = "Subject alternative names of the certificate"
  value       = var.create_certificate ? var.subject_alternative_names : []
}

output "validation_record_fqdns" {
  description = "List of FQDNs built using the domain name and validation_record_name"
  value       = var.create_certificate && var.validation_method == "DNS" ? [for record in aws_route53_record.certificate_validation : record.fqdn] : []
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID used for validation"
  value       = var.create_certificate && var.route53_zone_name != "" ? data.aws_route53_zone.domain[0].zone_id : ""
} 