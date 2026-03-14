terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.90.0"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_iam_service_account" "sa" {
  name      = var.sa
}

// https://yandex.cloud/ru/docs/iam/roles-reference

resource "yandex_resourcemanager_folder_iam_member" "iam-sa" {
  folder_id = var.folder_id
  role      = "iam.serviceAccounts.user"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-admin" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "storage-admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "compute-admin" {
  folder_id = var.folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_key" "sa_key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "Key for Yandex Cloud access"
}

resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "S3 static keys"
}

resource "yandex_storage_bucket" "tf-state" {
  folder_id             = var.folder_id
  bucket                = var.bucket
  default_storage_class = "COLD"
  max_size              = 104857600
}

resource "local_file" "key_json" {
  content  = jsonencode({
    id              = yandex_iam_service_account_key.sa_key.id
    service_account_id = yandex_iam_service_account_key.sa_key.service_account_id
    private_key     = yandex_iam_service_account_key.sa_key.private_key
    created_at      = yandex_iam_service_account_key.sa_key.created_at
  })
  filename = "yandex-sa.json"
}

resource "local_file" "static_key_json" {
  content = jsonencode({
    access_key = yandex_iam_service_account_static_access_key.sa_static_key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
    service_account_id = yandex_iam_service_account_static_access_key.sa_static_key.service_account_id
  })
  filename = "yandex-s3.json"
}
