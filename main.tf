resource "google_compute_network" "vpc_network" {
      project                 = var.project_id
       name  =                  "test-network1"
       auto_create_subnetworks = false
       routing_mode                    = "GLOBAL"
        delete_default_routes_on_create = false
}
resource "google_compute_subnetwork" "subnet" {
    name                     ="f1subnet"
  ip_cidr_range            = "172.16.0.0/24"
  region                   = var.resource_region[0]
  
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}
resource "google_compute_firewall" "default" {
  name    = "peerfirewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22","3389"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["externalssh"]
}
resource "google_compute_network" "vpc_network1" {
      project                 = var.project_id
       name  =                  "test-network2"
       auto_create_subnetworks = false
       routing_mode                    = "GLOBAL"
        delete_default_routes_on_create = false
}
resource "google_compute_subnetwork" "subnet1" {
    name                     ="f2subnet"
  ip_cidr_range            = "172.20.0.0/20"
  region                   = var.resource_region[1]
  network       = google_compute_network.vpc_network1.id
  private_ip_google_access = true
}
resource "google_compute_firewall" "default1" {
  name    = "peerfirewall1"
  network = google_compute_network.vpc_network1.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22","3389"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["web"]
}
resource "google_compute_instance" "terraform-instance" {
  name         = "myterravm"
    zone         = "us-central1-a"
  machine_type = "f1-micro"
  
  tags         = ["externalssh","web"]
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
   // network =   data.google_compute_network.tst_vpc.name  ..it will not create here as subnetwork only craete
    subnetwork = "${google_compute_subnetwork.subnet.id}"
    access_config {
    
   }
  }
  }
  resource "google_compute_instance" "terraform-instance1" {
  name         = "myterravm1"
    zone         = "asia-northeast2-a"
  machine_type = "f1-micro"
  
  tags         = ["externalssh","web"]
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
   subnetwork = "${google_compute_subnetwork.subnet1.id}"
    access_config {
    
   }
  }
  }
  
resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = "${google_compute_network.vpc_network.self_link}"
  peer_network = "${google_compute_network.vpc_network1.self_link}"
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = "${google_compute_network.vpc_network1.self_link}"
  peer_network = "${google_compute_network.vpc_network.self_link}"
}




