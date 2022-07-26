locals {
  argocd = {
    namespace = "argocd"
  }
  initial_bootstrap = {
    repoURL               = "https://github.com/bakavetsbiz/demo-dsd.git"
    targetRevision        = "main"
    destination_namespace = "argocd"
    source_path           = "k8s/infrastructure/applications/"
  }
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "4.9.16"
  namespace        = local.argocd.namespace
  create_namespace = true

  depends_on = [
    module.eks
  ]
}

resource "kubectl_manifest" "initial_bootstrap" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: initial-bootstrap
  namespace: ${local.argocd.namespace}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    path: ${local.initial_bootstrap.source_path}
    repoURL: ${local.initial_bootstrap.repoURL}
    targetRevision: ${local.initial_bootstrap.targetRevision}

    helm:
      parameters:
      - name: targetRevision
        value: ${local.initial_bootstrap.targetRevision}
      - name: certManager_sa_eks_role_arn
        value: ${module.iam_assumable_role_admin_cert_manager.iam_role_arn}

  destination:
    namespace: ${local.argocd.namespace}
    server: https://kubernetes.default.svc

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: -1
YAML

  depends_on = [
    helm_release.argocd
  ]
}