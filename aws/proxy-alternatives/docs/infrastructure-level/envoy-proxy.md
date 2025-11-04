# Envoy Proxy

## Visão Geral

Envoy é um proxy L7 (Layer 7) e edge proxy de alta performance originalmente desenvolvido pela Lyft. É a base de muitas soluções de service mesh como Istio, e oferece recursos avançados de load balancing, observabilidade, e resiliência.

## Características Principais

- **Arquitetura C++**: Performance otimizada em nível de sistema
- **API-Driven Configuration**: Configuração dinâmica via APIs
- **Observabilidade Rica**: Métricas, tracing e logging detalhados
- **L7 Load Balancing**: Algoritmos avançados de balanceamento
- **Service Discovery**: Integração com múltiplos service discovery
- **Circuit Breaking**: Proteção automática contra falhas

## Vantagens

### ✅ Prós

1. **Performance Excepcional**
   - Implementação em C++ otimizada
   - Zero-copy networking
   - Memory footprint baixo
   - Latência consistente e previsível

2. **Observabilidade Nativa**
   - Métricas detalhadas out-of-the-box
   - Distributed tracing automático
   - Access logs estruturados
   - Health checking integrado

3. **Resiliência Avançada**
   - Circuit breakers configuráveis
   - Retry policies sofisticadas
   - Rate limiting granular
   - Timeout management

4. **Flexibilidade de Configuração**
   - Configuration via APIs dinâmicas
   - Hot reload sem downtime
   - Extensibilidade via filters
   - Multi-protocol support

5. **Ecosystem Maduro**
   - Base do Istio service mesh
   - Ampla adoção em produção
   - Documentação extensiva
   - Comunidade ativa

## Desvantagens

### ❌ Contras

1. **Complexidade de Configuração**
   - Learning curve íngreme
   - YAML/JSON extenso
   - Debugging desafiador
   - Configuração verbosa

2. **Overhead Operacional**
   - Requer expertise em networking
   - Monitoring complexo
   - Troubleshooting avançado
   - Updates requerem planejamento

3. **Resource Requirements**
   - CPU usage para features avançadas
   - Memory para connection pools
   - Network overhead para telemetry
   - Storage para logs e métricas

4. **Curva de Aprendizado**
   - Conceitos de networking avançados
   - Configuração declarativa complexa
   - Integration patterns específicos
   - Operational best practices

## Casos de Uso Ideais

### 🎯 Quando Usar

1. **Service Mesh Infrastructure**
   - Microserviços complexos
   - Inter-service communication
   - Security policies centralizadas
   - Observabilidade unificada

2. **Edge Proxy/API Gateway**
   - Ingress traffic management
   - TLS termination
   - Rate limiting global
   - Content routing

3. **Load Balancer Avançado**
   - L7 load balancing
   - Health checking sofisticado
   - Traffic shaping
   - A/B testing

4. **High-Scale Production**
   - Ambientes críticos
   - Performance requirements
   - Compliance e security
   - Operational excellence

### ⚠️ Quando Evitar

1. **Aplicações Simples**
   - Monolitos pequenos
   - Desenvolvimento local
   - Proof of concepts
   - Resource-constrained environments

2. **Equipes Inexperientes**
   - Falta de expertise em networking
   - Limited operational capacity
   - Simple use cases
   - Rapid prototyping needs

## Instalação e Configuração

### Instalação Standalone

```bash
# Download Envoy binary
curl -L https://getenvoy.io/install.sh | bash

# Run with configuration file
envoy -c envoy.yaml
```

### Docker Deployment

```dockerfile
FROM envoyproxy/envoy:v1.28-latest

COPY envoy.yaml /etc/envoy/envoy.yaml

EXPOSE 8080 9901

CMD ["envoy", "-c", "/etc/envoy/envoy.yaml"]
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: envoy-proxy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: envoy-proxy
  template:
    metadata:
      labels:
        app: envoy-proxy
    spec:
      containers:
      - name: envoy
        image: envoyproxy/envoy:v1.28-latest
        ports:
        - containerPort: 8080
        - containerPort: 9901
        volumeMounts:
        - name: envoy-config
          mountPath: /etc/envoy
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
      volumes:
      - name: envoy-config
        configMap:
          name: envoy-config
```

