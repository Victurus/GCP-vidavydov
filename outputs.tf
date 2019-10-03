# INT

output "instance_g1_id_1" {
  value = "${google_compute_instance.instance_1.self_link}"
}

output "instance_g1_ip_1" {
  value = "${google_compute_instance.instance_1.network_interface.0.access_config.0.nat_ip}"
}

output "instance_g1_id_2" {
  value = "${google_compute_instance.instance_2.self_link}"
}

output "instance_g1_ip_2" {
  value = "${google_compute_instance.instance_2.network_interface.0.access_config.0.nat_ip}"
}

output "instance_g1_id_3" {
  value = "${google_compute_instance.instance_3.self_link}"
}

output "instance_g1_ip_3" {
  value = "${google_compute_instance.instance_3.network_interface.0.access_config.0.nat_ip}"
}

# NEG

output "instance_g2_id_1" {
  value = "${google_compute_instance.gateway_ins_1.self_link}"
}

output "instance_g2_ip_1" {
  value = "${google_compute_instance.gateway_ins_1.network_interface.0.access_config.0.nat_ip}"
}

output "instance_g2_id_2" {
  value = "${google_compute_instance.gateway_ins_2.self_link}"
}

output "instance_g2_ip_2" {
  value = "${google_compute_instance.gateway_ins_2.network_interface.0.access_config.0.nat_ip}"
}

output "instance_g2_id_3" {
  value = "${google_compute_instance.gateway_ins_3.self_link}"
}

output "instance_g2_ip_3" {
  value = "${google_compute_instance.gateway_ins_3.network_interface.0.access_config.0.nat_ip}"
}
