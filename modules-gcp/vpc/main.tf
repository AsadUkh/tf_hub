locals {
  vpc_cidr        = var.vpc_cidr
  subnets         = [for k in range(2) : cidrsubnet(local.vpc_cidr, 2, k)] # Create 2 subnets (1 private and 1 public)
  private_subnets = [local.subnets[0]]
  public_subnets  = [local.subnets[1]]
  subnet_names = {
    public_subnet_1  = "${var.vpc_name}-${var.region}-public-subnet-1"
    private_subnet_1 = "${var.vpc_name}-${var.region}-private-subnet-1"
  }
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = var.vpc_name

  subnets = [
    {
      subnet_name           = local.subnet_names.private_subnet_1
      subnet_ip             = local.private_subnets[0]
      subnet_region         = var.region
      subnet_private_access = true
    },
    {
      subnet_name   = local.subnet_names.public_subnet_1
      subnet_ip     = local.public_subnets[0]
      subnet_region = var.region
    }
  ]

  secondary_ranges = {
    (local.subnet_names.private_subnet_1) = [
      {
        range_name    = "${local.subnet_names.private_subnet_1}-pods"
        ip_cidr_range = "172.23.0.0/18"
      },
      {
        range_name    = "${local.subnet_names.private_subnet_1}-services"
        ip_cidr_range = "172.23.64.0/18"
      }
    ]
  }


  # routes = [
  #   {
  #     name              = "default-route-public"
  #     destination_range = "0.0.0.0/0"
  #     network           = var.vpc_cidr
  #     next_hop_gateway  = "default-internet-gateway"
  #   }
  # ]
  routes = [
    {
      name              = "egress-internet-default-route-public"
      description       = "route through IGW to access internet"
      tags              = "egress-inet"
      destination_range = "0.0.0.0/0"
      next_hop_internet = "true"
    }
  ]

  #### Firewall Rules
  firewall_rules = [
    {
      name      = "allow-ssh-ingress"
      direction = "INGRESS"
      ranges    = ["0.0.0.0/0"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    {
      name      = "allow-http-ingress"
      direction = "INGRESS"
      ranges    = ["0.0.0.0/0"]
      allow = [{
        protocol = "tcp"
        ports    = ["80"]
      }]
    },
    {
      name      = "allow-https-ingress"
      direction = "INGRESS"
      ranges    = ["0.0.0.0/0"]
      allow = [{
        protocol = "tcp"
        ports    = ["443"]
      }]
    },
    {
      name      = "allow-icmp-ingress"
      direction = "INGRESS"
      ranges    = ["0.0.0.0/0"]
      allow = [{
        protocol = "icmp"
      }]
    },
    {
      name      = "allow-all-egress"
      direction = "EGRESS"
      ranges    = ["0.0.0.0/0"]
      allow = [{
        protocol = "all"
      }]
  }]
}



####Conifuration for CloudNAT 


module "cloud_router_central" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"
  name    = "${var.project_id}-${var.region}-router"
  project = var.project_id
  network = module.vpc.network_name
  region  = var.region

  nats = [{
    name                               = "${var.project_id}-${var.region}-gateway"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetworks = [
      {
        name                     = module.vpc.subnets["${var.region}/${local.subnet_names.private_subnet_1}"].id
        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
        secondary_ip_range_names = module.vpc.subnets["${var.region}/${local.subnet_names.private_subnet_1}"].secondary_ip_range[*].range_name
      }
    ]
  }]
}
