echo "Create an Ingress... for backend service that refer to deployment/pod"

kubectl apply -f ingress.yaml

sleep 15s

echo "List the newly created ingress"

kubectl get ingress

sleep 15s

echo "Check the certificates"

kubectl get certificates

