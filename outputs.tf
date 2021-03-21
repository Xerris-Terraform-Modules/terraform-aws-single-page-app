
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "If you want this lambda to be triggered by an S3 upload event."
}

output "cloudfront_dist_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
  description = "If you want this lambda to be triggered by an S3 upload event."
}
