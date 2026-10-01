# ==============================================================================
# EKS Managed Add-ons & Zero-Trust AWS VPC CNI Network Policy Configuration
# ==============================================================================

# IAM Role for AWS VPC CNI (IRSA)
resource "aws_iam_role" "vpc_cni_role" {
  name = "${var.cluster_name}-vpc-cni-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-node"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni_role.name
}

# AWS VPC CNI with Native Network Policy Engine enabled
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.18.1-eksbuild.3"
  service_account_role_arn    = aws_iam_role.vpc_cni_role.arn
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    enableNetworkPolicy = "true"
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })

  depends_on = [aws_eks_node_group.system_nodes]
}

# CoreDNS Addon
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "coredns"
  addon_version               = "v1.11.1-eksbuild.9"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_addon.vpc_cni]
}

# Kube-Proxy Addon
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.30.0-eksbuild.3"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.system_nodes]
}

# IAM Role for AWS EBS CSI Driver
resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.cluster_name}-ebs-csi-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role.name
}

# AWS EBS CSI Driver Addon
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.31.0-eksbuild.1"
  service_account_role_arn    = aws_iam_role.ebs_csi_role.arn
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.system_nodes]
}
