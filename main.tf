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

resource "yandex_vpc_network" "itmo508541-network" {
  name        = "itmo508541-network"
  description = "sem1-project network"
}

resource "yandex_vpc_subnet" "itmo508541-subnet" {
  name           = "itmo508541-subnet"
  description    = "sem1-project subnet"
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = var.zone
  network_id     = yandex_vpc_network.itmo508541-network.id
}

###########

resource "local_file" "key_json" {
  content  = jsonencode({
    id              = yandex_iam_service_account_key.sa_key.id
    service_account_id = yandex_iam_service_account_key.sa_key.service_account_id
    private_key     = yandex_iam_service_account_key.sa_key.private_key
    created_at      = yandex_iam_service_account_key.sa_key.created_at
  })
  filename = "yandex-sa.json"
}

#output "subnet_id" {
#  value = yandex_vpc_subnet.itmo508541-subnet.id
#  description = "subnet-id"
#}
