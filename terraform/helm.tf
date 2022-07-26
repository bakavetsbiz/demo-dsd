resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "4.9.16"
  namespace        = "argocd"
  create_namespace = true

  depends_on = [
    module.eks
  ]
}