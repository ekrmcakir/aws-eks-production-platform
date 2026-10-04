#!/usr/bin/env bash
# ==============================================================================
# End-to-End Automated Deployment Script for EKS Platform
# ==============================================================================

set -euo pipefail

echo "=================================================================="
echo " 🚀 Bootstrapping AWS EKS Production Platform"
echo "=================================================================="

# Step 1: Terraform Infrastructure
echo "==> Step 1: Initializing and Applying Terraform IaC"
cd "$(dirname "$0")/../terraform"
terraform init -upgrade
terraform validate
terraform apply -var-file=terraform.tfvars -auto-approve

# Step 2: Update Kubeconfig
echo "==> Step 2: Updating local kubeconfig"
CLUSTER_NAME=$(terraform output -raw cluster_name)
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}"

# Step 3: Apply GitOps Root Application
echo "==> Step 3: Bootstrapping ArgoCD App-of-Apps GitOps Hierarchy"
kubectl apply -f ../gitops/bootstrap/root-app.yaml

echo "=================================================================="
echo " ✅ AWS EKS Platform Successfully Provisioned and Reconciled!"
echo "=================================================================="
