variable "cloud_id" {
  default = "b1grtmm0e3bfv2rf4kiq"
}
variable "folder_id" {
  default = "b1gd5rvg0g57hu28ajgt"
}

variable "ssh_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

data "yandex_iam_service_account" "diplom" {
  name        = "diplom"
 # description = "Service account for manage instances"
}

locals {
  network_name  = "diplom_network"
  subnet-1  = "subnet-pub-1"
  subnet-2  = "subnet-pub-1"
  subnet-3  = "subnet-pub-1"
  
  zone-1        = "ru-central1-a"
  zone-2        = "ru-central1-b"
  zone-3        = "ru-central1-d"

  master-instance-group-name = "k8s-control-plane"
  
  master_cores  = 2 # количество_ядер_vCPU
  master_memory = 2 # объем_RAM_в_ГБ
  master_core_fraction = 20 # базовая  производительность в процентах
  master_disk_size = 20
  master_disk_type = "network-sdd"
  master_group_size = 1 # количество_ВМ_в_группе

  worker-instance-group-name = "k8s-workers"

  worker_cores = 2
  worker_memory = 2
  worker_core_fraction = 100
  worker_disk_size = 20
  worker_disk_type = "network-hdd"
  worker_group_size = 3
  
}


