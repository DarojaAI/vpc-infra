# Contributing to vpc-infra

See [DarojaAI/.github/CONTRIBUTING.md](https://github.com/DarojaAI/.github/blob/main/CONTRIBUTING.md) for organization-wide guidelines.

## This Repo: VPC Infrastructure on Google Cloud

This repository provides a reusable Terraform module for Google Cloud VPC infrastructure including:
- VPC network
- Cloud NAT for egress
- Serverless VPC Access connector

### Setup

```bash
# Install Terraform
terraform version  # Should be ≥1.5.0

# Install pre-commit hooks
pip install pre-commit
pre-commit install
```

### Module Usage

This is a **reusable module**. To use it in another project:

```hcl
module "vpc" {
  source = "git::https://github.com/DarojaAI/vpc-infra.git//terraform?ref=v1.0.5"
  
  project_id = var.project_id
  region     = var.region
  # See terraform/variables.tf for all options
}

output "vpc_connector_name" {
  value = module.vpc.vpc_connector_name
}
```

### Development

```bash
# Validate locally
terraform -chdir=terraform validate

# Format
terraform fmt -recursive terraform/

# Pre-commit check
pre-commit run --all-files
```

### Release Process

1. **Test changes** with dependent projects
2. **Bump version** in `package.json`
3. **Create PR** with test results
4. **Merge** → GitHub Actions auto-tags and releases

### Important

- **This is a module** — always test in a dependent project before releasing
- **No terraform state** should be committed here
- **Version tags** match release versions (e.g., v1.0.5)
- **Breaking changes** require MAJOR version bump

---

For questions, see [GOVERNANCE.md](https://github.com/DarojaAI/.github/blob/main/GOVERNANCE.md)
