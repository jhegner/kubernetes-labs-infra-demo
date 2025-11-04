# Envoy Gateway

## Visão Geral

Envoy Gateway é um projeto da CNCF que visa simplificar o uso do Envoy Proxy como um gateway de API para Kubernetes. Ele implementa a Gateway API padrão do Kubernetes e oferece uma experiência mais simples que o Istio para casos de uso focados em ingress e edge proxy.

## Características Principais

- **Gateway API Nativa**: Implementação completa da Gateway API do Kubernetes
- **Simplificação do Envoy**: Interface simplificada para configuração do Envoy
- **Cloud Native**: Projetado especificamente para Kubernetes
- **Extensibilidade**: Sistema de extensões via CRDs
- **Observabilidade**: Métricas e tracing integrados
- **Multi-tenancy**: Suporte a múltiplos namespaces e equipes

## Vantagens

### ✅ Prós

1. **Simplicidade Operacional**
   - Configuração via Gateway API padrão
   - Menos complexidade que Istio completo
   - Installation e upgrade simplificados
   - Debugging mais direto

2. **Padrões Kubernetes Nativos**
   - Gateway API como interface principal
   - CRDs bem definidos
   - Integração nativa com Kubernetes RBAC
   - Helm charts oficiais

3. **Performance do Envoy**
   - Toda performance do Envoy Proxy
   - Data plane otimizado
   - L7 load balancing avançado
   - Connection pooling eficiente

4. **Futuro Garantido**
   - CNCF project com roadmap claro
   - Gateway API é o padrão emergente
   - Migração facilitada entre providers
   - Investimento contínuo

5. **Observabilidade Rica**
   - Métricas Prometheus automáticas
   - OpenTelemetry tracing
   - Access logs estruturados
   - Integration com OTEL stack

## Desvantagens

### ❌ Contras

1. **Projeto Relativamente Novo**
   - Menos maturidade que alternativas
   - Comunidade menor
   - Documentação em desenvolvimento
   - Casos edge podem ter limitações

2. **Limitações de Escopo**
   - Focado em ingress/gateway use cases
   - Não substitui service mesh completo
   - Menos features que Istio
   - East-west traffic limitado

3. **Ecossistema em Desenvolvimento**
   - Plugins e extensões limitados
   - Integração com terceiros em desenvolvimento
   - Tooling ainda evoluindo
   - Best practices emergindo

4. **Dependency do Kubernetes**
   - Exclusivo para ambientes Kubernetes
   - Não adequado para deployments standalone
   - Requer expertise em K8s
   - Version coupling com K8s APIs

## Casos de Uso Ideais

### 🎯 Quando Usar

1. **Ingress Gateway Moderno**
   - Substituição de NGINX Ingress
   - API Gateway para Kubernetes
   - Edge proxy com features avançadas
   - TLS termination centralizada

2. **Organizações Cloud-Native**
   - Kubernetes-first strategy
   - DevOps teams com expertise K8s
   - Standardização em Gateway API
   - Modern application architectures

3. **Migration de Ingress Controllers**
   - Upgrade de NGINX/Traefik
   - Padronização em Gateway API
   - Performance improvements
   - Advanced routing requirements

4. **Microservices com Requisitos Simples**
   - North-south traffic management
   - Basic service mesh features
   - Observability requirements
   - Rate limiting e security

### ⚠️ Quando Evitar

1. **Service Mesh Completo Necessário**
   - East-west traffic management
   - Complex security policies
   - Service-to-service encryption
   - Advanced traffic splitting

2. **Ambientes Non-Kubernetes**
   - Bare metal deployments
   - VM-based architectures
   - Legacy applications
   - Multi-platform requirements

## Instalação e Configuração

### Instalação via Helm

```bash
# Add Envoy Gateway Helm repository
helm repo add envoy-gateway https://gateway.envoyproxy.io/charts
helm repo update

# Install Envoy Gateway
helm install envoy-gateway envoy-gateway/envoy-gateway \
  --namespace envoy-gateway-system \
  --create-namespace \
  --set deployment.replicas=2
```

### Instalação via Manifests

```bash
# Install latest release
kubectl apply -f https://github.com/envoyproxy/gateway/releases/latest/download/install.yaml

# Verify installation
kubectl get pods -n envoy-gateway-system
kubectl get gatewayclass
```

