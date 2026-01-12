module "eks" {
	source = "terraform-aws-modules/eks/aws"
	version = "20.2.1"

	cluster_name = "devsecops-cluster"
	cluster_version = "1.29"

	#Networking (Putting the cluster in the VPC we created)
	vpc_id = module.vpc.vpc_id
	subnet_ids = module.vpc.private_subnets

	#Security (Allowing public access so we cab run kubectl from our machine)
	cluster_endpoint_public_access = true

	# The 'Worker Nodes'  (The actual servers) 
	eks_managed_node_groups = {
		bank_app_nodes = {
			# Instance Type: t3.medium (Minimum size for EKS)
			# Cost: ~$0.0h/hour per node + $0.10/hr for the cluster... gotta close quick
			instance_types = ["t3.small"]
	
			min_size = 1
			max_size = 2
			desired_size = 1
		}
	}

	# Grant US admin permissions
	enable_cluster_creator_admin_permissions = true
	
	tags = {
		Environment = "devsecops-simulation"
		Terraform = "true"
	}
}
		
