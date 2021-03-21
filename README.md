# Single Page Application

https://registry.terraform.io/modules/Xerris-Terraform-Modules/event-lambda/aws/latest

This is a quick way to spin up the necesary S3 Buckets, Cloudfront distributions, Route 53 records and ACM Certificates for a typical React/Single Page Application

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| aws.aws\_cloudfront | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_acm_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) |
| [aws_cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) |
| [aws_cloudfront_origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) |
| [aws_route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acm\_certificate\_domain | ACM Certificate Domain | `any` | `null` | no |
| domain\_name | Domain name to set for applications | `any` | n/a | yes |
| hosted\_zone | Hosted Zone for Route 53 | `any` | `null` | no |
| price\_class | CloudFront distribution price class | `string` | `"PriceClass_100"` | no |
| tags | Resource Tags if applicable | `map(string)` | `{}` | no |
| use\_default\_domain | Use CloudFront website address without Route53 and ACM certificate | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudfront\_dist\_id | If you want this lambda to be triggered by an S3 upload event. |
| cloudfront\_domain\_name | If you want this lambda to be triggered by an S3 upload event. |
