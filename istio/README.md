# 🚢 Laboratório Istio

## 📚 Aprendizado do básico ao avançado (inclui estratégia Blue/Green)

### 📋 Sobre o Laboratório

Este é um laboratório completo estruturado em formato de histórias de usuário (user stories), organizado por épicos do básico ao avançado. Cada história contém:

- ✍️ Descrição detalhada
- ✅ Critérios de aceitação
- 📝 Tarefas passo-a-passo
  - Comandos `kubectl`
  - Comandos `istioctl`
  - Exemplos em YAML
- 🔍 Dicas de validação
- ⭐ Nível de dificuldade

### 🛠️ Como Usar

- [ ] Prepare seu ambiente Kubernetes
- [ ] Siga as histórias em ordem
- [ ] Execute os hands-on em seu cluster
- [ ] Valide cada passo com os critérios fornecidos

### 🔄 Ambientes Blue/Green

Existem duas opções para trabalhar com clusters blue/green:

#### Opção A: Produção 🏢

- Dois clusters reais
- Recomendado para ambiente de produção
- Ideal para cenários multi-cluster

#### Opção B: Laboratório 🧪

- Simulação em um único cluster
- Usa namespaces separados (blue e green)
- Perfeito para aprendizado local