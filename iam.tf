resource "aws_iam_policy" "terraform_s3_state_policy" {
  name        = "TerraformS3StateAccessWithLockfile"
  description = "Permite acesso ao S3 para arquivos de tfstate e tflock"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "S3StateAccess",
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}/${var.bucket_prefix}/terraform.tfstate",
          "arn:aws:s3:::${var.bucket_name}/${var.bucket_prefix}/terraform.tfstate.tflock"
        ]
      },
      {
        Sid      = "S3ListBucket",
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::${var.bucket_name}"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_s3_state_policy" {
  user       = var.iam_user_name
  policy_arn = aws_iam_policy.terraform_s3_state_policy.arn
}