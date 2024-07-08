# Creating a cloud network

resource "yandex_vpc_network" "network" {
  name = local.network_name
}

# Creating subnets

resource "yandex_vpc_subnet" "subnet-1" {
  name           = local.subnet-1
  zone           = local.zone-1
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = local.subnet-1
  zone           = local.zone-2
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = local.subnet-1
  zone           = local.zone-3
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}