module "vpc" {
	source = "terraform-aws-modules/vpc/aws"
	version = "5.5.1"

	name = "devsecops-vpc"
	cidr = "10.0.0.0/16"

	azs	= ["af-south-1a", "af-south-1b"]
	private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
	public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

	#Gotta use only one NAT Gateway to save money (being broke sucks).
	# Instead of using 1 per zone. This saves ~R1k/ month in a real organization.
	enable_nat_gateway = true
	single_nat_gateway = true
	enable_vpn_gateway = false

	# DNS Support (for EKS)
	enable_dns_hostnames = true
	enable_dns_support = true

	#Tags (for EKS to know where where to put load Balancers)
	public_subnet_tags = {
		"kubernetes.io/role/elb" = 1
	}
	
	private_subnet_tags = {
		"kubernetes.io/role/internal-elb" = 1
	}

	tags = {
		Environment = "devsecops-simulation"
		Terraform = "true"
	}
}
		