### Configuração Básica

#### GatewayClass

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: envoy-gateway
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  parametersRef:
    group: gateway.envoyproxy.io
    kind: EnvoyProxy
    name: custom-proxy-config
    namespace: envoy-gateway-system
```

#### Gateway Resource

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: example-gateway
  namespace: default
spec:
  gatewayClassName: envoy-gateway
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
  - name: https
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: example-cert
    allowedRoutes:
      namespaces:
        from: Same
```

## Routing Configuration

### HTTPRoute Básica

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: backend-route
  namespace: default
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "api.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api/v1
    backendRefs:
    - name: backend-service
      port: 8080
      weight: 100
  - matches:
    - path:
        type: PathPrefix
        value: /api/v2
    backendRefs:
    - name: backend-v2-service
      port: 8080
      weight: 100
```

### Traffic Splitting

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: canary-route
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "api.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: stable-service
      port: 8080
      weight: 90
    - name: canary-service
      port: 8080
      weight: 10
```

### Header-based Routing

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: header-route
spec:
  parentRefs:
  - name: example-gateway
  rules:
  - matches:
    - headers:
      - name: "x-version"
        value: "v2"
    backendRefs:
    - name: v2-service
      port: 8080
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: default-service
      port: 8080
```

## Configurações Avançadas

### TLS Configuration

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: secure-gateway
spec:
  gatewayClassName: envoy-gateway
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: wildcard-cert
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: v1
kind: Secret
metadata:
  name: wildcard-cert
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>
```

### Backend TLS Policy

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTLSPolicy
metadata:
  name: backend-tls
  namespace: default
spec:
  targetRef:
    kind: Service
    name: secure-backend
  tls:
    caCertRefs:
    - kind: Secret
      name: backend-ca-cert
    hostname: backend.internal.com
```

### Security Policy

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: SecurityPolicy
metadata:
  name: security-policy
  namespace: default
spec:
  targetRef:
    kind: Gateway
    name: example-gateway
  cors:
    allowOrigins:
    - "https://frontend.example.com"
    allowMethods:
    - GET
    - POST
    - PUT
    - DELETE
    allowHeaders:
    - "Content-Type"
    - "Authorization"
    maxAge: 86400
  jwt:
    providers:
    - name: auth0
      issuer: "https://auth0.example.com/"
      audiences:
      - "api.example.com"
      remoteJWKS:
        uri: "https://auth0.example.com/.well-known/jwks.json"
```

### Rate Limiting

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: rate-limit-policy
  namespace: default
spec:
  targetRef:
    kind: Gateway
    name: example-gateway
  rateLimit:
    type: Global
    global:
      rules:
      - clientSelectors:
        - headers:
          - name: "x-user-id"
            value: "premium-user"
        limit:
          requests: 1000
          unit: Second
      - clientSelectors:
        - headers:
          - name: "x-user-id"
            value: "regular-user"
        limit:
          requests: 100
          unit: Second
      - limit:
          requests: 10
          unit: Second
```

## Observabilidade

### Prometheus Metrics

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: prometheus-config
  namespace: envoy-gateway-system
spec:
  telemetry:
    metrics:
      prometheus:
        configOverride:
          disable_host_header_fallback: true
        providers:
        - service:
            address: prometheus.monitoring:9090
          name: prometheus
        - name: otel
          envoyOtelAls:
            service: opentelemetry-collector.monitoring:4317
```

### Access Logs

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: access-logs
  namespace: envoy-gateway-system
spec:
  telemetry:
    accessLog:
      settings:
      - format:
          type: JSON
          json:
            timestamp: "%START_TIME%"
            method: "%REQ(:METHOD)%"
            path: "%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%"
            protocol: "%PROTOCOL%"
            response_code: "%RESPONSE_CODE%"
            response_flags: "%RESPONSE_FLAGS%"
            bytes_received: "%BYTES_RECEIVED%"
            bytes_sent: "%BYTES_SENT%"
            duration: "%DURATION%"
            upstream_service_time: "%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%"
            x_forwarded_for: "%REQ(X-FORWARDED-FOR)%"
            user_agent: "%REQ(USER-AGENT)%"
            request_id: "%REQ(X-REQUEST-ID)%"
            authority: "%REQ(:AUTHORITY)%"
            upstream_host: "%UPSTREAM_HOST%"
        providers:
        - type: File
          file:
            path: "/dev/stdout"
