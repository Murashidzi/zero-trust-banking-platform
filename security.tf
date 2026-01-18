# 1. Connect Terraform to the Kubernetes Cluster
provider "kubernetes" {
	host = module.eks.cluster_endpoint
	cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

	exec {
		api_version = "client.authentication.k8s.ip/v1beta1"
		command = "aws"
		# This only works if the aws cli is installed locally where terraform is executed.
		args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "af-south-1"]
	}
}

provider "helm" {
	kubernetes {
		host = module.eks.cluster_endpoint
		cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

		exec {
			api_version = "client.authentication.k8s.io/v1beta1"
			command = "aws"
			args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "af-south-1"]
		}
	}
}

# 2. Install OPA Gatekeeper usimg Helm
resource "helm_release" "gatekeeper" {
	name = "gatekeeper"
	repository = "https://open-policy-agent.github.io/gatekeeper/charts"
	chart = "gatekeeper"
	version = "3.14.0"
	namespace = "gatekeeper-system"
	create_namespace = true

	set {
		name = "replicas"
		value = "1" # Low cost mode (Prodcustion usually has 3)
	}
	# Wait for the cluster to be ready before trying to install
	depends_on = [module.eks]
}
