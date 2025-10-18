echo "Uninstalling ArgoCD from the cluster manually"

kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
