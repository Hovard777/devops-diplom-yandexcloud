
#Master node

resource "yandex_compute_instance_group" "control-plane" {
  name                = local.master-instance-group-name
  folder_id           = var.folder_id
  service_account_id  = data.yandex_iam_service_account.diplom.id
  deletion_protection = false # защита_от_удаления:_true_или_false

  instance_template {
    platform_id = "standard-v2"
    name        = "master-{instance.index}"
    resources {
      memory = local.master_memory 
      cores  = local.master_cores 
      core_fraction = local.master_core_fraction 
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd81n0sfjm6d5nq6l05g"
        size     = local.master_disk_size
        type     = local.master_disk_type
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
      size = local.master_group_size 
    }
  }

  allocation_policy {
    zones = [
      local.zone-1,
      local.zone-2,
      local.zone-3
    ]
  }
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

}

#Worker nodes
resource "yandex_compute_instance_group" "worker-nodes" {
  name                = local.worker-instance-group-name
  folder_id           = var.folder_id
  service_account_id  = data.yandex_iam_service_account.diplom.id
  deletion_protection = false # защита_от_удаления:_true_или_false

  instance_template {
    platform_id = "standard-v2"
    name        = "worker-{instance.index}"
    resources {
      memory = local.worker_cores # объем_RAM_в_ГБ
      cores  = local.worker_memory # количество_ядер_vCPU
      core_fraction = local.worker_core_fraction # базовая  производительность в процентах
    }

    boot_disk {
      mode       = "READ_WRITE"
      initialize_params {
        image_id = "fd81n0sfjm6d5nq6l05g"
        size     = local.worker_disk_size"
        type     = local.worker_disk_type
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
      size = local.worker_group_size # количество_ВМ_в_группе
    }
  }

  allocation_policy {
    zones = [
      local.zone-1,
      local.zone-2,
      local.zone-3
    ]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
}