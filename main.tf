terraform {
  backend "s3" {
    bucket         = "terraform-state-devsecops-murashidzi"
    key            = "global/s3/terraform.tfstate"
    region         = "af-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# 1. The Network (VPC) - Restored
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = "devsecops-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["af-south-1a", "af-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Environment = "devsecops-simulation"
    Terraform   = "true"
  }
}

# 2. The Bank Vault (EKS Cluster) - Restored & Updated
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "devsecops-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Node Group (The Servers)
  eks_managed_node_groups = {
    bank_app_nodes = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # --- THE FIX: Grant Admin Access to YOU and the ROBOT ---
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # 1. The Robot (GitHub Actions)
    cluster_creator = {
      principal_arn = "arn:aws:iam::487123916182:role/github-actions-deployer"
      access_policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
    # 2. YOU (The Laptop User)
    my_laptop = {
      principal_arn = "arn:aws:iam::487123916182:user/terraform-admin"
      access_policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }
  # --------------------------------------------------------

  tags = {
    Environment = "devsecops-simulation"
    Terraform   = "true"
  }
}
