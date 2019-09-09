output "instance_id_1" {
  value = "${google_compute_instance.instance_1.self_link}"
}

output "instance_ip_1" {
  value = "${google_compute_instance.instance_1.network_interface.0.access_config.0.nat_ip}"
}

output "instance_id_2" {
  value = "${google_compute_instance.instance_2.self_link}"
}

output "instance_ip_2" {
  value = "${google_compute_instance.instance_2.network_interface.0.access_config.0.nat_ip}"
}

output "instance_id_3" {
  value = "${google_compute_instance.instance_3.self_link}"
}

output "instance_ip_3" {
  value = "${google_compute_instance.instance_3.network_interface.0.access_config.0.nat_ip}"
}
