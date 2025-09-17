echo "Remove os recursos provisionados"

helm uninstall k8s-dashboard -n kubernetes-dashboard

echo "😴 Aguardando..."
sleep 15s

kubectl delete namespace kubernetes-dashboard

echo "Limpo..."