# Cpny-Terraform-Infra

It's a terraform configuration for bootstraping AWS infrastructure
for a containerized web application. As result It provides VPC, ECR,
EKS cluster and respective IAM policies, roles and network ACL definitions.

## Prerequisites

It requires:
* Terraform, version ~> 1.2
* kubectl, version ~> 1.22
* awscli2, version ~> 2.7

AWS cli should be preconfigured to have an access with permissions to deploy VPCs,
EKS clusters, and IAM policies/roles.

## Configuration Settings

Before applying the configuration it should be adopted to your environment.
A file `default.auto.tfvars` contains all parameters that should be adopted to
your requirements.
Strongly recommended to ensure that AWS CLI default region is the same as a region
provided within the configuration parameters. If it's not the same you can change
the default region for certain terminal session by environment variable AWS_REGION.

## Deploy The Infrastructure

1. Ensure that values in `default.auto.tfvars` matches your requirements
2. Ensure that you have respective access to AWS by command `aws sts get-caller-identity`
3. Ensure that a region where you deloy the infrastructure have a free slot for creating VPC
4. Make initialization of a terraform environment - `terraform init`
5. Ensure that there is no issues in the configuration `terraform plan`
6. Make deployment with command `terraform apply`
