provider "aws" {
  region = "us-east-1"
  alias  = "aws_cloudfront"
}

locals {
  default_certs = var.use_default_domain ? ["default"] : []
  acm_certs     = var.use_default_domain ? [] : ["acm"]
  domain_name   = var.use_default_domain ? "" : var.domain_name
  local_aliases = var.cloudfront-aliases == [] ? [] : formatlist("%s.${var.hosted_zone}", var.cloudfront-aliases)
 
}

data "aws_acm_certificate" "acm_cert" {
  count    = var.use_default_domain ? 0 : 1
  domain   = coalesce(var.acm_certificate_domain, var.hosted_zone)
  provider = aws.aws_cloudfront
  //CloudFront uses certificates from US-EAST-1 region only
  statuses = [
    "ISSUED",
  ]
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.domain_name}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.domain_name
  acl    = "private"
  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
  
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["x-amz-server-side-encryption",
            "x-amz-request-id",
            "x-amz-id-2"]
    max_age_seconds = 3000
  }

  policy = data.aws_iam_policy_document.s3_bucket_policy.json
  tags   = var.tags
}

data "aws_route53_zone" "domain_name" {
  count        = var.use_default_domain ? 0 : 1
  name         = var.hosted_zone
  private_zone = false
}

resource "aws_route53_record" "route53_record" {
  for_each = toset(local.local_aliases)
  depends_on = [
    aws_cloudfront_distribution.s3_distribution
  ]

  zone_id = data.aws_route53_zone.domain_name[0].zone_id
  name = each.value
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = "Z2FDTNDATAQYW2"

    //HardCoded value for CloudFront
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [
    aws_s3_bucket.s3_bucket
  ]

  origin {
    domain_name = "${var.domain_name}.s3.amazonaws.com"
    origin_id   = "s3-cloudfront"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = local.local_aliases

  
  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "s3-cloudfront"
    
#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  dynamic "viewer_certificate" {
    for_each = local.default_certs
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.acm_certs
    content {
      acm_certificate_arn      = data.aws_acm_certificate.acm_cert[0].arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1"
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/"
  }

  wait_for_deployment = false
  tags                = var.tags
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.domain_name}.s3.amazonaws.com"
}
