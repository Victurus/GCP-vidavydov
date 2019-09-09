data "google_compute_zones" "available" {}

resource "google_compute_network" "main_net" {
  name = "main-project-net"
  project = "${google_project_services.project.project}"
}

resource "google_compute_subnetwork" "subnet_1" {
  name = "subnet-1"
  region = "${var.region}"
  project = "${google_project_services.project.project}"
  description = "First subnetwork"
  ip_cidr_range = "10.64.0.0/20"
  network = "${google_compute_network.main_net.self_link}"
}

resource "google_compute_firewall" "allow_internal" {
  name = "internal-tcp-icmp"
  network = "${google_compute_network.main_net.name}"
  project = "${google_project_services.project.project}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = ["10.64.0.0/20"]
}

resource "google_compute_firewall" "allow_ssh_icmp" {
  name = "allow-ssh-icmp"
  network = "${google_compute_network.main_net.name}"
  project = "${google_project_services.project.project}"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_instance" "instance_1" {
  name = "tf-compute-1"
  project = "${google_project_services.project.project}"
  zone = "${data.google_compute_zones.available.names[0]}"
  machine_type = "f1-micro"
  tags = ["group-1"]
  boot_disk {
    initialize_params {
      image = "${var.boot_disk}"
    }
  }
  metadata = {
    ssh-keys = "${var.ansible_user}:${file(var.ansible_user_pub_key_path)}"
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet_1.self_link}"
    access_config {}
  }
}

resource "google_compute_instance" "instance_2" {
  name = "tf-compute-2"
  project = "${google_project_services.project.project}"
  zone = "${data.google_compute_zones.available.names[0]}"
  machine_type = "f1-micro"
  tags = ["group-1"]
  boot_disk {
    initialize_params {
      image = "${var.boot_disk}"
    }
  }
  metadata = {
    ssh-keys = "${var.ansible_user}:${file(var.ansible_user_pub_key_path)}"
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet_1.self_link}"
    access_config {}
  }
}

resource "google_compute_instance" "instance_3" {
  name = "tf-compute-3"
  project = "${google_project_services.project.project}"
  zone = "${data.google_compute_zones.available.names[0]}"
  machine_type = "f1-micro"
  tags = ["group-1"]
  boot_disk {
    initialize_params {
      image = "${var.boot_disk}"
    }
  }
  metadata = {
    ssh-keys = "${var.ansible_user}:${file(var.ansible_user_pub_key_path)}"
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet_1.self_link}"
    access_config {}
  }
}

resource "google_compute_instance_group" "group_1" {
  name = "instances-group-1"
  description = "First instance group"
  zone = "${data.google_compute_zones.available.names[0]}"
  project = "${google_project_services.project.project}"
  instances = [
    "${google_compute_instance.instance_1.self_link}",
    "${google_compute_instance.instance_2.self_link}",
    "${google_compute_instance.instance_3.self_link}",
  ]
}

# Internal load balancer 1 START

resource "google_compute_region_backend_service" "int_bsvc_1" {
  name = "int-bsvc-1"
  description = "Internal regional backend service 1"
  region = "${var.region}"
  health_checks = ["${google_compute_health_check.hcheck_int_bsvc_1.self_link}"]
  project = "${google_project_services.project.project}"

  protocol = "TCP"
  backend {
    group = "${google_compute_instance_group.group_1.self_link}"
  }
}

resource "google_compute_health_check" "hcheck_int_bsvc_1" {
  name = "hcheck-int-bsvc-1"
  description = "Health check for internal backend regional service 1"
  project = "${google_project_services.project.project}"
  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_address" "int_lb_address_1" {
  name = "int-lb-address-1"
  subnetwork = "${google_compute_subnetwork.subnet_1.self_link}"
  address_type = "INTERNAL"
  address = "10.64.0.7"
  project = "${google_project_services.project.project}"
  region = "${var.region}"
}

resource "google_compute_forwarding_rule" "int_lb_1" {
  name = "int-lb-1"
  description = "Internal load balancer 1"
  load_balancing_scheme = "INTERNAL"
  ports = ["80","22"]
  project = "${google_project_services.project.project}"
  network = "${google_compute_network.main_net.self_link}"
  subnetwork = "${google_compute_subnetwork.subnet_1.self_link}"
  backend_service = "${google_compute_region_backend_service.int_bsvc_1.self_link}"
  ip_address = "${google_compute_address.int_lb_address_1.address}"
}

