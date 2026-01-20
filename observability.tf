# Add the Prometheus Community Repository (Kinda like adding a new appstore to a phone).
resource "helm_release" "prometheus_stack" {
	name = "prometheus-stack"
	repository = "https://prometheus-community.github.io/helm-charts"
	chart = "kube-prometheus-stack"
	version = "56.0.0" #Locking version for stability
	namespace = "monitoring"
	create_namespace = true
	# More time
	timeout = 900

	# Configuration (Save money and resources)
	# "High Availability" features will be off in this tab even though they would be left on Prodcution
	# Disable alert manager (saves ~ 200MB RAM)
	set {
		name = "alertmanager.enabled"
		value = "false"
	}	

	#Shrink Prometheus (the database)

	set {
		name = "prometheus.prometheusSpec.replicas"
		value = "1"
	}

	set {
		name = "alertmanager.alertmanagerSpec.replicas"
		value = "1"
	}

	# Set a password for the Grafana Login
	set {
		name = "grafana.adminPassword"
		value = "admin123" # This should never be done in Production... one should always use AWS Secrets Manager
	}
	
	# Shrink Prometheus to fit on t3.small
	set {
		name = "prometheus.prometheusSpec.resources.requests.memory"
		value = "128Mi"
	}
	set {
		name = "prometheus.prometheusSpec.resources.requests.cpu"
		value = "50m"
	}
	set {
		name = "grafana.resources.requests.memory"
		value = "64Mi"
	}
	set {
		name = "grafana.resources.requests.cpu"
		value = "50m"
	}

	# Wait for the cluster to be ready
	depends_on = [module.eks]
}
