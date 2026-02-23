variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "The prefix for the S3 bucket name."
  type        = string
  default     = "sudipta-website-hosting-bucket"
}

variable "website_source_dir" {
  description = "The local directory containing the website files to upload to S3."
  type        = string
  default     = "./website"
}