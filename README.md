# Zero Trust Cloud-Native Banking Platform 

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EKS_%7C_VPC_%7C_ECR-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Security](https://img.shields.io/badge/Security-Zero_Trust_%7C_OIDC-D91A2A?style=for-the-badge)

## Architecture Overview
This repository contains the complete Infrastructure as Code (IaC) and deployment manifests for a highly available, secure financial microservice. The infrastructure is provisioned on AWS using Terraform, leveraging an Elastic Kubernetes Service (EKS) cluster deployed within a custom Virtual Private Cloud (VPC).

The core philosophy of this project is **Security by Default** and **Zero Trust Architecture**. It eliminates hardcoded credentials, enforces least-privilege IAM access, and ensures strict container runtime security.

## Key Engineering & Security Decisions

### 1. Keyless CI/CD with OpenID Connect (OIDC)
**The Problem:** Storing long-lived AWS IAM Access Keys in GitHub Secrets creates a massive blast radius if the repository or CI/CD platform is compromised.

**The Solution:** Implemented AWS IAM Identity Center and OIDC integration with GitHub Actions. The deployment pipeline requests temporary, short-lived STS tokens for authentication, ensuring zero static credentials exist anywhere in the pipeline.

### 2. Network Isolation & Topology
**The Problem:** Exposing worker nodes to the public internet invites automated scanning and exploitation.

**The Solution:** Designed a custom VPC utilizing public and private subnets. The EKS worker nodes (`t3.small`) reside strictly in private subnets, utilizing a NAT Gateway for outbound artifact retrieval. Only the Kubernetes `LoadBalancer` Service is exposed to the public internet, acting as the sole ingress point.

### 3. Container Runtime Security Contexts
**The Problem:** Default container configurations often run as the `root` user, making container escape vulnerabilities catastrophic to the host node.

**The Solution:** Enforced strict Kubernetes `SecurityContext` rules at the Deployment level. The Flask banking application is forced to run as an unprivileged user (`runAsUser: 1000`, `runAsGroup: 3000`), mitigating the impact of potential application-layer compromises.

### 4. Immutable Infrastructure & Image Scanning
**The Problem:** Deploying untracked or vulnerable container images into a production cluster.

**The Solution:** Deployed a private Amazon Elastic Container Registry (ECR) via Terraform with `image_scanning_configuration { scan_on_push = true }` enabled. Kubernetes workloads pull strictly tagged, immutable image digests rather than relying on the volatile `:latest` tag.

## Repository Structure
```text
zero-trust-banking-platform/
├── .github/workflows/
│   └── deploy.yml              # CI/CD pipeline with AWS OIDC authentication
├── k8s-manifests/
│   ├── bank-deployment.yaml    # K8s Deployment (Replicas, SecurityContext, Liveness Probes)
│   └── bank-service.yaml       # K8s LoadBalancer Service for public ingress
├── terraform/
│   ├── main.tf                 # VPC networking & EKS Cluster module definitions (v1.29)
│   ├── ecr.tf                  # Private container registry definition
│   └── providers.tf            # AWS provider and remote S3/DynamoDB backend configuration
└── app/
    ├── app.py                  # Python Flask microservice (Bank Dashboard)
    └── Dockerfile              # Multi-stage, minimal attack surface container build
```

## Deployment Guide

### Prerequisites
* AWS CLI configured (for initial backend setup)
* Terraform `>= 1.5.0`
* `kubectl` configured

### 1. Infrastructure Provisioning
The infrastructure state is managed remotely via S3 with state locking handled by DynamoDB to prevent concurrent pipeline corruption.

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

### 2. Cluster Authentication
Once the EKS cluster is successfully provisioned, update your local kubeconfig using the AWS CLI. Note: Access entries are strictly managed via the `access_entries` block in `main.tf` to ensure explicit authorization mapping between IAM identities and RBAC.

```bash
aws eks update-kubeconfig --region af-south-1 --name devsecops-cluster
```

### 3. Application Deployment
Deploy the banking application to the worker nodes. The deployment utilizes a standard rolling update strategy ensuring zero downtime during updates.

```bash
kubectl apply -f k8s-manifests/
```

### 4. Teardown
To prevent ongoing AWS billing for the NAT Gateway and EKS Control Plane, tear down the environment:

```bash
kubectl delete svc bank-loadbalancer
terraform destroy --auto-approve
```
