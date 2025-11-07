# Proxies Tradicionais e API Gateways

## Visão Geral

Esta seção aborda as alternativas tradicionais e populares para proxy reverso e API gateway, incluindo NGINX, Kong, e Traefik. Essas soluções oferecem diferentes abordagens e características para cenários diversos.

## NGINX

### Características Principais

NGINX é um servidor web, proxy reverso e load balancer de alta performance, conhecido por sua estabilidade e eficiência.

#### Vantagens

**✅ Prós**

1. **Performance Comprovada**
   - Arquitetura event-driven otimizada
   - Baixo uso de memória
   - Alta concorrência
   - Throughput excepcional

2. **Maturidade e Estabilidade**
   - 20+ anos de desenvolvimento
   - Amplamente testado em produção
   - Comunidade vasta
   - Documentação extensa

3. **Flexibilidade de Configuração**
   - Linguagem de configuração poderosa
   - Módulos extensivos
   - Suporte a Lua scripting
   - SSL/TLS robusto

4. **Ecossistema Rico**
   - Múltiplas distribuições
   - Integração com CDNs
   - Monitoring tools
   - Third-party modules

#### Desvantagens

**❌ Contras**

1. **Configuração Complexa**
   - Sintaxe específica do NGINX
   - Recarregamento para mudanças
   - Debugging desafiador
   - Configuração não declarativa

2. **Limitações Programáticas**
   - Lógica complexa requer Lua
   - Sem APIs dinâmicas nativas
   - Reconfiguração manual
   - Observabilidade básica

#### Configuração Básica

```nginx
upstream backend {
    server backend1.example.com:443;
    server backend2.example.com:443;
    
    keepalive 32;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    location / {
        proxy_pass https://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Buffer responses for synchronous clients
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
    }
    
    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

#### Rate Limiting

```nginx
# Define rate limiting zones
http {
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $server_name zone=perserver:10m rate=100r/s;
    
    server {
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            limit_req zone=perserver burst=50;
            
            proxy_pass https://backend;
        }
    }
}
```

#### Lua Scripting

```nginx
location /dynamic {
    access_by_lua_block {
        local headers = ngx.req.get_headers()
        local user_type = headers["x-user-type"]
        
        if user_type == "premium" then
            ngx.var.backend = "premium_backend"
        else
            ngx.var.backend = "standard_backend"
        end
    }
    
    proxy_pass https://$backend;
}
```

### Casos de Uso Ideais

**🎯 Quando Usar NGINX**

- **High-Performance Proxy**: Cenários com requirements extremos de performance
- **Static Content Serving**: Combinação de proxy e web server
- **Legacy Integration**: Integração com sistemas existentes
- **Cost-Sensitive**: Soluções com budget limitado

---

## Kong Gateway

### Características Principais

Kong é um API Gateway cloud-native construído sobre NGINX, focado em microserviços e APIs.

#### Vantagens

**✅ Prós**

1. **Ecosystem de Plugins**
   - 100+ plugins oficiais
   - Marketplace de plugins
   - Plugin development framework
   - Extensibilidade via Lua

2. **Management APIs**
   - RESTful admin API
   - Configuração dinâmica
   - Database-backed ou DB-less
   - GitOps workflows

3. **Enterprise Features**
   - Kong Manager UI
   - RBAC e workspace isolation
   - Analytics e monitoring
   - Support enterprise

4. **Cloud-Native**
   - Kubernetes native
   - Service mesh integration
   - Declarative configuration
   - Horizontal scaling

#### Desvantagens

**❌ Contras**

1. **Complexidade Operacional**
   - Learning curve para plugins
   - Database dependencies (optional)
   - Plugin configuration complexity
   - Resource overhead

2. **Licensing Model**
   - Enterprise features são pagas
   - Community edition limitada
   - Plugin restrictions
   - Support limitations

#### Configuração Básica

```yaml
# Kong configuration via YAML (DB-less mode)
_format_version: "3.0"

services:
- name: backend-service
  url: https://backend.example.com:443
  
routes:
- name: api-route
  service: backend-service
  hosts:
  - api.example.com
  paths:
  - /api
  
plugins:
- name: rate-limiting
  service: backend-service
  config:
    minute: 100
    hour: 1000
    policy: local

- name: key-auth
  service: backend-service
  config:
    key_names:
    - apikey
    
- name: cors
  service: backend-service
  config:
    origins:
    - "https://frontend.example.com"
    methods:
    - GET
    - POST
    - PUT
    - DELETE
    headers:
    - Accept
    - Accept-Version
    - Content-Length
    - Content-MD5
    - Content-Type
    - Date
    - X-Auth-Token
    exposed_headers:
    - X-Auth-Token
    credentials: true
    max_age: 3600
```

#### Plugin Development

```lua
-- custom-auth plugin
local CustomAuthHandler = {}

