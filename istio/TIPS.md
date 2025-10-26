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