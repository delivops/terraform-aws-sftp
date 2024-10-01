# Terraform-aws-sftp

Terraform-aws-sftp is a Terraform module for setting up an AWS Transfer for SFTP server.

## Installation

To use this module, you need to have Terraform installed. You can find installation instructions on the Terraform website.

## Usage

The module will create a connection over protocol sftp with s3 bucket.
Use this module multiple times to create repositories with different configurations.

Include this repository as a module in your existing terraform code:

```python

provider "aws" {
  region = var.aws_region
  }

################################################################################
# AWS S3
################################################################################


module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  # version       = "4.1.2"
  bucket = var.s3_bucket_name
  acl    = "private"
  force_destroy = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

################################################################################
# AWS SFTP
################################################################################

module "sftp" {
  source = "delivops/sftp/aws"
  # version  = "x.x.x"

  sftp_users = var.sftp_users
  # [
  #   {
  #     user_name  = "xxxxx"
  #     public_key = "xxxxx"
  #   },
  #   {
  #     user_name  = "yyyyy"
  #     public_key = "yyyy"
  #      }
  # ]
  restricted_home = var.restricted_home
  identifier      = var.identifier
  s3_bucket_name  = module.s3_bucket.s3_bucket_id
}

```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.s3_access_for_sftp_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.s3_access_for_sftp_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_transfer_server.transfer_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_server) | resource |
| [aws_transfer_ssh_key.transfer_server_ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_ssh_key) | resource |
| [aws_transfer_user.transfer_server_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_user) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_access_for_sftp_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_s3_bucket.landing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Identifier for this module's resources | `string` | n/a | yes |
| <a name="input_restricted_home"></a> [restricted\_home](#input\_restricted\_home) | Whether to restrict users to their home directories | `bool` | `true` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket for SFTP storage | `string` | n/a | yes |
| <a name="input_sftp_users"></a> [sftp\_users](#input\_sftp\_users) | List of SFTP users to create | <pre>list(object({<br/>    user_name       = string<br/>    public_key      = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The Server ID of the Transfer Server (e.g. s-12345678). |
| <a name="output_transfer_server_endpoint"></a> [transfer\_server\_endpoint](#output\_transfer\_server\_endpoint) | The endpoint of the Transfer Server (e.g. s-12345678.server.transfer.REGION.amazonaws.com). |
<!-- END_TF_DOCS -->

## Steps

### 1. Construct the endpoint

Using the following format:

```bash
<<s-SERVER_ID>>.server.transfer.REGION.amazonaws.com
```

### 2. Testing the SFTP Server

Using the following format:

```bash
sftp -i /path/to/private_key user1@your-sftp-server-endpoint
```

## License

MIT

