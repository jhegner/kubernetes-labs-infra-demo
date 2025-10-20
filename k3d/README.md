# 🚀 k3d Local Environment Setup

This guide explains how to set up and use k3d for local Kubernetes development. k3d is a lightweight wrapper to run k3s (Rancher Lab's minimal Kubernetes distribution) in docker.

## 📋 Prerequisites

- 🐳 Docker installed and running
- 🎮 kubectl CLI tool installed
- 🔧 k3d installed (`curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash`)

## 📁 Project Structure

```tree
k3d/
├── applications/
│   └── app-micronout.yaml    # ArgoCD application manifest
├── infra/
│   └── kubernetes.yaml       # Main Kubernetes resources
├── ns/
│   └── namespaces.yaml      # Namespace definitions
└── scripts/
    └── install.sh           # Installation automation script
```

## ⚡ Quick Start

1. Create a k3d registry:

```bash
k3d registry create mylocal-registry \
    --port 5000 \
    --proxy-remote-url "https://..." \
    --proxy-username "123..." \
    --proxy-password "456..."
```

2. See running

```bash
k3d registry list

NAME                 ROLE       CLUSTER   STATUS
mylocal-registry     registry             running

```

3. Create a k3d cluster:

```bash
k3d cluster create labs-single-cluster \
    --servers 1 \
    --registry-use k3d-vultr-registry:5000 \
```

4. Run the installation script:

```bash
cd scripts
chmod +x install.sh
./install.sh
```

## 🔧 Available Resources

### 🏷️ Namespaces

The project defines two namespaces:

- `k3dlocal`: Main namespace for local development
- `argocd`: Namespace for ArgoCD deployment

### 📱 Applications

The environment includes:

- **app-micronout**: A Micronaut-based application managed by ArgoCD
  - Configured with auto-sync
  - Creates namespace automatically
  - Includes self-healing and pruning

### 🏗️ Infrastructure Components

The `kubernetes.yaml` includes:

- ConfigMap with mock API configuration
- Deployment configuration:
  - 3 replicas
  - Resource limits:
    - Memory: 800Mi (limit), 400Mi (request)
    - CPU: 500m (limit)
  - Uses Vultr container registry image

## 🔐 ArgoCD Access

After installation:

1. Access ArgoCD UI at `http://localhost:8085`

2. Login credentials:
   - Username: `admin`
   - Password: Retrieved during installation (check script output)

3. Configure ArgoCD ConfigMap for registry:

```bash
kubectl edit configmap argocd-cm -n argocd

# ... adicionar - se for Docker/OCI registry, usar:

data:
  repositories: |
    - name: myprivrepo
      type: docker
      url: registry.example.com
      username: SEU_USUARIO
      password: SEU_TOKEN

# reiniciar

kubectl rollout restart deploy -n argocd

```

## 🛠️ Useful Commands

```bash
# Check cluster status
kubectl cluster-info

# Get all resources in k3dlocal namespace
kubectl get all -n k3dlocal

# Check ArgoCD application status
kubectl get applications -n argocd

# Port forward ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8085:443
```

## ❗ Troubleshooting

1. If ArgoCD UI is not accessible:
   - Verify the port-forward is running
   - Check ArgoCD pods are running: `kubectl get pods -n argocd`

2. If application doesn't sync:
   - Check application status: `kubectl get application -n argocd`
   - View application logs: `kubectl logs -n argocd <application-pod-name>`

3. Docker local testing:

   ```bash
   docker run --env-file ./env/config.env \
     -p 8080:8080 \
     ewr.vultrcr.com/kuberneteslabcontainerregistry/kubernetes-labs-app-micronout:develop
   ```

## 🔄 Port Forward

```bash
# Argo URL
kubectl port-forward svc/argocd-server -n argocd 8085:443

# Svc App
kubectl -n labs port-forward service/app-micronout-service --address 0.0.0.0 8080:80
```

## 📝 Notes

- 🔄 The environment uses ArgoCD for GitOps-based deployments
- 🏷️ All resources are labeled with project, team, and environment tags
- 📦 The Micronaut application uses Vultr container registry for images
