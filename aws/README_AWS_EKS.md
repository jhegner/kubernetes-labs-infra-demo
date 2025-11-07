# Configuração AWS EKS - Kubernetes Labs

Este guia descreve como configurar o acesso ao cluster Kubernetes no Amazon EKS usando AWS CLI e kubectl.

## Pré-requisitos

- AWS CLI instalado e configurado
- kubectl instalado
- Permissões adequadas no AWS IAM para acessar o cluster EKS

## 1. Configuração do AWS CLI

### 1.1 Instalação do AWS CLI

Se ainda não tiver o AWS CLI instalado:

```bash
# Windows
curl "https://awscli.amazonaws.com/AWSCLIV2.msi" -o "AWSCLIV2.msi"
msiexec /i AWSCLIV2.msi

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# macOS
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

### 1.2 Configuração das Credenciais AWS

Configure suas credenciais AWS usando um dos métodos abaixo:

#### Método 1: AWS Configure (Recomendado)

```bash
aws configure
```

Forneça as seguintes informações:

- **AWS Access Key ID**: Sua chave de acesso AWS
- **AWS Secret Access Key**: Sua chave secreta AWS
- **Default region name**: Região onde está seu cluster EKS (ex: us-east-1)
- **Default output format**: json (recomendado)

#### Método 2: Variáveis de Ambiente

```bash
export AWS_ACCESS_KEY_ID=sua_access_key
export AWS_SECRET_ACCESS_KEY=sua_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

#### Método 3: AWS Profile

```bash
aws configure --profile eks-profile
```

### 1.3 Verificação da Configuração

Verifique se a configuração está correta:

```bash
# Verificar credenciais
aws sts get-caller-identity

# Listar clusters EKS disponíveis
aws eks list-clusters --region us-east-1
```

## 2. Configuração do Kubeconfig

### 2.1 Instalação do kubectl

Se ainda não tiver o kubectl instalado:

```bash
# Windows (usando Chocolatey)
choco install kubernetes-cli

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# macOS (usando Homebrew)
brew install kubectl
```

### 2.2 Configuração do Kubeconfig para EKS

#### Método 1: Atualização Automática do Kubeconfig

```bash
# Substituir pelos valores do seu cluster
aws eks update-kubeconfig --region us-east-1 --name lab-eks-cluster
```

Exemplo:

```bash
aws eks update-kubeconfig --region us-east-1 --name lab-eks-cluster
```

#### Método 2: Usando Perfil AWS Específico

```bash
aws eks update-kubeconfig --region us-east-1 --name lab-eks-cluster --profile eks-profile
```

#### Método 3: Especificando Caminho do Kubeconfig

```bash
aws eks update-kubeconfig --region us-east-1 --name lab-eks-cluster --kubeconfig ~/.kube/eks-config
```

### 2.3 Verificação da Configuração do Kubeconfig

```bash
# Verificar contextos disponíveis
kubectl config get-contexts

# Verificar contexto atual
kubectl config current-context

# Verificar conectividade com o cluster
kubectl get nodes

# Verificar informações do cluster
kubectl cluster-info
```

## 3. Configuração de Múltiplos Clusters

Se você trabalha com múltiplos clusters EKS:

### 3.1 Adicionando Múltiplos Clusters

```bash
# Cluster de desenvolvimento
aws eks update-kubeconfig --region us-east-1 --name dev-cluster --alias dev

# Cluster de produção
aws eks update-kubeconfig --region us-east-1 --name prod-cluster --alias prod
```

### 3.2 Alternando Entre Contextos

```bash
# Listar contextos
kubectl config get-contexts

# Alternar para contexto específico
kubectl config use-context dev
kubectl config use-context prod

# Verificar contexto atual
kubectl config current-context
```

## 4. Configurações Avançadas

### 4.1 Configuração de Role ARN (AssumeRole)

Se você precisa assumir uma role específica para acessar o cluster:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name nome-do-cluster \
  --role-arn arn:aws:iam::123456789012:role/EKSAccessRole
```

### 4.2 Configuração com MFA

Para ambientes que requerem MFA:

```bash
# Primeiro, obtenha credenciais temporárias com MFA
aws sts get-session-token --serial-number arn:aws:iam::123456789012:mfa/usuario --token-code 123456

# Use as credenciais temporárias para configurar o kubeconfig
export AWS_ACCESS_KEY_ID=TEMP_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=TEMP_SECRET_KEY
export AWS_SESSION_TOKEN=TEMP_SESSION_TOKEN

aws eks update-kubeconfig --region us-east-1 --name nome-do-cluster
```

### 4.3 Configuração de Proxy

Se você está atrás de um proxy corporativo:

```bash
# Configurar proxy para AWS CLI
aws configure set proxy.http_proxy http://proxy.empresa.com:8080
aws configure set proxy.https_proxy https://proxy.empresa.com:8080

# Ou usando variáveis de ambiente
export HTTP_PROXY=http://proxy.empresa.com:8080
export HTTPS_PROXY=https://proxy.empresa.com:8080
export NO_PROXY=localhost,127.0.0.1,.empresa.com
```

## 5. Solução de Problemas

### 5.1 Problemas Comuns

#### Erro: "could not get token: AccessDenied"

```bash
# Verificar permissões IAM
aws sts get-caller-identity

# Verificar se o usuário/role tem permissão eks:DescribeCluster
aws eks describe-cluster --name nome-do-cluster --region us-east-1
```

#### Erro: "server version: v1.xx.x: context deadline exceeded"

```bash
# Verificar conectividade de rede
kubectl get nodes --request-timeout=10s

# Verificar configuração de proxy se aplicável
```

#### Erro: "error: You must be logged in to the server (Unauthorized)"

```bash
# Verificar se o usuário/role está mapeado no cluster
kubectl describe configmap aws-auth -n kube-system

# Verificar contexto atual
kubectl config current-context
```

### 5.2 Comandos de Diagnóstico

```bash
# Verificar configuração do kubectl
kubectl config view

# Verificar detalhes do cluster
aws eks describe-cluster --name nome-do-cluster --region us-east-1

# Verificar logs do AWS CLI (modo debug)
aws eks update-kubeconfig --region us-east-1 --name nome-do-cluster --debug

# Verificar versão dos componentes
aws --version
kubectl version --client
```

## 6. Boas Práticas

### 6.1 Segurança

- Use perfis AWS separados para diferentes ambientes
- Configure MFA quando possível
- Use roles IAM ao invés de usuários para aplicações
- Monitore o acesso através do CloudTrail

### 6.2 Organização

- Use aliases descritivos para contextos kubectl
- Mantenha arquivos kubeconfig separados por ambiente
- Document as configurações em um local centralizado

### 6.3 Automação

```bash
# Script para alternar contextos facilmente
alias k8s-dev='kubectl config use-context dev'
alias k8s-prod='kubectl config use-context prod'

# Script para verificar status do cluster
function check-cluster() {
  echo "=== Contexto Atual ==="
  kubectl config current-context
  echo "=== Nodes ==="
  kubectl get nodes
  echo "=== Namespaces ==="
  kubectl get namespaces
}
```

## 7. Referências

- [Documentação oficial AWS EKS](https://docs.aws.amazon.com/eks/)
- [Documentação kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/)
- [Kubernetes Authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)

---

**Nota**: Substitua `lab-eks-cluster`, `us-east-1`, e outros valores pelos específicos do seu ambiente.