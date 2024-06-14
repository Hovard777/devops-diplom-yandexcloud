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



