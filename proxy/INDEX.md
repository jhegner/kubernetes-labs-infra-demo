# Índice da Documentação - Alternativas de Proxy

## 📋 Estrutura da Documentação

```
proxy-alternatives/
├── README_PROXY_ALTERNATIVES.md           # Documentação original + novo índice
├── docs/
│   ├── guia-comparativo.md                # 🎯 DOCUMENTO PRINCIPAL
│   ├── java-based/                        # Soluções baseadas em Java
│   │   ├── spring-cloud-gateway.md
│   │   ├── micronaut-gateway.md
│   │   └── vertx-web-proxy.md
│   ├── infrastructure-level/              # Soluções de infraestrutura
│   │   ├── envoy-proxy.md
│   │   ├── envoy-gateway.md
│   │   └── traditional-proxies.md         # NGINX, Kong, Traefik
│   └── examples/                           # Exemplos práticos (futuro)
└── INDEX.md                               # Este arquivo
```

## 🎯 Navegação Rápida

### Por Tipo de Solução

**Java-Based Solutions**

- [Spring Cloud Gateway](./docs/java-based/spring-cloud-gateway.md) - Solução reativa do Spring
- [Micronaut Gateway](./docs/java-based/micronaut-gateway.md) - Alternativa leve e performática  
- [Vert.x Web Proxy](./docs/java-based/vertx-web-proxy.md) - Event-driven, alta performance

**Infrastructure-Level Solutions**

- [Envoy Proxy](./docs/infrastructure-level/envoy-proxy.md) - Proxy L7 enterprise
- [Envoy Gateway](./docs/infrastructure-level/envoy-gateway.md) - Gateway API nativo
- [Proxies Tradicionais](./docs/infrastructure-level/traditional-proxies.md) - NGINX, Kong, Traefik

### Por Cenário de Uso

**Alta Performance / Baixa Latência**

1. [Vert.x Web Proxy](./docs/java-based/vertx-web-proxy.md)
2. [Envoy Proxy](./docs/infrastructure-level/envoy-proxy.md)
3. [NGINX](./docs/infrastructure-level/traditional-proxies.md#nginx)

**API Gateway Empresarial**

1. [Kong](./docs/infrastructure-level/traditional-proxies.md#kong-gateway)
2. [Spring Cloud Gateway](./docs/java-based/spring-cloud-gateway.md)
3. [Envoy Gateway](./docs/infrastructure-level/envoy-gateway.md)

**Cloud Native / Kubernetes**

1. [Envoy Gateway](./docs/infrastructure-level/envoy-gateway.md)
2. [Traefik](./docs/infrastructure-level/traditional-proxies.md#traefik)
3. [Envoy Proxy](./docs/infrastructure-level/envoy-proxy.md)

**Desenvolvimento Rápido**

1. [Traefik](./docs/infrastructure-level/traditional-proxies.md#traefik)
2. [Micronaut Gateway](./docs/java-based/micronaut-gateway.md)
3. [Spring Cloud Gateway](./docs/java-based/spring-cloud-gateway.md)

### Por Problema Específico

**Clientes Síncronos (Buffering)**

- [Spring Cloud Gateway - Buffering](./docs/java-based/spring-cloud-gateway.md#configurações-para-buffering-clientes-síncronos)
- [Envoy - Buffer Filter](./docs/infrastructure-level/envoy-proxy.md#envoyfilter-para-buffering)
- [Micronaut - Blocking Mode](./docs/java-based/micronaut-gateway.md#proxy-básico-não-blocante)

**TLS com CA Interna**

- [Envoy Proxy - TLS Config](./docs/infrastructure-level/envoy-proxy.md#configuração-com-tls)
- [Micronaut - TLS](./docs/java-based/micronaut-gateway.md#tls-e-certificados)
- [NGINX - SSL](./docs/infrastructure-level/traditional-proxies.md#configuração-básica)

**Rate Limiting**

- [Kong - Rate Limiting](./docs/infrastructure-level/traditional-proxies.md#rate-limiting)
- [Envoy - Rate Limiting](./docs/infrastructure-level/envoy-proxy.md#rate-limiting)
- [Spring Cloud Gateway - Filters](./docs/java-based/spring-cloud-gateway.md#filtro-de-rate-limiting)

## 🚀 Guias de Início Rápido

### Para Desenvolvedores Java

**Início**: [Micronaut Gateway](./docs/java-based/micronaut-gateway.md) → [Spring Cloud Gateway](./docs/java-based/spring-cloud-gateway.md)

### Para DevOps/SRE

**Início**: [Traefik](./docs/infrastructure-level/traditional-proxies.md#traefik) → [Envoy Gateway](./docs/infrastructure-level/envoy-gateway.md)

### Para Arquitetos

**Início**: [Guia Comparativo](./docs/guia-comparativo.md) → Documentação específica da solução escolhida

### Para Performance Engineers  

**Início**: [Vert.x Web Proxy](./docs/java-based/vertx-web-proxy.md) → [Envoy Proxy](./docs/infrastructure-level/envoy-proxy.md)

## 📚 Documentos Complementares

### Migrations

- [De NGINX para Envoy Gateway](./docs/guia-comparativo.md#de-nginx-para-alternativas-modernas)
- [De Spring para Micronaut](./docs/guia-comparativo.md#de-spring-cloud-gateway-para-alternativas)  
- [De Kong para Envoy Gateway](./docs/guia-comparativo.md#de-kong-para-envoy-gateway)

### Best Practices

- [Configurações de Performance](./docs/guia-comparativo.md#implementação-faseada)
- [Security Hardening](./docs/infrastructure-level/traditional-proxies.md#security-hardening)
- [Observabilidade](./docs/guia-comparativo.md#checklist-de-implementação)

### Troubleshooting

- [Problemas Comuns](./docs/java-based/spring-cloud-gateway.md#troubleshooting-comum)
- [Debug e Monitoring](./docs/infrastructure-level/envoy-proxy.md#testing-e-debugging)
- [Performance Tuning](./docs/java-based/micronaut-gateway.md#performance-optimization)

## 🎯 Recomendações por Contexto

| Contexto | Solução Primária | Alternativa | Justificativa |
|----------|------------------|-------------|---------------|
| **Startup** | Traefik | Micronaut | Setup rápido, baixo overhead |
| **Enterprise** | Kong | Spring Cloud Gateway | Features empresariais, suporte |
| **High-Tech** | Envoy Proxy | Vert.x | Performance máxima |
| **Cloud-Native** | Envoy Gateway | Traefik | Padrões modernos, K8s native |
| **Java Shop** | Micronaut | Spring Cloud Gateway | Expertise existente |

## 📈 Matriz de Decisão

Para uma análise detalhada com scores e pesos por critério, consulte:
**[Guia Comparativo - Matriz de Decisão](./docs/guia-comparativo.md#matriz-de-decisão-por-critérios)**

## 🔗 Links Úteis

- **Documentação Original**: [README_PROXY_ALTERNATIVES.md](./README_PROXY_ALTERNATIVES.md)
- **Guia Principal**: [docs/guia-comparativo.md](./docs/guia-comparativo.md)
- **Repository Root**: [../../](../../README.md)

---

*Última atualização: Novembro 2025*
