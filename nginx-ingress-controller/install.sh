echo "Installing service who-ami..."

kubectl apply -f service-02.yaml

sleep 15s

echo "Install NGINX Ingress Controller (ingress-nginx)"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml

echo "Waiting for IP of the newly created Load Balancer..."

kubectl get services ingress-nginx-controller -n ingress-nginx -w

