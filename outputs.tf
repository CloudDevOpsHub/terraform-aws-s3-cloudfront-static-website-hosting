output "website_url" {
  description = "The URL of the S3 bucket for static website hosting."
  value       = "https://${aws_cloudfront_distribution.website_distribution.domain_name}"
}

output "cloudfront_url" {
  description = "The URL of the CloudFront distribution."
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket created for website hosting."
  value       = aws_s3_bucket.website_bucket.bucket
}