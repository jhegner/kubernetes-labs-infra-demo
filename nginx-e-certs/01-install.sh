echo "Installing deployment who-ami"

kubectl apply -f deployment.yaml

sleep 15s

echo "Installing service who-ami..."

kubectl apply -f service.yaml

sleep 15s

echo "Install NGINX Ingress Controller (ingress-nginx)"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml

echo "Waiting for IP of the newly created Load Balancer..."

kubectl get services ingress-nginx-controller -n ingress-nginx -w

sleep 15s

# (Manual) - Create an A record in your domain DNS that points to the above IP EXTERNAL-IP
# labs.nercode.com.br

# (Optional) Scale NGINX Ingress Controller to 03 replicas.
#  kubectl scale deployment --namespace ingress-nginx ingress-nginx-controller --replicas=3 

# sleep 15s

