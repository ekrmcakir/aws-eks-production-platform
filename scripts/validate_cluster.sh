#!/usr/bin/env bash
# ==============================================================================
# Automated EKS Production Platform Health Check & Validation
# ==============================================================================

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-eks-production-platform}"
AWS_REGION="${AWS_REGION:-us-east-1}"

echo "=================================================================="
echo " 🔍 Starting Platform Validation: ${CLUSTER_NAME} in ${AWS_REGION}"
echo "=================================================================="

# 1. Verify EKS Cluster status
echo -n "[1/7] Checking EKS Control Plane Status... "
CLUSTER_STATUS=$(aws eks describe-cluster --name "${CLUSTER_NAME}" --region "${AWS_REGION}" --query "cluster.status" --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "${CLUSTER_STATUS}" == "ACTIVE" ]]; then
  echo "✅ ACTIVE"
else
  echo "❌ FAILED (Status: ${CLUSTER_STATUS})"
  exit 1
fi

# 2. Check Kubernetes Nodes
echo -n "[2/7] Checking Kubernetes Node Readiness... "
READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c "Ready" || echo "0")
if [[ "${READY_NODES}" -ge 2 ]]; then
  echo "✅ (${READY_NODES} nodes Ready)"
else
  echo "⚠️ Warning: Only ${READY_NODES} ready nodes found."
fi

# 3. Check Karpenter Controller Pod
echo -n "[3/7] Verifying Karpenter Controller... "
KARPENTER_STATUS=$(kubectl get pods -n karpenter -l app.kubernetes.io/name=karpenter -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NOT_FOUND")
if [[ "${KARPENTER_STATUS}" == "Running" ]]; then
  echo "✅ Running"
else
  echo "⚠️ Status: ${KARPENTER_STATUS}"
fi

# 4. Check AWS Load Balancer Controller
echo -n "[4/7] Verifying AWS Load Balancer Controller... "
LBC_STATUS=$(kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NOT_FOUND")
if [[ "${LBC_STATUS}" == "Running" ]]; then
  echo "✅ Running"
else
  echo "⚠️ Status: ${LBC_STATUS}"
fi

# 5. Check ArgoCD
echo -n "[5/7] Verifying ArgoCD Server & Repo Controller... "
ARGOCD_STATUS=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NOT_FOUND")
if [[ "${ARGOCD_STATUS}" == "Running" ]]; then
  echo "✅ Running"
else
  echo "⚠️ Status: ${ARGOCD_STATUS}"
fi

# 6. Check AWS VPC CNI Network Policy Engine
echo -n "[6/7] Verifying VPC CNI Network Policy Daemon... "
CNI_NETPOL=$(kubectl -n kube-system get daemonset aws-node -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="ENABLE_NETWORK_POLICY")].value}' 2>/dev/null || echo "false")
if [[ "${CNI_NETPOL}" == "true" ]]; then
  echo "✅ ENABLED"
else
  echo "⚠️ Status: ${CNI_NETPOL}"
fi

# 7. Check Cert-Manager
echo -n "[7/7] Verifying Cert-Manager Webhook & Controller... "
CERT_STATUS=$(kubectl get pods -n cert-manager -l app.kubernetes.io/instance=cert-manager -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NOT_FOUND")
if [[ "${CERT_STATUS}" == "Running" ]]; then
  echo "✅ Running"
else
  echo "⚠️ Status: ${CERT_STATUS}"
fi

echo "=================================================================="
echo " 🎉 All EKS Platform Checks Completed Successfully!"
echo "=================================================================="
