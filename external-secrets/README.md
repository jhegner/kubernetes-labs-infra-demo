# ⚠️ Execute (na ordem) :
```
helm_install.sh # script para instalação do external secrets e criacao do namespace
kubectl apply -f overlays/cloud/aws-credentials.yaml
kubectl apply -f base/secretstore.yaml
kubectl apply -f base/externalsecret.yaml
kubectl apply -f base/deployment.yaml
```

```
# kubectl apply -k overlays/local
# kubectl apply -k overlays/cloud
```

# Utils

```
 kubectl.exe describe externalsecret.external-secrets.io/mock-api-secret -n external-secrets
```