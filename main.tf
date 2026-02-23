data "aws_caller_identity" "current" {}

# S3 bucket for static website hosting
resource "aws_s3_bucket" "website_bucket" {
  bucket_prefix = var.bucket_prefix
}

# Make S3 bucket private
resource "aws_s3_bucket_public_access_block" "website_bucket_public_access_block" {
  bucket = aws_s3_bucket.website_bucket.id
  depends_on = [ aws_s3_bucket.website_bucket ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Origin Access Control for CloudFront
resource "aws_cloudfront_origin_access_control" "oac" {
  name = "${var.bucket_prefix}-oac"
  description     = "OAC for ${var.bucket_prefix} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

# S3 bucket policy to allow CloudFront access
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  depends_on = [ aws_s3_bucket_public_access_block.website_bucket_public_access_block ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.website_distribution.id}"
          }
        }
      }
    ]
  })
}

# Upload website files to S3
resource "aws_s3_object" "website_files" {
  for_each = {
    for file in fileset(var.website_source_dir, "**") :
    file => file
    if !endswith(file, "/")
  }

  bucket       = aws_s3_bucket.website_bucket.id
  key          = each.value
  source       = "${var.website_source_dir}/${each.value}"
  etag         = filemd5("${var.website_source_dir}/${each.value}")
  
  content_type = try(
    lookup(
      {
        "html" = "text/html",
        "css"  = "text/css",
        "js"   = "application/javascript",
        "json" = "application/json",
        "png"  = "image/png",
        "jpg"  = "image/jpeg",
        "jpeg" = "image/jpeg",
        "gif"  = "image/gif",
        "svg"  = "image/svg+xml",
        "ico"  = "image/x-icon"
      },
      lower(reverse(split(".", each.value))[0])
    ),
    "application/octet-stream"
  )

  depends_on = [aws_s3_bucket_public_access_block.website_bucket_public_access_block]
}

# Configure S3 bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

  depends_on = [aws_s3_bucket_public_access_block.website_bucket_public_access_block]
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website_bucket.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # CloudFront distribution settings
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.bucket_prefix} S3 bucket"
  default_root_object = "index.html"

  # Cache behavior settings
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Redirect HTTP to HTTPS
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Use the lowest price class for CloudFront to minimize costs
  price_class = "PriceClass_100"

  # Geo restriction settings 
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Use the default CloudFront certificate for HTTPS
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
