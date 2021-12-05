resource "aws_s3_bucket" "logging" {
  bucket = "silo-web-app-logging"
  acl    = "private"

  tags = {
    Name = "silo-web-app-logging"
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "silo-web-app-artifacts"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://${aws_route53_zone.public-domain.name}"]
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
    Name = "silo-web-app-artifacts"
  }
}

resource "aws_s3_bucket_policy" "artifacts-policy" {
  bucket = aws_s3_bucket.artifacts.id
  policy = data.aws_iam_policy_document.s3_read_permissions.json
}


data "aws_iam_policy_document" "artifacts-policy-document" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.artifacts.id,
      "${aws_s3_bucket.artifacts.id}/*"
    ]
  }
}
resource "aws_s3_bucket_public_access_block" "artifacts-public-access-block" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
