# 3-Tier AWS VPC with NAT Gateways using Terraform

![AWS pic](/AWS-VPC-3-Tier.png)

## Introduction

### !! This repo is ONLY for learning purposes. You must provide YOUR own AWS Credentials in order to use the Terraform configuration !!

### [Download the repository](https://github.com/DobriJS/Terraform-AWS-VPC-3-Tier-Architecture.git)

- Learn about [Terraform Registry and Modules](https://registry.terraform.io/)
- Learn about [VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)

## Executing Terraform Commands

```t
# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform plan
terraform plan

# Terraform Apply
terraform apply -auto-approve

# Terraform Destroy
terraform destroy -auto-approve
```

## Configuration files content

### Input Variables

#### generic-variables.tf

```t
# Input Variables

# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  type        = string
  default     = ""
  description = "AWS Access Key"
  sensitive   = true
}

variable "secret_key" {
  type        = string
  default     = ""
  description = "AWS Secret Key"
  sensitive   = true
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}
# Business Division
variable "business_division" {
  description = "Business division name"
  type        = string
  default     = "SpaceX"
}
```

#### local-values.tf

- Learn more about [Local Values](https://www.terraform.io/docs/language/values/locals.html)

```t
locals {
  owners = var.business_divsion
  environment = var.environment
  name = "${var.business_divsion}-${var.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
}
```

#### terraform.tfvars

```t
# Generic Variables
aws_region        = "us-east-1"
access_key        = ""
secret_key        = ""
environment       = "stag"
business_division = "Some Division in the corp."
```

#### vpc-variables.tf

```t
# VPC Input Variables

# VPC Name
variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "myvpc"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

# VPC Availability Zones
variable "vpc_availability_zones" {
  description = "VPC Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# VPC Public Subnets
variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# VPC Private Subnets
variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# VPC Database Subnets
variable "vpc_database_subnets" {
  description = "VPC Database Subnets"
  type        = list(string)
  default     = ["10.0.151.0/24", "10.0.152.0/24"]
}

# VPC Create Database Subnet Group (True / False)
variable "vpc_create_database_subnet_group" {
  description = "VPC Create Database Subnet Group"
  type        = bool
  default     = true
}

# VPC Create Database Subnet Route Table (True or False)
variable "vpc_create_database_subnet_route_table" {
  description = "VPC Create Database Subnet Route Table"
  type        = bool
  default     = true
}


# VPC Enable NAT Gateway (True or False)
variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
  default     = true
}

# VPC Single NAT Gateway (True or False)
variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type        = bool
  default     = true
}
```

#### vpc-module.tf

```t
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  # VPC Basic Details
  name            = "${local.name}-${var.vpc_name}"
  cidr            = var.vpc_cidr_block
  azs             = var.vpc_availability_zones
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  # Database Subnets
  database_subnets                       = var.vpc_database_subnets
  create_database_subnet_group           = var.vpc_create_database_subnet_group
  create_database_subnet_route_table     = var.vpc_create_database_subnet_route_table
  create_database_internet_gateway_route = true
  create_database_nat_gateway_route      = true

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags     = local.common_tags
  vpc_tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "Public Subnets"
  }
  private_subnet_tags = {
    Type = "Private Subnets"
  }
  database_subnet_tags = {
    Type = "Private Database Subnets"
  }
}
```

#### vpc-outputs.tf

```t
# VPC Output Values

# VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# VPC CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# VPC Private Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

# VPC Public Subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# VPC NAT gateway Public IP
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# VPC AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.azs
}
```

#### vpc.auto.tfvars

```t
# VPC Variables
vpc_name = "myvpc"
vpc_cidr_block = "10.0.0.0/16"
vpc_availability_zones = ["us-east-1a", "us-east-1b"]
vpc_public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_database_subnets= ["10.0.151.0/24", "10.0.152.0/24"]
vpc_create_database_subnet_group = true
vpc_create_database_subnet_route_table = true
vpc_enable_nat_gateway = true
vpc_single_nat_gateway = true
```

## Clean-Up

#### Don't forget to clean up all the created resources to save money on your account !

```t
terraform destroy -auto-approve
```
