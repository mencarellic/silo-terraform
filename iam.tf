resource "aws_iam_user" "github-actions-app-deployment" {
  name = "github-actions-app-deployment"
}

data "aws_iam_policy_document" "github-actions-app-deployment" {
  statement {
    sid = "DeployToS3Object"
    actions = [
      "s3:PutObject*"
    ]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }
}

resource "aws_iam_user_policy" "github-actions-app-deployment" {
  name = "github-actions-app-deployment"
  user = aws_iam_user.github-actions-app-deployment.name

  policy = data.aws_iam_policy_document.github-actions-app-deployment.json
}

resource "aws_iam_access_key" "github-actions-app-deployment" {
  user = aws_iam_user.github-actions-app-deployment.name
}