## Configuração Básica

### Proxy Reverso Simples

```yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8080
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: backend_service

  clusters:
  - name: backend_service
    connect_timeout: 30s
    type: LOGICAL_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: backend_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: backend.example.com
                port_value: 443
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext

admin:
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901
```

### Configuração com TLS

```yaml
static_resources:
  listeners:
  - name: https_listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8443
    filter_chains:
    - transport_socket:
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificates:
            - certificate_chain:
                filename: "/etc/envoy/tls/tls.crt"
              private_key:
                filename: "/etc/envoy/tls/tls.key"
      filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: https_ingress
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains: ["api.example.com"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: backend_service
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: backend_service
    connect_timeout: 30s
    type: LOGICAL_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: backend_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: backend.internal.com
                port_value: 443
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        common_tls_context:
          validation_context:
            trusted_ca:
              filename: "/etc/envoy/tls/ca.crt"
```

## Configurações Avançadas

### Rate Limiting

```yaml
http_filters:
- name: envoy.filters.http.local_ratelimit
  typed_config:
    "@type": type.googleapis.com/udpa.type.v1.TypedStruct
    type_url: type.googleapis.com/envoy.extensions.filters.http.local_ratelimit.v3.LocalRateLimit
    value:
      stat_prefix: local_rate_limiter
      token_bucket:
        max_tokens: 100
        tokens_per_fill: 100
        fill_interval: 60s
      filter_enabled:
        runtime_key: local_rate_limit_enabled
        default_value:
          numerator: 100
          denominator: HUNDRED
      filter_enforced:
        runtime_key: local_rate_limit_enforced
        default_value:
          numerator: 100
          denominator: HUNDRED
      response_headers_to_add:
      - append: false
        header:
          key: x-local-rate-limit
          value: 'true'
- name: envoy.filters.http.router
```

### Circuit Breaker

```yaml
clusters:
- name: backend_service
  connect_timeout: 30s
  type: LOGICAL_DNS
  lb_policy: ROUND_ROBIN
  circuit_breakers:
    thresholds:
    - priority: DEFAULT
      max_connections: 100
      max_pending_requests: 50
      max_requests: 200
      max_retries: 3
      retry_budget:
        budget_percent:
          value: 25.0
        min_retry_concurrency: 3
  outlier_detection:
    consecutive_5xx: 5
    interval: 30s
    base_ejection_time: 30s
    max_ejection_percent: 50
    min_health_percent: 50
  load_assignment:
    cluster_name: backend_service
    endpoints:
    - lb_endpoints:
      - endpoint:
          address:
            socket_address:
              address: backend.example.com
              port_value: 443
```

### Health Checking

```yaml
clusters:
- name: backend_service
  connect_timeout: 30s
  type: LOGICAL_DNS
  lb_policy: ROUND_ROBIN
  health_checks:
  - timeout: 5s
    interval: 10s
    unhealthy_threshold: 3
    healthy_threshold: 2
    http_health_check:
      path: "/health"
      expected_statuses:
      - start: 200
        end: 299
  load_assignment:
    cluster_name: backend_service
    endpoints:
    - lb_endpoints:
      - endpoint:
          address:
            socket_address:
              address: backend.example.com
              port_value: 443
          health_check_config:
            port_value: 8080
```

### Request/Response Transformation

```yaml
http_filters:
- name: envoy.filters.http.lua
  typed_config:
    "@type": type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua
    inline_code: |
      function envoy_on_request(request_handle)
        request_handle:headers():add("x-proxy-by", "envoy")
        request_handle:headers():add("x-request-id", request_handle:headers():get(":authority") .. "-" .. os.time())
      end

      function envoy_on_response(response_handle)
        response_handle:headers():add("x-processed-by", "envoy-proxy")
        response_handle:headers():add("x-response-time", os.time())
      end
- name: envoy.filters.http.router
```

## Integração com Istio

### Istio Gateway usando Envoy

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: envoy-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: api-cert
    hosts:
    - "api.example.com"
