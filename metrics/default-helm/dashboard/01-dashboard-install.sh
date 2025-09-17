echo "Add kubernetes-dashboard repository"

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

helm repo update

echo "😴 Aguardando..."
sleep 15s

echo "Create a namespace for the kubernetes dashboard"

kubectl create ns "kubernetes-dashboard"

kubectl get namespaces
