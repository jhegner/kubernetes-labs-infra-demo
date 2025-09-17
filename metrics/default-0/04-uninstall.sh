echo "Remove os recursos provisionados"

kubectl delete svc kubernetes-dashboard-lb -n kubernetes-dashboard
kubectl delete serviceaccount admin-user -n kubernetes-dashboard
kubectl delete clusterrolebinding admin-user -n kubernetes-dashboard
kubectl delete service/metrics-server -n kube-system
kubectl delete deployment.apps/metrics-server -n kube-system
kubectl delete namespace kubernetes-dashboard

helm uninstall kubernetes-dashboard -n kubernetes-dashboard

echo "Limpo..."