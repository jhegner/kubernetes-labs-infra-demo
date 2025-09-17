echo "Expoe URL dashboard para acesso fora do cluster..."

kubectl apply -f service-lb.yaml

echo "😴..."

sleep 15s

echo "Aguarda o provisionamento do loadbalancer da cloud com IP externo"

kubectl get services kubernetes-dashboard-lb -n kubernetes-dashboard -w


