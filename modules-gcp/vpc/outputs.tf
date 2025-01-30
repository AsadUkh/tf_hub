# Outputs
output "network_name" {
  value = module.vpc.network_name
}

output "private_subnetwork_name" {
  value = local.subnet_names.private_subnet_1
}

output "public_subnetwork_name" {
  value = local.subnet_names.public_subnet_1
}

output "subnets_secondary_ranges" {
  value = module.vpc.subnets_secondary_ranges
}


output "secondary_ip_range_names" {
  value = tomap({
    for subnet_name, ranges in module.vpc.subnets_secondary_ranges :
    subnet_name => [for range in ranges : range["range_name"]]
  })
}