```

### Distributed Tracing

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: tracing-config
  namespace: envoy-gateway-system
spec:
  telemetry:
    tracing:
      provider:
        type: OpenTelemetry
        host: jaeger-collector.monitoring
        port: 14268
      customTags:
        "environment":
          literal:
            value: "production"
        "service.name":
          literal:
            value: "envoy-gateway"
```

## Extensibilidade

### Custom Filter via WASM

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: wasm-extension
  namespace: envoy-gateway-system
spec:
  provider:
    type: Kubernetes
    kubernetes:
      envoyService:
        type: LoadBalancer
  bootstrap:
    value: |
      static_resources:
        listeners:
        - name: wasm_listener
          filter_chains:
          - filters:
            - name: envoy.filters.http.wasm
              typed_config:
                "@type": type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
                config:
                  name: "my_custom_filter"
                  root_id: "my_root_id"
                  vm_config:
                    vm_id: "my_vm_id"
                    runtime: "envoy.wasm.runtime.v8"
                    code:
                      local:
                        inline_string: |
                          // Custom WASM filter code here
```

### External Authorization

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: SecurityPolicy
metadata:
  name: external-auth
  namespace: default
spec:
  targetRef:
    kind: HTTPRoute
    name: protected-route
  extAuth:
    grpc:
      backendRef:
        name: auth-service
        port: 9000
    failOpen: false
    headersToBackend:
    - "authorization"
    - "x-user-id"
    headersToUpstream:
    - "x-auth-user"
    - "x-auth-roles"
```

## Deployment Patterns

### Multi-Region Setup

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: multi-region-gateway
  annotations:
    gateway.envoyproxy.io/regions: "us-east-1,us-west-2"
spec:
  gatewayClassName: envoy-gateway
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: global-cert
  addresses:
  - type: NamedAddress
    value: global-load-balancer
```

### High Availability

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: ha-config
  namespace: envoy-gateway-system
spec:
  provider:
    type: Kubernetes
    kubernetes:
      envoyDeployment:
        replicas: 3
        strategy:
          type: RollingUpdate
          rollingUpdate:
            maxSurge: 1
            maxUnavailable: 0
      envoyService:
        type: LoadBalancer
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
          service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
```

## Migration Strategies

### From NGINX Ingress

```yaml
# Step 1: Install Envoy Gateway alongside NGINX
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: migration-gateway
  namespace: default
spec:
  gatewayClassName: envoy-gateway
  listeners:
  - name: http-migration
    port: 8080  # Different port initially
    protocol: HTTP

---
# Step 2: Create HTTPRoute equivalent to Ingress
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: migrated-route
spec:
  parentRefs:
  - name: migration-gateway
  hostnames:
  - "api.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: api-service
      port: 8080
```

### From Istio Gateway

```yaml
# Convert Istio VirtualService to HTTPRoute
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: istio-migration
spec:
  parentRefs:
  - name: envoy-gateway
  hostnames:
  - "api.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /v1
    filters:
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
        - name: "x-version"
          value: "v1"
    backendRefs:
    - name: v1-service
      port: 8080
```

## Best Practices

### Security Hardening

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: SecurityPolicy
metadata:
  name: hardened-security
spec:
  targetRef:
    kind: Gateway
    name: production-gateway
  cors:
    allowOrigins:
    - "https://trusted-domain.com"
    allowCredentials: true
  basicAuth:
    users:
      secretRef:
        name: basic-auth-secret
  jwt:
    providers:
    - name: primary-jwt
      issuer: "https://auth.company.com/"
      audiences:
      - "api.company.com"
      remoteJWKS:
        uri: "https://auth.company.com/.well-known/jwks.json"
        cacheDuration: "5m"
```

### Performance Optimization

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: performance-config
spec:
  provider:
    kubernetes:
      envoyDeployment:
        pod:
          resources:
            requests:
              cpu: "500m"
              memory: "512Mi"
            limits:
              cpu: "2000m"
              memory: "1Gi"
  bootstrap:
    value: |
      overload_manager:
        refresh_interval: 0.25s
        resource_monitors:
        - name: "envoy.resource_monitors.fixed_heap"
          typed_config:
            "@type": type.googleapis.com/envoy.extensions.resource_monitors.fixed_heap.v3.FixedHeapConfig
            max_heap_size_bytes: 1073741824  # 1GB
        actions:
        - name: "envoy.overload_actions.shrink_heap"
          triggers:
          - name: "envoy.resource_monitors.fixed_heap"
            threshold:
              value: 0.95
        - name: "envoy.overload_actions.stop_accepting_requests"
          triggers:
          - name: "envoy.resource_monitors.fixed_heap"
            threshold:
              value: 0.98
```

