resource "aws_s3_bucket" "logging" {
  bucket = "mencarelli-silo-web-app-logging"
  acl    = "private"

  tags = {
    Name = "mencarelli-silo-web-app-logging"
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "mencarelli-silo-web-app-artifacts"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${data.aws_route53_zone.public.name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = aws_s3_bucket.logging.id
    target_prefix = "silo-web-app-artifacts/"
  }

  tags = {
    Name = "mencarelli-silo-web-app-artifacts"
  }
}

resource "aws_s3_bucket_policy" "artifacts-policy" {
  bucket = aws_s3_bucket.artifacts.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "AllowCloudfrontOnly",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : aws_cloudfront_origin_access_identity.public.iam_arn
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.artifacts.arn}/*"
      }
    ]
  })
  # policy = data.aws_iam_policy_document.artifacts-policy-document.json
}

# data "aws_iam_policy_document" "artifacts-policy-document" {
#   statement {
#     sid    = "PublicReadGetObject"
#     effect = "Allow"
#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     actions = [
#       "s3:GetObject"
#     ]

#     resources = [
#       "${aws_s3_bucket.artifacts.arn}/*"
#     ]
#   }
# }

resource "aws_s3_bucket_public_access_block" "artifacts-public-access-block" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "www-redirect" {
  bucket = "mencarelli-silo-web-app-redirect"
  acl    = "public-read"

  website {
    redirect_all_requests_to = "https://www.${data.aws_route53_zone.public.name}"
  }
  tags = {
    Name = "mencarelli-silo-web-app-www-redirect"
  }
}

resource "aws_s3_bucket_object" "placeholder-index" {
  bucket  = aws_s3_bucket.artifacts.id
  key     = "index.html"
  content = "Hello World"

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

resource "aws_s3_bucket_object" "placeholder-error" {
  bucket  = aws_s3_bucket.artifacts.id
  key     = "error.html"
  content = "Error!"

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}
