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