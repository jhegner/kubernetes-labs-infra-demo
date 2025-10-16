#!/bin/bash
set -e  

echo "🐙 Installing ArgoCD in the cluster manually"

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "😴 Aguardando..."
sleep 15s

kubectl get pods -n argocd

echo "🚀 Argocd installed..."