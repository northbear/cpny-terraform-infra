locals {
  application_name     = var.application.name
  app_name_capitalized = trimspace(title(local.application_name))
  images_list          = var.application.images
}

resource "aws_ecr_repository" "app" {
  count = length(local.images_list)
  # for_each = toset(local.images_list)

  name                 = "webapp/${local.images_list[count.index]}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_iam_policy" "app_ecr_rw" {
  name        = "${var.aws_iam_rolepolicy_prefix}Ecr${local.app_name_capitalized}ReadWritePolicy"
  path        = "/"
  description = "ECR ReadWrite policy for ${local.application_name} application"

  policy = file("files/aws-ecr-webapp-readwrite-policy.json")
}

output "app_ecr_urls" {
  value = [for ecr in aws_ecr_repository.app : ecr.repository_url]
}
