ArgoCD:

helm repo add argo https://argoproj.github.io/argo-helm

helm install argo-cd argo/argo-cd --version 4.9.16 -n argocd --create-namespace


