echo "✅ Application manifest applied. You can now manage your application through the ArgoCD UI."

kubectl apply -f argocd-app.yaml

sleep 10s

echo "⏳ Waiting for the application to be fully synchronized..."
