# =============================================================================
# VPC Network Infrastructure
# =============================================================================
# Creates a shared VPC with subnets for PostgreSQL and application workloads.
# Includes firewall rules, Cloud NAT, and VPC Access Connector support.
# =============================================================================

# Enable required GCP APIs
resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "servicenetworking" {
  project            = var.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "vpcaccess" {
  project            = var.project_id
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

# =============================================================================
# VPC Network
# =============================================================================

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute]
}

# =============================================================================
# Subnets
# =============================================================================

resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  project       = var.project_id
  name          = "${var.vpc_name}-${each.value.name}"
  ip_cidr_range = each.value.cidr
  region        = var.region
  network       = google_compute_network.vpc.name

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  depends_on = [google_project_service.compute]
}

# =============================================================================
# Firewall Rules
# =============================================================================

resource "google_compute_firewall" "allow_internal" {
  project = var.project_id
  name    = "${var.vpc_name}-allow-internal-${var.environment}"
  network = google_compute_network.vpc.name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [for subnet in var.subnets : subnet.cidr]
}

resource "google_compute_firewall" "allow_ssh" {
  project = var.project_id
  count   = length(var.allow_ssh_from_cidrs) > 0 ? 1 : 0
  name    = "${var.vpc_name}-allow-ssh-${var.environment}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allow_ssh_from_cidrs
}

resource "google_compute_firewall" "allow_postgres" {
  project = var.project_id
  name    = "${var.vpc_name}-allow-postgres-${var.environment}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  # Allow from all subnets in this VPC
  source_ranges = [for subnet in var.subnets : subnet.cidr]
}

resource "google_compute_firewall" "allow_egress" {
  project = var.project_id
  count   = var.enable_cloud_nat ? 1 : 0
  name    = "${var.vpc_name}-allow-egress-${var.environment}"
  network = google_compute_network.vpc.name

  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}

# =============================================================================
# Cloud NAT (for outbound internet access)
# =============================================================================

resource "google_compute_router" "router" {
  project = var.project_id
  count   = var.enable_cloud_nat ? 1 : 0
  name    = "${var.vpc_name}-router-${var.environment}"
  region  = var.region
  network = google_compute_network.vpc.id

  depends_on = [google_compute_network.vpc]
}

resource "google_compute_router_nat" "nat" {
  project = var.project_id
  count   = var.enable_cloud_nat ? 1 : 0
  name    = "${var.vpc_name}-nat-${var.environment}"
  router  = google_compute_router.router[0].name
  region  = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [google_compute_router.router]
}

# =============================================================================
# Outputs
# =============================================================================

output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_id" {

# =============================================================================
# VPC Access Connector (for external service access: GitHub Actions, Cloud Run)
# =============================================================================

resource "google_vpc_access_connector" "github_actions" {
  name          = "${var.vpc_name}-github-connector-${var.environment}"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.2.0/28"
  machine_type  = "e2-micro"

  depends_on = [google_project_service.vpcaccess, google_compute_network.vpc]
}

# =============================================================================
# Outputs
# =============================================================================
  value       = google_compute_network.vpc.id
}

output "vpc_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnets" {
  description = "Map of subnet names to subnet objects"
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet }
}

output "subnet_names" {
  description = "List of subnet names"
  value       = [for name, subnet in google_compute_subnetwork.subnets : subnet.name]
}

output "subnet_cidrs" {
  description = "Map of subnet name to CIDR"
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet.ip_cidr_range }
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet.id }
}

output "region" {
  description = "Region where VPC is deployed"
  value       = var.region
}

output "nat_ip_allocated" {
  description = "Whether Cloud NAT is enabled"
  value       = var.enable_cloud_nat
}
output "vpc_connector_name" {
  description = "Name of VPC Access Connector for external service access"
  value       = google_vpc_access_connector.github_actions.name
}

output "vpc_connector_self_link" {
  description = "Self link of VPC Access Connector"
  value       = google_vpc_access_connector.github_actions.self_link
}
