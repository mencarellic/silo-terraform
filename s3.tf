resource "aws_s3_bucket" "logging" {
  bucket = "mencarelli-silo-web-app-logging"
  acl    = "private"

  tags = {
    Name = "mencarelli-silo-web-app-logging"
  }
}

resource "aws_s3_bucket_public_access_block" "logging-public-access-block" {
  bucket = aws_s3_bucket.logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logging-policy" {
  bucket = aws_s3_bucket.logging.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "AllowLogging",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logging.s3.amazonaws.com"
        },
        "Action" : [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource" : "${aws_s3_bucket.logging.arn}/*"
      }
    ]
  })
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
      },
      {
        "Sid" : "AllowDeployment",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : aws_iam_user.github-actions-app-deployment.arn
        },
        "Action" : [
          "s3:PutObject*",
          "s3:GetObject*",
          "s3:DeleteObject*"
        ],
        "Resource" : "${aws_s3_bucket.artifacts.arn}/*"
      }
    ]
  })
}

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

resource "aws_s3_bucket_public_access_block" "www-redirect-public-access-block" {
  bucket = aws_s3_bucket.www-redirect.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "www-redirect-policy" {
  bucket = aws_s3_bucket.www-redirect.id
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
        "Resource" : "${aws_s3_bucket.www-redirect.arn}/*"
      }
    ]
  })
}
