locals {
  workload_subnets = {
    az_base = 0 * var.redundancy_factor
    ip_base = 10
  }
  management_subnets = {
    az_base = 1 * var.redundancy_factor
    ip_base = 20
  }
  public_subnets = {
    az_base = 2 * var.redundancy_factor
    ip_base = 30
  }
  zones_count = length(data.aws_availability_zones.available.zone_ids)
}

resource "aws_vpc" "this" {
  cidr_block = var.aws_vpc_cidr_block
  tags = {
    Name = "HomeAssignment"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "GW_HomeAssignment"
  }
}
resource "aws_route" "igw" {
  route_table_id         = aws_vpc.this.main_route_table_id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "workload" {
  count = var.redundancy_factor

  vpc_id     = aws_vpc.this.id
  cidr_block = "10.1.${local.workload_subnets.ip_base + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[
    (local.workload_subnets.az_base + count.index) % local.zones_count
  ]

  tags = {
    Name = "Workload"
  }
}

resource "aws_eip" "nat_workload" {
  vpc = true

  tags = {
    Name = "nat_workload_ip"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "workload" {
  allocation_id = aws_eip.nat_workload.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "nat_workload"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "workload_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.workload.id
  }

  tags = {
    Name = "workload_rt"
  }
}

resource "aws_route_table_association" "workload" {
  count = length(aws_subnet.workload)

  subnet_id      = aws_subnet.workload[count.index].id
  route_table_id = aws_route_table.workload_rt.id
}

resource "aws_subnet" "management" {
  count = var.redundancy_factor

  vpc_id     = aws_vpc.this.id
  cidr_block = "10.1.${local.management_subnets.ip_base + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[
    (local.management_subnets.az_base + count.index) % local.zones_count
  ]

  map_public_ip_on_launch = true

  tags = {
    Name = "Management"
  }
}

resource "aws_subnet" "public" {
  count = var.redundancy_factor

  vpc_id     = aws_vpc.this.id
  cidr_block = "10.1.${local.public_subnets.ip_base + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[
    (local.public_subnets.az_base + count.index) % local.zones_count
  ]

  map_public_ip_on_launch = true

  tags = {
    Name = "Public"
  }
}

resource "aws_network_acl" "management" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.management[*].id
}

resource "aws_network_acl_rule" "vpc_to_mgmt" {
  network_acl_id = aws_network_acl.management.id
  rule_number    = 100
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
}

resource "aws_network_acl_rule" "mgmt_to_vpc" {
  network_acl_id = aws_network_acl.management.id
  rule_number    = 100
  egress         = true
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = aws_vpc.this.cidr_block
}

resource "aws_network_acl_rule" "management_access" {
  count = length(var.management_access_list)

  network_acl_id = aws_network_acl.management.id
  rule_number    = 200 + 10 * count.index
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = var.management_access_list[count.index]
}

# resource "aws_network_acl_rule" "allow_all_from_mgmt" {
#   count = length(var.management_access_list)

#   network_acl_id = aws_network_acl.management.id
#   rule_number    = 100
#   egress         = false
#   protocol       = "all"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
# }

output "nat_gateway_workload" {
  value = aws_eip.nat_workload.public_ip
}
