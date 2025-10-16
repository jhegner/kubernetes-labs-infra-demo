# Algumas dicas

> Pensando numa esteira CI/CD em que tenho diversas versões da mesma aplicação sendo geradas para teste (ambiente de develop), depois release (staging) e na sequencia produção, qual seria a melhore simples recomendação ou abordagem para uso de tags em imagem de container.

Boa pergunta 👌 — isso faz bastante diferença na rastreabilidade e na confiabilidade da esteira.
Vou te passar uma visão **prática e simples** para CI/CD com múltiplos ambientes (`develop → staging → production`), sem complicar com dezenas de tags.

---

## 🎯 Objetivos ao definir tags

1. **Reprodutibilidade** → conseguir rodar a mesma imagem em qualquer ambiente.
2. **Imutabilidade** → cada build deve ter um identificador único (não sobrescrever builds antigos).
3. **Clareza** → facilitar entender “o que está rodando” em cada ambiente.
4. **Fluxo de promoção** → a mesma imagem sobe de *develop → staging → prod*, sem rebuild.

---

## 🚀 Estratégia simples de tagging

### 1. Sempre usar uma tag imutável

* **`<git-sha>`**: tag única por commit (garante rastreabilidade).

  * Exemplo: `app:sha-9f14c3d`

Isso é o **core** — sempre que fizer push, essa tag estará disponível e nunca muda.

---

### 2. Facilitar testes de ambiente com tags mutáveis

* **`develop`** → sempre aponta para a última build do branch `develop`.
* **`staging`** → aponta para a última build promovida (release candidate).
* **`latest`** (opcional) → usado só para branch default (`main`).

Isso ajuda o time a rodar rapidamente `docker pull app:develop`, mas não serve como referência final de deploy (pode mudar a qualquer momento).

---

### 3. Versões semânticas para releases

* Quando fizer um **release oficial** (merge em `main` + tag `vX.Y.Z`):

  * `app:v1.4.0`
  * `app:v1.4`
  * `app:v1`
  * `app:sha-9f14c3d`
  * `app:latest` (se usar latest em produção, mas muita gente evita).

Assim você tem:

* Tags **fixas** (sha e semver completo).
* Tags **móveis** (develop/staging/latest).

---

## 📦 Exemplo real de tagging por ambiente

* **Develop** (branch `develop`):

  ```
  app:sha-abc123
  app:develop
  ```

* **Staging** (branch `release/v1.4.0` ou tag `rc`):

  ```
  app:sha-abc123
  app:staging
  app:v1.4.0-rc1
  ```

* **Production** (tag `v1.4.0` no Git):

  ```
  app:sha-abc123
  app:v1.4.0
  app:v1.4
  app:v1
  app:latest
  ```

---

## ✅ Recomendação prática

* **Sempre** use `sha` nas definições de `Deployment` no Kubernetes (garante imutabilidade).
* Use as tags **móveis (`develop`, `staging`, `latest`) apenas para CI/CD e humanos testarem**.
* Gere tags semânticas no **merge/release** para produção.

---

👉 Dessa forma você resolve rastreabilidade, rollback fácil e simplicidade sem precisar de sistemas de versionamento de imagem muito sofisticados.

---


> Faz uma explicação resumida como funciona o mecanismo de tags no OCI (docker) cada tag é uma nova imagem ?

Boa — vamos resumir bem 👇

No **OCI/Docker Registry**, uma **imagem** é composta por **camadas (layers)** e um **manifesto** que aponta para elas.
As **tags** são apenas **ponteiros para manifests** — **não são cópias da imagem**.

---

### 🔑 Funcionamento

* Cada **build** gera um **manifest** que descreve:

  * As camadas (layers, tarballs compactados).
  * Configuração do container (Entrypoint, Env, etc).
* Uma **tag** (`latest`, `v1.0.0`, `sha-xxxx`) é associada a um manifest.
* Várias **tags podem apontar para o mesmo manifest** → ou seja, a mesma imagem pode ser chamada de `app:v1.0.0` e `app:latest` ao mesmo tempo.

---

### 📌 Exemplos

1. Você faz build e publica:

   ```
   docker push app:v1.0.0
   docker push app:latest
   ```

   👉 Ambas as tags podem apontar para **o mesmo manifest** no registry.

2. Se rebuildar com `:latest`:

   * O **manifesto novo** é criado (mesmo que camadas antigas sejam reaproveitadas).
   * A tag `latest` passa a apontar para esse novo manifest.
   * A antiga `v1.0.0` continua apontando para o build original (imutável).

---

### ✅ Em resumo

* **Cada tag não é uma nova imagem**.
* **Cada build cria um manifest**.
* **Tags são apelidos/pointers para manifests**.
* Uma mesma camada pode ser reutilizada por várias imagens → por isso o pull/push é rápido e economiza espaço.

---

Aqui vai um diagrama simplificado de como funciona o mecanismo de tags no modelo **OCI/Docker** 👇

```
               ┌───────────────────────────┐
               │       Registry OCI         │
               └───────────────────────────┘
                          │
          ┌─────────────────────────────────────┐
          │                                     │
      ┌───────┐                           ┌───────┐
      │ Tag:  │                           │ Tag:  │
      │latest │                           │v1.0.0 │
      └───┬───┘                           └───┬───┘
          │                                   │
          ▼                                   ▼
     ┌───────────┐                      ┌───────────┐
     │ Manifest A│◄─────────────────────┘           │
     └─────┬─────┘                                  │
           │                                        │
           ▼                                        │
 ┌─────────────────┐                                │
 │ Layer 1 (base)  │                                │
 ├─────────────────┤                                │
 │ Layer 2 (libs)  │                                │
 ├─────────────────┤                                │
 │ Layer 3 (app)   │                                │
 └─────────────────┘                                │
```

---

### O que acontece:

* `latest` e `v1.0.0` podem apontar para o **mesmo Manifest** (mesmo build).
* O **Manifest** descreve quais **layers** compõem a imagem.
* Os **layers são cacheados e reutilizados** entre diferentes versões quando não mudam.
* Se você fizer novo build e der push em `:latest`, o registry apenas cria um **novo Manifest B**, e a tag `latest` passa a apontar para ele (sem apagar o Manifest A).

---

