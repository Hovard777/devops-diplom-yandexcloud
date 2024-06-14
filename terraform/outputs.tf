output "master_node_external_ips" {
    value = yandex_compute_instance_group.control-plane.instances.*.network_interface.0.nat_ip_address
}

output "master_node_internal_ips" {
    value = yandex_compute_instance_group.control-plane.instances.*.network_interface.0.ip_address
}

output "worker_node_external_ips" {
    value = yandex_compute_instance_group.worker-nodes.instances.*.network_interface.0.nat_ip_address
}

output "worker_node_internal_ips" {
    value = yandex_compute_instance_group.worker-nodes.instances.*.network_interface.0.ip_address
}