function CustomAuthHandler:access(conf)
    local headers = kong.request.get_headers()
    local auth_header = headers["authorization"]
    
    if not auth_header then
        return kong.response.exit(401, {message = "Missing authorization header"})
    end
    
    -- Custom validation logic
    local valid = validate_token(auth_header)
    if not valid then
        return kong.response.exit(403, {message = "Invalid token"})
    end
    
    -- Add user context to upstream
    kong.service.request.set_header("x-user-id", user_id)
end

return CustomAuthHandler
```

#### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kong-gateway
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kong
  template:
    metadata:
      labels:
        app: kong
    spec:
      containers:
      - name: kong
        image: kong:3.4
        env:
        - name: KONG_DATABASE
          value: "off"
        - name: KONG_DECLARATIVE_CONFIG
          value: "/kong/kong.yml"
        - name: KONG_PROXY_ACCESS_LOG
          value: "/dev/stdout"
        - name: KONG_ADMIN_ACCESS_LOG
          value: "/dev/stdout"
        - name: KONG_PROXY_ERROR_LOG
          value: "/dev/stderr"
        - name: KONG_ADMIN_ERROR_LOG
          value: "/dev/stderr"
        - name: KONG_ADMIN_LISTEN
          value: "0.0.0.0:8001"
        ports:
        - containerPort: 8000
        - containerPort: 8001
        volumeMounts:
        - name: kong-config
          mountPath: /kong
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
      volumes:
      - name: kong-config
        configMap:
          name: kong-config
```

### Casos de Uso Ideais

**🎯 Quando Usar Kong**

- **API-First Organizations**: Empresas focadas em APIs
- **Plugin Ecosystem**: Necessidade de funcionalidades específicas
- **Developer Experience**: Teams que valorizam DX
- **Enterprise Requirements**: Governança e compliance

---

## Traefik

### Características Principais

Traefik é um reverse proxy e load balancer moderno que funciona com Docker, Kubernetes, e outros orchestrators.

#### Vantagens

**✅ Prós**

1. **Service Discovery Automático**
   - Auto-discovery de serviços
   - Configuração dinâmica
   - Zero-config para containers
   - Multiple provider support

2. **Modern Architecture**
   - Cloud-native design
   - Container-first approach
   - Kubernetes native
   - Protocol agnostic

3. **Ease of Use**
   - Minimal configuration
   - Web UI dashboard
   - Automatic SSL certificates
   - Hot reloading

4. **Observabilidade Built-in**
   - Prometheus metrics
   - Tracing support
   - Access logs
   - Health checks

#### Desvantagens

**❌ Contras**

1. **Performance Limitations**
   - Go runtime overhead
   - Não otimizado para static content
   - Memory usage higher
   - CPU overhead para discovery

2. **Enterprise Features Limited**
   - Menos plugins que Kong
   - Rate limiting básico
   - Advanced features são pagas
   - Community support limitado

#### Configuração Básica

```yaml
# traefik.yml
api:
  dashboard: true
  insecure: true

entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

providers:
  kubernetes:
    endpoints:
    - "https://kubernetes.default.svc:443"

certificatesResolvers:
  letsencrypt:
    acme:
      tlsChallenge: {}
      email: admin@example.com
      storage: acme.json

metrics:
  prometheus:
    addEntryPointsLabels: true
    addServicesLabels: true

tracing:
  jaeger:
    samplingServerURL: http://jaeger:14268/api/sampling
    localAgentHostPort: jaeger:6831
```

#### Kubernetes Integration

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: api-route
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    match: Host(`api.example.com`) && PathPrefix(`/api`)
    services:
    - name: backend-service
      port: 8080
      weight: 100
    middlewares:
    - name: rate-limit
    - name: auth
  tls:
    certResolver: letsencrypt

---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: rate-limit
spec:
  rateLimit:
    burst: 100
    average: 50

---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: auth
spec:
  basicAuth:
    secret: auth-secret
```

#### Docker Compose

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@example.com"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./letsencrypt:/letsencrypt"

  backend:
    image: nginx:alpine
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=Host(`api.example.com`)"
      - "traefik.http.routers.backend.entrypoints=websecure"
      - "traefik.http.routers.backend.tls.certresolver=letsencrypt"
      - "traefik.http.services.backend.loadbalancer.server.port=80"
```

### Casos de Uso Ideais

**🎯 Quando Usar Traefik**

- **Container Environments**: Docker/Kubernetes deployments
- **Dynamic Infrastructure**: Auto-scaling environments
- **Development Teams**: Rapid prototyping e development
- **SSL Automation**: Automatic certificate management

---

## Comparação Consolidada

### Performance Comparison

| Solução | Throughput | Latência | Memory | CPU |
|---------|------------|----------|---------|-----|
| **NGINX** | Muito Alto | Muito Baixa | Baixo | Baixo |
| **Kong** | Alto | Baixa | Médio | Médio |
| **Traefik** | Médio | Média | Alto | Alto |

### Feature Matrix

