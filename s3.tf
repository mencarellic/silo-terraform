resource "aws_s3_bucket" "artifacts" {
  bucket = "silo-web-apps-artifacts"
  acl    = "private"

  tags = {
    Name = "silo-web-apps-artifacts"
  }
}
