aws_region         = "eu-west-1"
aws_domain_name    = "object01.xyz."
aws_domain_zone_id = "Z02980861JZUO0UJ6A5R2"
aws_vpc_cidr_block = "10.1.0.0/16"
aws_eks_cidr_block = "172.20.0.0/16"

aws_iam_rolepolicy_prefix = "CPNY"

redundancy_factor = 2
management_access_list = [
  "147.235.151.207/32" // Home Router
]

application = {
  name   = "webapp"
  images = ["web", "api"]
}
