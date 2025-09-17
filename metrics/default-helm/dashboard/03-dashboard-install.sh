echo "List the resources in the kubernetes-dashboard namespace"
kubectl get all -n kubernetes-dashboard

echo "Create a LoadBalancer service for the kubernetes dashboard"
kubectl apply -f service-lb.yaml

echo "😴 Aguardando..."
sleep 5m

ip_externo=$(kubectl get svc k8s-dashboard-lb -n kubernetes-dashboard -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Access the dashboard at: https://$ip_externo/"

token=$(kubectl -n kubernetes-dashboard create token admin-user)
echo "Token for dashboard access: $token"


