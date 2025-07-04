# 🔹 AWS Provider Configuration
provider "aws" {
  region = "eu-west-1"
}

##########################
# 📦 Create a Private S3 Bucket
##########################

resource "aws_s3_bucket" "my_bucket" {
  bucket        = "skander-terraform-demo-bucket" # Must be globally unique
  force_destroy = true                             # Allows deletion even if files exist

  tags = {
    Name        = "demo-s3-bucket"
    Environment = "Dev"
  }
}

# 🔒 Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#########################################
# 👤 Create an IAM User with S3 Access
#########################################

resource "aws_iam_user" "demo_user" {
  name          = "terraform-user-demo"
  force_destroy = true
}

# 📜 IAM Policy: Read-only access to the S3 bucket
data "aws_iam_policy_document" "s3_read_only" {
  statement {
    sid    = "ReadAccessToBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.my_bucket.arn,
      "${aws_s3_bucket.my_bucket.arn}/*"
    ]
  }
}

# 🛡️ Create the IAM Policy from the document
resource "aws_iam_policy" "read_s3_policy" {
  name   = "ReadOnlyS3Policy"
  policy = data.aws_iam_policy_document.s3_read_only.json
}

# 🔗 Attach the policy to the IAM user
resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.demo_user.name
  policy_arn = aws_iam_policy.read_s3_policy.arn
}