```

### VirtualService

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend-service
spec:
  hosts:
  - "api.example.com"
  gateways:
  - envoy-gateway
  http:
  - match:
    - uri:
        prefix: "/api"
    route:
    - destination:
        host: backend-service.default.svc.cluster.local
        port:
          number: 443
    timeout: 30s
    retries:
      attempts: 3
      perTryTimeout: 10s
```

### DestinationRule com TLS

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend-service
spec:
  host: backend-service.default.svc.cluster.local
  trafficPolicy:
    tls:
      mode: SIMPLE
      caCertificates: /etc/istio/custom-ca/ca.crt
    connectionPool:
      http:
        maxRequestsPerConnection: 10
        h2MaxRequests: 100
        idleTimeout: 90s
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
```

### EnvoyFilter para Buffering

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: buffer-response
  namespace: istio-system
spec:
  workloadSelector:
    labels:
      istio: ingressgateway
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
      listener:
        filterChain:
          filter:
            name: envoy.filters.network.http_connection_manager
            subFilter:
              name: envoy.filters.http.router
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.buffer
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.buffer.v3.Buffer
          max_request_bytes: 5242880
          max_response_bytes: 10485760
```

## Observabilidade

### Métricas Prometheus

```yaml
admin:
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901

stats_config:
  stats_tags:
  - tag_name: cluster_name
    regex: "^cluster\\.((.+?)\\.).*"
  - tag_name: virtual_host_name
    regex: "^vhost\\.((.+?)\\.).*"

stats_sinks:
- name: envoy.stat_sinks.statsd
  typed_config:
    "@type": type.googleapis.com/envoy.config.core.v3.StatsdSink
    address:
      socket_address:
        address: prometheus-statsd-exporter
        port_value: 9125
```

### Access Logs Estruturados

```yaml
access_log:
- name: envoy.access_loggers.file
  typed_config:
    "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
    path: "/var/log/envoy/access.log"
    format: |
      {
        "timestamp": "%START_TIME%",
        "method": "%REQ(:METHOD)%",
        "path": "%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%",
        "protocol": "%PROTOCOL%",
        "response_code": "%RESPONSE_CODE%",
        "response_flags": "%RESPONSE_FLAGS%",
        "bytes_received": "%BYTES_RECEIVED%",
        "bytes_sent": "%BYTES_SENT%",
        "duration": "%DURATION%",
        "upstream_service_time": "%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%",
        "x_forwarded_for": "%REQ(X-FORWARDED-FOR)%",
        "user_agent": "%REQ(USER-AGENT)%",
        "request_id": "%REQ(X-REQUEST-ID)%",
        "authority": "%REQ(:AUTHORITY)%",
        "upstream_host": "%UPSTREAM_HOST%"
      }
```

### Distributed Tracing

```yaml
tracing:
  http:
    name: envoy.tracers.zipkin
    typed_config:
      "@type": type.googleapis.com/envoy.config.trace.v3.ZipkinConfig
      collector_cluster: zipkin
      collector_endpoint: "/api/v2/spans"
      shared_span_context: false

http_filters:
- name: envoy.filters.http.trace
  typed_config:
    "@type": type.googleapis.com/envoy.extensions.filters.http.trace.v3.Trace
- name: envoy.filters.http.router
```

## Performance Tuning

### Connection Pool Optimization

```yaml
clusters:
- name: backend_service
  connect_timeout: 5s
  type: LOGICAL_DNS
  lb_policy: ROUND_ROBIN
  http2_protocol_options: {}
  upstream_connection_options:
    tcp_keepalive:
      keepalive_probes: 3
      keepalive_time: 30
      keepalive_interval: 5
  circuit_breakers:
    thresholds:
    - priority: DEFAULT
      max_connections: 200
      max_pending_requests: 100
      max_requests: 400
      max_retries: 5
  load_assignment:
    cluster_name: backend_service
    endpoints:
    - lb_endpoints:
      - endpoint:
          address:
            socket_address:
              address: backend.example.com
              port_value: 443
```

### Listener Optimization

```yaml
listeners:
- name: listener_0
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 8080
  listener_filters:
  - name: envoy.filters.listener.original_dst
  - name: envoy.filters.listener.http_inspector
  socket_options:
  - level: 1      # SOL_SOCKET
    name: 15      # SO_REUSEPORT
    int_value: 1
  - level: 6      # IPPROTO_TCP
    name: 1       # TCP_NODELAY
    int_value: 1
  per_connection_buffer_limit_bytes: 32768
```

