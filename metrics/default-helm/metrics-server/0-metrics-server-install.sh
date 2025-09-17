echo "Add the Helm repository for the Metrics server"

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

helm repo update

echo "😴 Aguardando..."
sleep 15s

echo "Create a namespace for the Metrics server"

kubectl create ns metrics-server

kubectl get namespaces
