variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Used to name all resources consistently"
  type        = string
  default     = "zero-downtime-cicd"
}

variable "common_tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default = {
    Project     = "zero-downtime-cicd"
    ManagedBy   = "Terraform"
    Owner       = "DeviSharanya"
  }
}