## Troubleshooting

### Debug Configuration

```bash
# Check Gateway status
kubectl get gateway example-gateway -o yaml

# Check HTTPRoute status
kubectl get httproute backend-route -o yaml

# Check EnvoyProxy deployment
kubectl get pods -n envoy-gateway-system

# Get Envoy configuration
kubectl port-forward -n envoy-gateway-system svc/envoy-gateway 19000:19000
curl http://localhost:19000/config_dump

# Check logs
kubectl logs -n envoy-gateway-system deployment/envoy-gateway
```

### Common Issues

```yaml
# Fix: Gateway not ready
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: debug-gateway
spec:
  gatewayClassName: envoy-gateway
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All  # Check namespace restrictions
status:
  conditions:
  - type: Programmed
    status: "False"
    reason: InvalidListener
    message: "Listener port 80 conflicts with existing listener"
```

## Referências e Documentação

### Documentação Oficial

- [Envoy Gateway Documentation](https://gateway.envoyproxy.io/)
- [Gateway API Specification](https://gateway-api.sigs.k8s.io/)
- [Envoy Gateway GitHub](https://github.com/envoyproxy/gateway)

### Tutoriais e Guias

- [Getting Started with Envoy Gateway](https://gateway.envoyproxy.io/latest/user/quickstart/)
- [Gateway API Migration Guide](https://gateway.envoyproxy.io/latest/user/guides/)
- [Security Best Practices](https://gateway.envoyproxy.io/latest/user/security/)

### Livros e Recursos

- "Gateway API: The Future of Kubernetes Ingress" - CNCF
- "Envoy Proxy Fundamentals" - Matt Klein
- "Cloud Native Network Security" - Andy Goldstein

### Artigos Técnicos

- [Gateway API vs Ingress](https://kubernetes.io/blog/2021/04/22/evolving-kubernetes-networking-with-the-gateway-api/)
- [Envoy Gateway Performance](https://blog.envoyproxy.io/envoy-gateway-performance-8c4ee21c5e80)
- [Service Mesh Comparison](https://servicemesh.es/)

### Comunidade e Suporte

- [Envoy Gateway Slack](https://envoyproxy.slack.com/)
- [Gateway API Community](https://gateway-api.sigs.k8s.io/community/)
- [CNCF TOC](https://github.com/cncf/toc)

## Comparação com Alternativas

### Envoy Gateway vs Istio Gateway

| Característica | Envoy Gateway | Istio Gateway |
|----------------|---------------|---------------|
| **Escopo** | Ingress/Edge | Service Mesh Completo |
| **Complexidade** | Simples | Complexo |
| **APIs** | Gateway API | Istio CRDs |
| **Features** | Básicas | Avançadas |
| **Learning Curve** | Baixa | Alta |

### Envoy Gateway vs NGINX Ingress

| Característica | Envoy Gateway | NGINX Ingress |
|----------------|---------------|---------------|
| **Performance** | Muito Alta | Alta |
| **Configuração** | Gateway API | Annotations |
| **Extensibilidade** | WASM/Filters | Lua Scripts |
| **Observabilidade** | Rica | Básica |
| **Future-Proof** | Sim | Legado |

## Conclusão

Envoy Gateway representa o futuro dos ingress controllers para Kubernetes:

**Ideal para:**

- Organizações que adotam Gateway API
- Teams que precisam de performance superior ao NGINX
- Ambientes que requerem observabilidade rica
- Modernização de infraestrutura de ingress

**Considerações:**

- Projeto ainda em evolução
- Requer expertise em Kubernetes
- Melhor para casos de ingress/edge
- Investment de longo prazo em padrões

É uma escolha estratégica para organizações que buscam padronização em Gateway API e performance superior, especialmente como evolution path do NGINX Ingress ou alternativa simples ao Istio para casos de uso de ingress.
