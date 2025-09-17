echo "Install the kubernetes-dashboard"

helm install k8s-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace "kubernetes-dashboard" -f dashboard-values.yaml

echo "😴 Aguardando..."
sleep 2m

echo "Install the cluster role binding for the admin user"

kubectl apply -f cluster-role-binding.yaml

echo "😴 Aguardando..."
sleep 15s

echo "Create the admin user service account"

kubectl apply -f service-account.yaml
