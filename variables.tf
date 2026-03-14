variable "token" {
  type        = string
  description = "YC token"
  sensitive   = true
}

variable "sa" {
  type        = string
  description = "Service account name"
  sensitive   = true
}

variable "cloud_id" {
  type        = string
  description = "Cloud ID"
}

variable "folder_id" {
  type        = string
  description = "Folder ID"
}

variable "zone" {
  type        = string
  description = "Zone"
}

variable "bucket" {
  type        = string
  description = "Bucket for Terraform state storage"
}
