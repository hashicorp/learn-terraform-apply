# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

## Output values

output "bucket_name" {
  description = "Name of S3 bucket"
  value       = aws_s3_bucket.example.bucket
}
