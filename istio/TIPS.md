# Dicas

## 1 Colunas Personalizadas no kubectl

Para exibir apenas o nome e o status dos pods do Kubernetes, você pode usar o comando `kubectl get pods` com a flag `-o custom-columns`:

```bash
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase
```

### Explicação

| Comando/Parâmetro      | Descrição                                                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `kubectl get pods`     | Comando básico para obter informações sobre pods                                                                                |
| `-o custom-columns`    | Especifica a saída em formato de colunas personalizadas                                                                         |
| `NAME:.metadata.name`  | Define uma coluna "NAME" que mostra o nome do pod a partir de `.metadata.name`                                                  |
| `STATUS:.status.phase` | Define uma coluna "STATUS" que mostra a fase atual do pod a partir de `.status.phase` (ex: Running, Pending, Succeeded, Failed) |

### Saída de exemplo

```bash
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase -n labs

NAME                       STATUS
backend-5c974d796d-cql86   Running
frontend-c9468b94-ntswr    Running
```

## 2 Modelo OSI (Open Systems Interconnection)

O modelo OSI é um framework conceitual que padroniza as funções de um sistema de telecomunicações ou computação em sete camadas abstratas:

| Camada | Nome         | Descrição                                         | Exemplos de Uso/Protocolos     |
| ------ | ------------ | ------------------------------------------------- | ------------------------------ |
| 7      | Aplicação    | Interface direta com o usuário final e aplicações | HTTP, SMTP, FTP, DNS, SSH      |
| 6      | Apresentação | Tradução, criptografia e compressão de dados      | SSL/TLS, JPEG, MPEG, ASCII     |
| 5      | Sessão       | Gerencia sessões e conexões entre aplicações      | NetBIOS, RPC, SIP              |
| 4      | Transporte   | Garante a entrega confiável dos dados             | TCP, UDP, SCTP                 |
| 3      | Rede         | Roteamento e endereçamento lógico                 | IP, ICMP, OSPF, BGP            |
| 2      | Enlace       | Endereçamento físico e acesso ao meio             | Ethernet, WiFi, Switch, Bridge |
| 1      | Física       | Transmissão de bits brutos                        | Cabos, Fibra Ótica, Hub        |

### Casos de Uso Práticos por Camada

| Camada           | Caso de Uso no Kubernetes/Istio                              | Serviços AWS Relacionados                               |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------- |
| 7 - Aplicação    | API REST de microserviços, Interface do Kubernetes Dashboard | API Gateway, AppSync, AWS App Runner, Elastic Beanstalk |
| 6 - Apresentação | TLS mútuo (mTLS) do Istio para criptografia                  | AWS Certificate Manager (ACM), AWS KMS                  |
| 5 - Sessão       | Gerenciamento de conexões persistentes em aplicações         | AWS ElastiCache, Amazon MQ                              |
| 4 - Transporte   | Load Balancing do Service Mesh, Service Discovery            | ELB (ALB/NLB), Route 53, AWS Cloud Map                  |
| 3 - Rede         | Comunicação entre pods, Políticas de Rede (NetworkPolicy)    | VPC, Security Groups, Network ACLs, Transit Gateway     |
| 2 - Enlace       | Container Network Interface (CNI), Overlay Networks          | VPC ENIs, AWS VPC CNI plugin for K8s                    |
| 1 - Física       | Infraestrutura do cluster (servidores, switches, etc.)       | EC2, EKS Nodes, AWS Outposts, Direct Connect            |