## Testing e Debugging

### Configuração de Debug

```yaml
admin:
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 9901
  profile_path: "/tmp/envoy.prof"

dynamic_resources:
  cds_config:
    resource_api_version: V3
    api_config_source:
      api_type: GRPC
      transport_api_version: V3
      grpc_services:
      - envoy_grpc:
          cluster_name: xds_cluster

hidden_envoy_deprecated_and_dangerous_log_level: debug
```

### Health Check Endpoint

```bash
# Check admin interface
curl http://localhost:9901/

# Get configuration dump
curl http://localhost:9901/config_dump

# Get stats
curl http://localhost:9901/stats

# Get clusters info
curl http://localhost:9901/clusters

# Get listeners info
curl http://localhost:9901/listeners
```

### Load Testing

```bash
# Using Apache Bench
ab -n 10000 -c 100 http://localhost:8080/

# Using wrk
wrk -t4 -c100 -d30s http://localhost:8080/

# Using hey
hey -n 10000 -c 100 http://localhost:8080/
```

## Referências e Documentação

### Documentação Oficial

- [Envoy Proxy Documentation](https://www.envoyproxy.io/docs/)
- [Envoy Configuration Reference](https://www.envoyproxy.io/docs/envoy/latest/configuration/configuration)
- [Envoy API Reference](https://www.envoyproxy.io/docs/envoy/latest/api/)

### Tutoriais e Guias

- [Getting Started with Envoy](https://www.envoyproxy.io/docs/envoy/latest/start/start)
- [Envoy Proxy Deep Dive](https://blog.envoyproxy.io/)
- [Service Mesh with Envoy](https://www.servicemeshbook.com/)

### Livros e Recursos

- "Envoy Proxy Fundamentals" por Flynn/Calcote
- "Service Mesh Patterns" por Alex Soto
- "Cloud Native Infrastructure" por Justin Garrison

### Artigos Técnicos

- [Envoy Proxy Architecture](https://blog.envoyproxy.io/envoy-threading-model-a8d44b922310)
- [Performance Tuning Envoy](https://www.envoyproxy.io/docs/envoy/latest/faq/performance/how_fast_is_envoy)
- [Envoy vs NGINX](https://www.nginx.com/blog/nginx-vs-envoy-proxy-performance/)

### Comunidade e Suporte

- [Envoy Proxy GitHub](https://github.com/envoyproxy/envoy)
- [Envoy Slack Community](https://envoyproxy.slack.com/)
- [CNCF Envoy Project](https://www.cncf.io/projects/envoy/)

## Troubleshooting Comum

### Problema: Configuration Errors

**Sintoma**: Envoy fails to start with config errors

**Solução**:

```bash
# Validate configuration
envoy --mode validate -c envoy.yaml

# Check admin interface for errors
curl http://localhost:9901/config_dump?include_eds
```

### Problema: High Memory Usage

**Sintoma**: Memory consumption grows over time

**Solução**:

```yaml
# Add connection limits
circuit_breakers:
  thresholds:
  - priority: DEFAULT
    max_connections: 100
    max_pending_requests: 50

# Configure buffer limits
per_connection_buffer_limit_bytes: 32768
```

### Problema: SSL/TLS Issues

**Sintoma**: TLS handshake failures

**Solução**:

```yaml
# Debug TLS configuration
common_tls_context:
  validation_context:
    trusted_ca:
      filename: "/etc/envoy/tls/ca.crt"
    verify_certificate_spki:
    - "base64-encoded-spki-hash"
    verify_certificate_hash:
    - "base64-encoded-cert-hash"
```

## Conclusão

Envoy Proxy é a escolha ideal para:

- Infraestrutura de service mesh
- Edge proxy com requisitos avançados
- Cenários que requerem observabilidade rica
- Ambientes de produção com requirements de performance

É especialmente adequado para organizações que precisam de:

- Controle granular sobre traffic management
- Observabilidade e monitoring avançados
- Integração com ecosistemas cloud-native
- Flexibilidade para customizações específicas

A complexidade de configuração é compensada pela robustez e flexibilidade que oferece em ambientes de produção complexos.
