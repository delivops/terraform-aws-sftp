variable "identifier" {
  description = "Identifier for this module's resources"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for SFTP storage"
  type        = string
}

variable "sftp_users" {
  description = "List of SFTP users to create"
  type = list(object({
    user_name       = string
    public_key      = string
  }))
  sensitive = true
}

variable "restricted_home" {
  description = "Whether to restrict users to their home directories"
  type        = bool
  default     = true
}
