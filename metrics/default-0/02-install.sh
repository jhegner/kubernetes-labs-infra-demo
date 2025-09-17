echo "Installing service account..."

kubectl apply -f service-account.yaml

echo "😴..."

sleep 15s

echo "Installing cluster role-binding..."

kubectl apply -f cluster-role-binding.yaml

echo "😴..."

sleep 15s

echo "Getting a Bearer Token for ServiceAccount"

kubectl -n kubernetes-dashboard create token admin-user
