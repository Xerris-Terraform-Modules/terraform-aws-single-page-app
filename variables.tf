variable "domain_name" {
  description = "Domain name to set for applications"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource Tags if applicable"
}

variable "hosted_zone" {
  default     = ""
  description = "Hosted Zone for Route 53"
}

variable "acm_certificate_domain" {
  default     = null
  description = "ACM Certificate Domain"
}

variable "price_class" {
  default     = "PriceClass_100" 
  description = "CloudFront distribution price class"
}

variable "use_default_domain" {
  default     = false
  description = "Use CloudFront website address without Route53 and ACM certificate"
}

variable "cloudfront-aliases" {
  default     = []
  description = "Use CloudFront website address without Route53 and ACM certificate"
}
