# This variables file has the following sections, just search for the name
# 1. AWS Provider Variables
# 2. General Variables
# 3. VPC Variables



# AWS Provider Variables
variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "eu-west-2"
}

# General Variables
variable "resource_prefix" {
  description = "Suffix for built resources."
  type        = string
  default     = "fis_demo_1"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}


locals {
  subnet_cidr_ranges = [for i in range(length(data.aws_availability_zones.available_azs.names)) : "10.0.${i}.0/24"]
  az_count           = length(local.subnet_cidr_ranges)
}
