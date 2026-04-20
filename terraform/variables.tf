# =============================================================================
# Variables
# =============================================================================

variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "prod"
}

variable "vpc_name" {
  description = "Name for the VPC network"
  type        = string
  default     = "shared-vpc"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,}[a-z]$", var.vpc_name))
    error_message = "VPC name must start with lowercase letter, end with letter/number, contain only lowercase letters, numbers, and hyphens, and be at least 4 characters."
  }
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name = string
    cidr = string
  }))
  default = [
    {
      name = "postgres-subnet"
      cidr = "10.8.0.0/24"
    }
  ]
}

variable "allow_ssh_from_cidrs" {
  description = "CIDR blocks allowed to SSH into instances"
  type        = list(string)
  default     = []
}

variable "enable_cloud_nat" {
  description = "Enable Cloud NAT for outbound internet access"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}