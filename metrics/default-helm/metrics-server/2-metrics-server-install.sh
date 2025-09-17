echo "Deploy the Metrics server to Kubernetes..."

helm install metrics-server metrics-server/metrics-server -n  metrics-server \
    --values metrics-server.values

echo "😴 Aguardando..."
sleep 15s

helm ls -n metrics-server

echo "😴 Aguardando..."
sleep 15s

kubectl get all -n metrics-server

echo "Verify the resource usage at the cluster level"

kubectl top nodes

