terraform {
  required_version = ">= 1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }
  }
}

locals {
  s3_arn_prefix = "arn:${data.aws_partition.default.partition}:s3:::"

  user_names_map = {
    for user in var.sftp_users :
    user.user_name => merge(user, {
      s3_bucket_arn = lookup(user, "s3_bucket_name", null) != null ? "${local.s3_arn_prefix}${lookup(user, "s3_bucket_name")}" : data.aws_s3_bucket.landing.arn
    })
  }
}

data "aws_partition" "default" {}

data "aws_s3_bucket" "landing" {
  bucket = var.s3_bucket_name
}
data "aws_iam_policy_document" "s3_access_for_sftp_users" {
  for_each = local.user_names_map
  statement {
    sid       = "AllowListingOfUserFolder"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [each.value.s3_bucket_arn]
  }

  statement {
    sid    = "HomeDirObjectAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject", "s3:GetObject", "s3:DeleteObject",
      "s3:DeleteObjectVersion", "s3:GetObjectVersion",
      "s3:GetObjectACL", "s3:PutObjectACL"
    ]
    resources = [
      var.restricted_home ? "${each.value.s3_bucket_arn}/${each.value.user_name}/*" : "${each.value.s3_bucket_arn}/*"
    ]
  }
}
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}