| Feature | NGINX | Kong | Traefik |
|---------|-------|------|---------|
| **Rate Limiting** | Básico | Avançado | Básico |
| **Authentication** | Básico | Rico | Médio |
| **Service Discovery** | Manual | API-driven | Automático |
| **SSL/TLS** | Manual | Automático | Automático |
| **Plugins** | Lua only | 100+ plugins | Middlewares |
| **UI Dashboard** | Terceiros | Enterprise | Built-in |
| **Configuration** | Files | API/Files | Auto/Files |
| **Observability** | Básica | Rica | Boa |

### Deployment Complexity

| Aspecto | NGINX | Kong | Traefik |
|---------|-------|------|---------|
| **Setup** | Médio | Alto | Baixo |
| **Configuration** | Alto | Médio | Baixo |
| **Maintenance** | Médio | Alto | Baixo |
| **Troubleshooting** | Alto | Médio | Médio |
| **Scaling** | Manual | Automático | Automático |

## Guia de Decisão

### Escolha NGINX quando

- Performance é crítica
- Infraestrutura tradicional
- Orçamento limitado
- Expertise existente em NGINX
- Necessidade de custom logic via Lua
- Serving static content junto com proxy

### Escolha Kong quando

- API management é prioridade
- Necessita de plugins ricos
- Governance e compliance
- Developer portal requirements
- Enterprise support
- Microservices architecture complexa

### Escolha Traefik quando

- Container-first environment
- Kubernetes native
- Auto-discovery requirements
- Development/staging environments
- Rapid deployment needs
- Small to medium scale

## Best Practices Gerais

### Security Hardening

```nginx
# NGINX Security Headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Content-Security-Policy "default-src 'self'" always;

# Hide version information
server_tokens off;

# Rate limiting
limit_req_zone $binary_remote_addr zone=global:10m rate=10r/s;
limit_req zone=global burst=20 nodelay;
```

### Monitoring e Observabilidade

```yaml
# Prometheus monitoring for all solutions
scrape_configs:
- job_name: 'nginx'
  static_configs:
  - targets: ['nginx-exporter:9113']

- job_name: 'kong'
  static_configs:
  - targets: ['kong:8001']
  metrics_path: /metrics

- job_name: 'traefik'
  static_configs:
  - targets: ['traefik:8080']
  metrics_path: /metrics
```

### High Availability

```yaml
# Kubernetes HA deployment pattern
apiVersion: apps/v1
kind: Deployment
metadata:
  name: proxy-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - proxy
              topologyKey: kubernetes.io/hostname
```

## Referências e Documentação

### NGINX

- [NGINX Documentation](https://nginx.org/en/docs/)
- [NGINX Plus](https://www.nginx.com/products/nginx/)
- [OpenResty](https://openresty.org/en/)

### Kong

- [Kong Gateway Documentation](https://docs.konghq.com/)
- [Kong Plugin Hub](https://docs.konghq.com/hub/)
- [Kong Kubernetes Ingress](https://github.com/Kong/kubernetes-ingress-controller)

### Traefik

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Traefik Proxy](https://traefik.io/traefik/)
- [Traefik Hub](https://traefik.io/traefik-hub/)

### Livros e Recursos

- "NGINX Cookbook" por Derek DeJonghe
- "Kong API Gateway" por Marco Palladino
- "Traefik Quick Start Guide" por Rahul Soni

### Artigos Técnicos

- [NGINX vs Kong vs Traefik](https://www.nginx.com/blog/comparing-kong-krakend-nginx-plus/)
- [API Gateway Pattern](https://microservices.io/patterns/apigateway.html)
- [Reverse Proxy Best Practices](https://blog.nginx.org/blog/avoiding-top-10-nginx-configuration-mistakes)

## Troubleshooting Comum

### NGINX Common Issues

```nginx
# Debug configuration
error_log /var/log/nginx/error.log debug;

# Test configuration
nginx -t

# Reload without downtime
nginx -s reload

# Common SSL issues
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
ssl_prefer_server_ciphers off;
```

### Kong Troubleshooting

```bash
# Check Kong status
kong health

# Validate configuration
kong config -c kong.conf parse

# Debug mode
KONG_LOG_LEVEL=debug kong start

# Plugin debugging
kong start --vv
```

### Traefik Debugging

```yaml
# Enable debug logging
log:
  level: DEBUG

# API endpoint for debugging
api:
  dashboard: true
  debug: true

# Check configuration
curl http://traefik:8080/api/rawdata
```

## Conclusão

As soluções tradicionais oferecem diferentes trade-offs:

**NGINX**: Ideal para maximum performance e controle total, especialmente quando expertise já existe.

**Kong**: Melhor para API management empresarial com necessidades de plugins ricos e governance.

**Traefik**: Excelente para ambientes cloud-native e container-first com necessidades de auto-discovery.

A escolha deve considerar:

- Performance requirements
- Operational complexity tolerance
- Team expertise
- Feature requirements
- Budget constraints
- Long-term maintenance strategy
