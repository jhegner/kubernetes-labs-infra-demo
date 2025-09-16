echo "Install cert-manager to manage SSL certificates..."

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.10.1/cert-manager.yaml

sleep 15s

echo "Install the above Let's Encrypt issuers (staging and prod)"

kubectl apply -f letsencrypt.yaml

sleep 15s
