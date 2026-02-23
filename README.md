# S3 Static Website Hosting with CloudFront & Origin Access Control

A production-ready Terraform configuration for hosting static websites on AWS using Amazon S3, CloudFront CDN, and Origin Access Control (OAC) for secure content delivery with HTTPS.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Outputs](#outputs)
- [Cost Analysis](#cost-analysis)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)
- [FAQ](#faq)

## Overview

This Terraform module creates a secure, scalable, and cost-effective static website hosting infrastructure on AWS. It combines S3 for storage, CloudFront for global content delivery, and OAC for secure origin access—all configured with industry best practices.

### What Gets Deployed

- **S3 Bucket**: Private bucket for storing static website files
- **CloudFront Distribution**: CDN for fast content delivery with HTTPS
- **Origin Access Control (OAC)**: Secure access from CloudFront to S3
- **Public Access Block**: Ensures S3 bucket remains private
- **S3 Bucket Policy**: Restricts access to CloudFront only

## Architecture

```
Users → CloudFront (Public) → OAC (Authentication) → S3 Bucket (Private)
```

## Prerequisites

- Terraform >= 1.0
- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- Website files in the `website/` directory

## File Structure

```
S3WebHosting/
├── main.tf              # Primary resource definitions
├── provider.tf          # AWS provider configuration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
└── website/             # Static website files
    ├── index.html
    ├── style.css
    └── script.js
```

## Variables

- `bucket_prefix`: Prefix for S3 bucket name (auto-generates unique name)
- `website_source_dir`: Path to website files directory (default: `./website`)

## Usage

1. **Initialize Terraform:**

   ```bash
   terraform init
   ```

2. **Plan the deployment:**

   ```bash
   terraform plan
   ```

3. **Apply the configuration:**

   ```bash
   terraform apply
   ```

4. **Get CloudFront URL:**
   ```bash
   terraform output cloudfront_domain_name
   ```

## Outputs

- `cloudfront_domain_name`: CloudFront distribution domain name
- `s3_bucket_name`: Name of the created S3 bucket

## Security Features

- S3 bucket is completely private (no public access)
- All public ACLs are blocked
- CloudFront uses Origin Access Control for secure S3 access
- HTTPS is enforced (HTTP redirects to HTTPS)
- Content is cached for performance optimization

## Cost Optimization

- Uses PriceClass_100 for CloudFront (lowest cost tier)
- S3 bucket has no public access (reduces exposure)
- CloudFront caching reduces S3 data transfer costs

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Notes

- The S3 bucket name is auto-generated with a random suffix to ensure global uniqueness
- CloudFront distribution may take 10-15 minutes to deploy
- Website files are automatically uploaded to S3 during deployment
