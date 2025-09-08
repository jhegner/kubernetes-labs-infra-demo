echo "Installing External Secrets Operator via Helm..."

helm repo add external-secrets https://charts.external-secrets.io

helm install demo-external-secrets external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true

echo "External Secrets Operator installation complete."