data "aws_route53_zone" "this" {
  name = var.aws_domain_name
}

data "aws_availability_zones" "available" {
  state = "available"
}
