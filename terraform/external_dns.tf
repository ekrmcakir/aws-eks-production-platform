# ==============================================================================
# ExternalDNS for Automated Route53 Record Synchronization
# ==============================================================================

resource "aws_iam_role" "external_dns_role" {
  name = "${var.cluster_name}-external-dns-irsa"

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
          "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:external-dns"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "${var.cluster_name}-external-dns-policy"
  description = "Allows ExternalDNS to manage Route53 hosted zones"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["route53:ChangeResourceRecordSets"]
        Effect   = "Allow"
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  policy_arn = aws_iam_policy.external_dns_policy.arn
  role       = aws_iam_role.external_dns_role.name
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.14.4"
  namespace  = "kube-system"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns_role.arn
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "source[0]"
    value = "ingress"
  }

  depends_on = [
    aws_eks_node_group.system_nodes,
    aws_iam_role_policy_attachment.external_dns_attach
  ]
}
