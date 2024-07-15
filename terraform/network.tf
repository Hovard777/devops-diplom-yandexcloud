# Creating a cloud network
resource "yandex_vpc_network" "network" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "subnet" {
  count = var.num_subnets

  name           = "${var.network_name}-subnet-${count.index + 1}"
  zone           = var.zones[count.index % length(var.zones)]
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [local.subnet_cidrs[count.index]]
}