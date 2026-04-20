# VPC Infrastructure

Terraform module for creating a shared VPC network with subnets for GCP PostgreSQL deployments.

## Usage

```hcl
module "vpc" {
  source = "github.com/patelmm79/vpc-infra?ref=v1.0.0"

  project_id = "my-project"
  environment = "prod"
  region     = "us-central1"
  
  # Network configuration
  vpc_name = "shared-vpc"
  
  subnets = [
    {
      name = "postgres-subnet"
      cidr = "10.8.0.0/24"
    },
    {
      name = "app-subnet" 
      cidr = "10.9.0.0/24"
    }
  ]
  
  # Allow access from specific CIDRs (optional)
  allow_ssh_from_cidrs = ["1.2.3.4/32"]
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_name` | Name of the VPC network |
| `vpc_id` | ID of the VPC network |
| `subnets` | Map of subnet names to subnet objects |
| `subnet_names` | List of subnet names |
| `subnet_cidrs` | Map of subnet name to CIDR |

## Requirements

- Terraform >= 1.0
- Google Cloud SDK

## License

MIT