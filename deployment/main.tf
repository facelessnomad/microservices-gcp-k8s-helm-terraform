# GKE
data "google_client_config" "default" {}

data "google_container_engine_versions" "gke_version" {
  location       = var.region
  version_prefix = "1.27."
}

resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke-${terraform.workspace}"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  depends_on = [ 
    google_compute_network.vpc,
    google_compute_subnetwork.subnet
   ]
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name     = google_container_cluster.primary.name
  location = var.region
  cluster  = google_container_cluster.primary.name

  version    = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    preemptible  = true
    disk_type    = "pd-standard"
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke-${terraform.workspace}"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [ google_container_cluster.primary ]
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc-${terraform.workspace}"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet-${terraform.workspace}"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# HELM
resource "helm_release" "microservices-chart" {
  name  = "microservices-app-${terraform.workspace}"
  chart = "${path.module}./helm-chart"

  depends_on = [
    google_container_node_pool.primary_nodes
  ]
}