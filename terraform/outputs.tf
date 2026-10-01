output = {
  vpc_id = {
    description = "The ID of the provisioned VPC"
    value       = aws_vpc.eks_vpc.id
  }
  private_subnets = {
    description = "List of IDs of private subnets"
    value       = aws_subnet.private[*].id
  }
  public_subnets = {
    description = "List of IDs of public subnets"
    value       = aws_subnet.public[*].id
  }
  cluster_name = {
    description = "The name of the EKS cluster"
    value       = aws_eks_cluster.eks.name
  }
  cluster_endpoint = {
    description = "Endpoint for EKS control plane"
    value       = aws_eks_cluster.eks.endpoint
  }
  cluster_oidc_issuer_url = {
    description = "The URL on the EKS cluster for the OpenID Connect identity provider"
    value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  }
  karpenter_node_role_arn = {
    description = "IAM role ARN assumed by Karpenter provisioned EC2 instances"
    value       = aws_iam_role.karpenter_node.arn
  }
  karpenter_queue_name = {
    description = "Name of the SQS queue used for Karpenter spot interruption handling"
    value       = aws_sqs_queue.karpenter_interruption.name
  }
}
