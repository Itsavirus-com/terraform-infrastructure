variable "create_certificate" {
  description = "Create a new ACM certificate"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of subject alternative names (SANs) for the certificate"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Method to use for domain validation"
  type        = string
  default     = "DNS"
  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "Validation method must be either DNS or EMAIL."
  }
}

variable "route53_zone_name" {
  description = "Route53 hosted zone name for DNS validation (leave empty to skip automatic validation)"
  type        = string
  default     = ""
}

variable "wait_for_validation" {
  description = "Wait for certificate validation to complete"
  type        = bool
  default     = true
}

variable "validation_timeout" {
  description = "Timeout for certificate validation"
  type        = string
  default     = "5m"
}

variable "certificate_transparency_logging_preference" {
  description = "Certificate transparency logging preference"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.certificate_transparency_logging_preference)
    error_message = "Certificate transparency logging preference must be either ENABLED or DISABLED."
  }
}

# For importing existing certificates
variable "existing_certificate_domain" {
  description = "Domain name of existing certificate to import (used when create_certificate is false)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
} 