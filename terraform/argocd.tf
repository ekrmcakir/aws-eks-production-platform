# ==============================================================================
# ArgoCD Continuous Delivery & GitOps Engine
# ==============================================================================

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version
  namespace        = "argocd"
  create_namespace = true

  values = [
    yamlencode({
      server = {
        extraArgs = ["--insecure"]
        metrics = {
          enabled = true
        }
      }
      repoServer = {
        metrics = {
          enabled = true
        }
      }
      controller = {
        metrics = {
          enabled = true
        }
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]

  depends_on = [aws_eks_node_group.system_nodes]
}
