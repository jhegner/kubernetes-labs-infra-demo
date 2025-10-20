#!/bin/bash
set -e

echo "✨ Install deps for k3d local env via script"

# Create namespace for k3d local env

echo "🔧 Criando namespace para k3d local env"
kubectl apply -f ../ns/namespaces.yaml
echo "😴 Aguardando..."
sleep 5s
echo "✅ Namespace criado com sucesso"

# Install ArgoCD in the cluster manually
echo "🐙 Installing ArgoCD in the cluster manually"

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "😴 Aguardando..."
sleep 15s
kubectl get pods -n argocd
echo "✅ ArgoCD installed successfully"

# Get the initial admin password and port-forward the ArgoCD server to localhost:8085
echo "🔑 Running the command to get the initial admin password:"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
echo "😴 Aguardando..."
sleep 2s

# Information for the user to login
echo "👨🏾‍💻 Then, open your browser and navigate to https://localhost:8085"
echo "Login: admin"
echo "Password: (the password you retrieved earlier)"
echo "Running command to port-forward in another terminal the ArgoCD server to localhost:8085"
echo ""
echo ""
echo "command: [kubectl port-forward svc/argocd-server -n argocd 8085:443]"
echo ""
echo ""

# Create Docker registry secret in ArgoCD namespace
kubectl create secret docker-registry vultr-registry-secret \
  --docker-server=$CONTAINER_REGISTRY_URL \
  --docker-username=$CONTAINER_REGISTRY_USERNAME \
  --docker-password=$CONTAINER_REGISTRY_PASSWORD \
  --docker-email=$EMAIL1 \
  -n argocd 

# Apply application manifest to ArgoCD
echo "⏳ Applying application manifest to ArgoCD"
kubectl apply -f ../argo-apps
echo "😴 Aguardando..."
sleep 10s
echo "✅ Application manifest applied. You can now manage your application through the ArgoCD UI."

# ---

echo "Ends the install process of deps for k3d local env via script"