#!/bin/bash
set -e  

echo "🔑 Running the command to get the initial admin password:"

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo

sleep 2s

echo "👨🏾‍💻 Then, open your browser and navigate to https://localhost:8085"
echo "Login: admin"
echo "Password: (the password you retrieved earlier)"

echo "🔄 Running command to port-forward the ArgoCD server to localhost:8085"

kubectl port-forward svc/argocd-server -n argocd 8085:443
