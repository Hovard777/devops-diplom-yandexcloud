
#Master node

resource "yandex_compute_instance_group" "control-plane" {
  name                = "k8s-control-plane"
  folder_id           = var.folder_id
  service_account_id  = data.yandex_iam_service_account.diplom.id
  deletion_protection = false # защита_от_удаления:_true_или_false

  instance_template {
    platform_id = "standard-v2"
    name        = "master-{instance.index}"
    resources {
      memory = 2 # объем_RAM_в_ГБ
      cores  = 2 # количество_ядер_vCPU
      core_fraction = 20 # базовая  производительность в процентах
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd81n0sfjm6d5nq6l05g"
        size     = 20
        type     = "network-hdd"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.network.id}"
      subnet_ids = [
        "${yandex_vpc_subnet.subnet-1.id}",
        "${yandex_vpc_subnet.subnet-2.id}",
        "${yandex_vpc_subnet.subnet-3.id}",
      ]
      nat = true
    }
    metadata = { user-data = "#cloud-config\nusers:\n  - name: ifebres\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
    }
  }
  scale_policy {
    fixed_scale {
      size = 1 # количество_ВМ_в_группе
    }
  }

  allocation_policy {
    zones = [
      "ru-central1-a",
      "ru-central1-b",
      "ru-central1-d"
    ]
  }
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

}

#Worker nodes
resource "yandex_compute_instance_group" "worker-nodes" {
  name                = "k8s-workers"
  folder_id           = var.folder_id
  service_account_id  = data.yandex_iam_service_account.diplom.id
  deletion_protection = false # защита_от_удаления:_true_или_false

  instance_template {
    platform_id = "standard-v2"
    name        = "worker-{instance.index}"
    resources {
      memory = 2 # объем_RAM_в_ГБ
      cores  = 2 # количество_ядер_vCPU
      core_fraction = 20 # базовая  производительность в процентах
    }

    boot_disk {
      mode       = "READ_WRITE"
      initialize_params {
        image_id = "fd81n0sfjm6d5nq6l05g"
        size     = "20"
        type     = "network-hdd"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.network.id}"
      subnet_ids = [
        "${yandex_vpc_subnet.subnet-1.id}",
        "${yandex_vpc_subnet.subnet-2.id}",
        "${yandex_vpc_subnet.subnet-3.id}",
      ]
      nat = true
    }
    metadata = { user-data = "#cloud-config\nusers:\n  - name: ifebres\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
    }
  }
  scale_policy {
    fixed_scale {
      size = 3 # количество_ВМ_в_группе
    }
  }

  allocation_policy {
    zones = [
      "ru-central1-a",
      "ru-central1-b",
      "ru-central1-d"
    ]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
}