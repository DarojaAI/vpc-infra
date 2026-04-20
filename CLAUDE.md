# CLAUDE.md - Developer Instructions

This repo contains a Terraform module for creating a shared VPC network on GCP.

## Purpose

Creates a reusable VPC infrastructure that can be consumed by application repos (like `rag_research_tool`) to share network resources.

## Usage

```hcl
module "vpc" {
  source = "github.com/patelmm79/vpc-infra?ref=v1.0.0"

  project_id  = "my-project"
  region      = "us-central1"
  vpc_name    = "shared-vpc"
  
  subnets = [
    { name = "postgres-subnet", cidr = "10.8.0.0/24" },
    { name = "app-subnet", cidr = "10.9.0.0/24" }
  ]
}
```

## Deployment

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

## Key Outputs

| Output | Usage |
|--------|-------|
| `vpc_name` | Pass to postgres module |
| `subnet_names` | Pass subnet to postgres module |
| `subnet_cidrs` | Reference for firewall rules |

## Version Pinning

When consuming from app repos, pin to a specific version:
```hcl
source = "github.com/patelmm79/vpc-infra?ref=v1.0.0"
```

Tag releases in this repo following semver (v1.0.0, v1.1.0, etc.)