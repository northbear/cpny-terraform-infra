variable "aws_region" {
  type        = string
  description = "AWS region to deploy a infrastructure"
}

variable "aws_domain_name" {
  type        = string
  description = "Domain name managed by Route53 used for infrastructure public resources"
}

variable "aws_domain_zone_id" {
  type        = string
  description = "AWS domain zone id that responsible for domain name provided as aws_domain_name"
}

variable "aws_vpc_cidr_block" {
  type        = string
  description = "CIDR block used for infrastructure VPC"
}

variable "aws_eks_cidr_block" {
  type        = string
  description = "CIDR block used for EKS cluster"
}

variable "redundancy_factor" {
  type        = number
  description = "number of subnets with the same role for allocation"
}

variable "management_access_list" {
  type        = list(string)
  description = "list of IPs allowed to access to the infrastructure management public subnets"
}

variable "aws_iam_rolepolicy_prefix" {
  type        = string
  description = "A prefix that should be added to custom roles and policies to distinguish with native one"
}

variable "application" {
  type        = object({
    name = string
    images = list(string)
  })
  description = "An applicaiton definition for name and set of images"
}