# Internal load balancer 1 END

# Network endpoint group 1 START

resource "google_compute_network_endpoint_group" "neg_1" {
  name         = "neg-1"
  network      = "${google_compute_network.main_net.self_link}"
  subnetwork   = "${google_compute_subnetwork.subnet_1.self_link}"
  project = "${google_project_services.project.project}"
  default_port = "80"
  zone         = "${data.google_compute_zones.available.names[0]}"
}

resource "google_compute_network_endpoint" "nee_1" {
  network_endpoint_group = "${google_compute_network_endpoint_group.neg_1.id}"

  project    = "${google_project_services.project.project}"
  instance   = "${google_compute_instance.gateway_ins_1.name}"
  ip_address = "${google_compute_instance.gateway_ins_1.network_interface.0.network_ip}"
  port       = "${google_compute_network_endpoint_group.neg_1.default_port}"
  zone       = "${data.google_compute_zones.available.names[0]}"
}

# Network endpoint group 1 STOP

# Gateway instance 

resource "google_compute_instance" "gateway_ins_1" {
  project = "${google_project_services.project.project}"
  zone = "${data.google_compute_zones.available.names[0]}"
  name = "gateway-ins-1"
  machine_type = "f1-micro"
  can_ip_forward = "true"
  tags = ["gateway"]
  boot_disk {
    initialize_params {
      image = "${var.boot_disk}"
    }
  }
  metadata = {
    ssh-keys = "${var.ansible_user}:${file(var.ansible_user_pub_key_path)}"
  }
#  metadata_startup_script = <<_EOF
#sysctl net.ipv4.ip_forward=1
#iptables -t nat -F
#iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --destination ${google_compute_address.int_lb_address_1.address}:80
#iptables -t nat -A POSTROUTING -p tcp -d ${google_compute_address.int_lb_address_1.address} --dport 80 -j SNAT --to-source ${google_compute_instance.gateway_ins_1.network_interface.0.network_ip}
#_EOF
  network_interface {
    network = "${google_compute_network.main_net.self_link}"
    subnetwork = "${google_compute_subnetwork.subnet_1.self_link}"
    access_config {}
  }
}

# External load balancer 1 START

resource "google_compute_global_forwarding_rule" "ext_lb_1" {
  name = "ext-lb-1"
  project = "${google_project_services.project.project}"
  description = "First external load balancer"
  load_balancing_scheme = "EXTERNAL"
  port_range = "80"
  target = "${google_compute_target_http_proxy.proxy_1.self_link}"
}

resource "google_compute_target_http_proxy" "proxy_1" {
  name = "proxy-1"
  description = "This is main proxy"
  url_map = "${google_compute_url_map.url_map_1.self_link}"
  project = "${google_project_services.project.project}"
}

resource "google_compute_url_map" "url_map_1" {
  name = "url-map-1"
  description = "This is URL map for main traffic proxy"
  default_service = "${google_compute_backend_service.ext_backend_1.self_link}"
  project = "${google_project_services.project.project}"

  host_rule {
    hosts        = ["test-1.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.ext_backend_1.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.ext_backend_1.self_link}"
    }
  }
}

# External load balancer 1 END

# Exteranl backend

resource "google_compute_backend_service" "ext_backend_1" {
  name          = "ext-backend-1"
  health_checks = ["${google_compute_health_check.ext_hcheck_1.self_link}"]
  load_balancing_scheme = "EXTERNAL"
  project = "${google_project_services.project.project}"

  backend {
    group = "${google_compute_network_endpoint_group.neg_1.self_link}"
    balancing_mode = "RATE"
    max_rate = "1000"
  }
}

resource "google_compute_health_check" "ext_hcheck_1" {
  name               = "ext-hcheck-1"
  check_interval_sec = 1
  timeout_sec        = 1
  project = "${google_project_services.project.project}"
  tcp_health_check {
   port = "80"
  }
}

# Firewall rule

resource "google_compute_firewall" "allow_traffic" {
  name = "allow-traffic"
  network = "${google_compute_network.main_net.name}"
  project = "${google_project_services.project.project}"
  target_tags = ["gateway"]

  allow {
    protocol = "tcp"
    ports = ["80"]
  }
}
