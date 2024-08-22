resource "aws_iam_role" "s3_access_for_sftp_users" {
  for_each            = local.user_names_map
  name                = "${var.identifier}-${each.key}"
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.s3_access_for_sftp_users[each.key].arn]
}

resource "aws_iam_policy" "s3_access_for_sftp_users" {
  for_each = local.user_names_map
  name     = "${var.identifier}-${each.key}"
  policy   = data.aws_iam_policy_document.s3_access_for_sftp_users[each.key].json
}
resource "aws_transfer_server" "transfer_server" {
  identity_provider_type = "SERVICE_MANAGED"
  protocols              = ["SFTP"]
  domain                 = "S3"
  tags = {
    Name = var.identifier
  }
}

resource "aws_transfer_user" "transfer_server_user" {
  for_each = local.user_names_map

  server_id = aws_transfer_server.transfer_server.id
  user_name = each.key
  role      = aws_iam_role.s3_access_for_sftp_users[each.key].arn

  home_directory_type = var.restricted_home ? "LOGICAL" : "PATH"
  home_directory      = var.restricted_home ? null : "/${var.s3_bucket_name}/${each.key}"

  dynamic "home_directory_mappings" {
    for_each = var.restricted_home ? [1] : []
    content {
      entry  = "/"
      target = "/${var.s3_bucket_name}/${each.key}"
    }
  }
}

resource "aws_transfer_ssh_key" "transfer_server_ssh_key" {
  for_each  = local.user_names_map
  server_id = aws_transfer_server.transfer_server.id
  user_name = each.key
  body      = each.value.public_key
}
