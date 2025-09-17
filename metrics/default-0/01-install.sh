echo "Installing metrics server..."

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo "😴..."

sleep 15s

echo "Installing the web UI (Kubernetes Dashboard)..."

echo "Add kubernetes-dashboard repository"

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

echo "Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart"

helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

echo "😴..."

sleep 2m

# -- Apenas se local utilizando minikube
# echo "Enable access to the Dashboard"
#kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443


echo "Metrics server e dash instalados"