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

variable "network_name" {
  description = "Base name for the network"
  type        = string
  default     = "my-network"
}

variable "num_subnets" {
  description = "Number of subnets to create"
  type        = number
  default     = 3
}

variable "zones" {
  description = "List of zones"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
}


locals {
  subnet_cidrs = [for i in range(var.num_subnets) : "192.168.${i + 1}.0/24"]
}


