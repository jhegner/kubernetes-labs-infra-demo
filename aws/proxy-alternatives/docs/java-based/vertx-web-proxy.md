# Vert.x Web Proxy

## Visão Geral

Eclipse Vert.x é um toolkit para construir aplicações reativas na JVM. O Vert.x Web Proxy oferece uma solução de proxy reverso de alta performance com APIs simples e diretas, ideais para cenários que requerem controle total sobre o comportamento do proxy.

## Características Principais

- **Event Loop Non-Blocking**: Arquitetura baseada em event loops
- **Alta Performance**: Construído sobre Netty com otimizações específicas
- **APIs Simples**: Interface direta sem abstrações desnecessárias
- **Flexibilidade Total**: Controle completo sobre headers, routing e transformações
- **Multi-Language**: Suporte a JavaScript, Kotlin, Scala e outras linguagens

## Vantagens

### ✅ Prós

1. **Performance Excepcional**
   - Event loop single-threaded otimizado
   - Zero-copy networking quando possível
   - Memory footprint extremamente baixo
   - Latência consistente e baixa

2. **Simplicidade Arquitetural**
   - APIs diretas e intuitivas
   - Menos layers de abstração
   - Debugging mais simples
   - Código mais previsível

3. **Controle Total**
   - Controle completo sobre requests/responses
   - Customização de connection pooling
   - Manipulação granular de headers
   - TLS configuration detalhada

4. **Polyglot Programming**
   - Suporte a múltiplas linguagens JVM
   - Interoperabilidade entre componentes
   - Reutilização de código

5. **Comunidade Ativa**
   - Ecossistema maduro
   - Extensa documentação
   - Suporte corporativo (Eclipse Foundation)

## Desvantagens

### ❌ Contras

1. **Paradigma Event-Driven**
   - Curva de aprendizado para callback hell
   - Complexidade em debugging assíncrono
   - Gerenciamento de estado desafiador

2. **Menos Features Out-of-Box**
   - Sem sistema de filtros automático
   - Circuit breakers não incluídos
   - Rate limiting manual

3. **Observabilidade Manual**
   - Métricas requerem implementação manual
   - Tracing distribuído não automático
   - Health checks customizados

4. **Ecossistema de Proxy Limitado**
   - Menos plugins específicos para proxy
   - Integração manual com service discovery
   - Configuration management personalizada

## Casos de Uso Ideais

### 🎯 Quando Usar

1. **Alta Performance Requerida**
   - Latência crítica (< 1ms)
   - Throughput extremo (> 100k RPS)
   - Resource-constrained environments

2. **Proxy Customizado**
   - Lógica de roteamento complexa
   - Transformações específicas
   - Integração com sistemas proprietários

3. **Microserviços Simples**
   - Proxy services especializados
   - Sidecar proxies
   - API Gateway minimalista

4. **Desenvolvimento de Protótipos**
   - POCs de alta performance
   - Testes de carga
   - Experimentação com protocolos

### ⚠️ Quando Evitar

1. **Equipes Inexperientes com Async**
   - Falta de experiência com callbacks
   - Preferência por programação síncrona
   - Requisitos de manutenibilidade alta

2. **Features Avançadas de Gateway**
   - Sistema de plugins robusto
   - Configuração declarativa
   - Integração enterprise complexa

## Implementação Básica

### Dependências Maven

```xml
<dependencies>
    <!-- Vert.x Core -->
    <dependency>
        <groupId>io.vertx</groupId>
        <artifactId>vertx-core</artifactId>
        <version>4.4.6</version>
    </dependency>

    <!-- Vert.x Web -->
    <dependency>
        <groupId>io.vertx</groupId>
        <artifactId>vertx-web</artifactId>
        <version>4.4.6</version>
    </dependency>

    <!-- Vert.x Web Client -->
    <dependency>
        <groupId>io.vertx</groupId>
        <artifactId>vertx-web-client</artifactId>
        <version>4.4.6</version>
    </dependency>

    <!-- Vert.x Web Proxy -->
    <dependency>
        <groupId>io.vertx</groupId>
        <artifactId>vertx-web-proxy</artifactId>
        <version>4.4.6</version>
    </dependency>

    <!-- Logging -->
    <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
        <version>1.4.11</version>
    </dependency>
</dependencies>
```

### Proxy Básico com HttpProxy

```java
import io.vertx.core.AbstractVerticle;
import io.vertx.core.Promise;
import io.vertx.core.http.HttpClient;
import io.vertx.core.http.HttpServer;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.proxy.handler.ProxyHandler;
import io.vertx.httpproxy.HttpProxy;

public class SimpleProxyVerticle extends AbstractVerticle {

    @Override
    public void start(Promise<Void> startPromise) {
        HttpClient client = vertx.createHttpClient();
        
        // Create HTTP proxy
        HttpProxy proxy = HttpProxy.reverseProxy(client);
        proxy.origin(443, "backend.example.com");

        // Setup router
        Router router = Router.router(vertx);
        
        // All requests go through proxy
        router.route().handler(ProxyHandler.create(proxy));

        // Create HTTP server
        HttpServer server = vertx.createHttpServer();
        
        server.requestHandler(router)
              .listen(8080)
              .onSuccess(result -> {
                  System.out.println("Proxy server started on port 8080");
                  startPromise.complete();
              })
              .onFailure(startPromise::fail);
    }
}
```

### Proxy Customizado com WebClient

```java
import io.vertx.core.AbstractVerticle;
import io.vertx.core.Promise;
import io.vertx.core.http.HttpMethod;
import io.vertx.core.http.HttpServer;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.client.WebClient;
import io.vertx.ext.web.client.WebClientOptions;

public class CustomProxyVerticle extends AbstractVerticle {

    private WebClient webClient;

    @Override
    public void start(Promise<Void> startPromise) {
        WebClientOptions options = new WebClientOptions()
            .setSsl(true)
            .setTrustAll(true)  // Para desenvolvimento apenas
            .setDefaultHost("backend.example.com")
            .setDefaultPort(443);

        webClient = WebClient.create(vertx, options);

        Router router = Router.router(vertx);
        
        // Handle all methods and paths
        router.route().handler(ctx -> {
            String path = ctx.request().path();
            HttpMethod method = ctx.request().method();
            
            // Forward request
            webClient.request(method, path)
                .putHeaders(ctx.request().headers())
                .sendBuffer(ctx.getBody())
                .onSuccess(response -> {
                    // Forward response
                    ctx.response()
                        .setStatusCode(response.statusCode())
                        .putHeaders(response.headers())
                        .end(response.bodyAsBuffer());
                })
                .onFailure(error -> {
                    ctx.response()
                        .setStatusCode(500)
                        .end("Proxy error: " + error.getMessage());
                });
        });

        HttpServer server = vertx.createHttpServer();
        server.requestHandler(router)
              .listen(8080)
              .onSuccess(result -> {
                  System.out.println("Custom proxy started on port 8080");
                  startPromise.complete();
              })
              .onFailure(startPromise::fail);
    }
}
```

## Configurações Avançadas

### TLS e Certificados

```java
import io.vertx.core.net.PemKeyCertOptions;
import io.vertx.core.net.PemTrustOptions;
import io.vertx.ext.web.client.WebClientOptions;

public class TLSProxyVerticle extends AbstractVerticle {

    @Override
    public void start(Promise<Void> startPromise) {
        // Client TLS configuration
        WebClientOptions clientOptions = new WebClientOptions()
            .setSsl(true)
            .setPemTrustOptions(new PemTrustOptions()
                .addCertPath("/path/to/ca.crt"))
            .setPemKeyCertOptions(new PemKeyCertOptions()
                .setCertPath("/path/to/client.crt")
                .setKeyPath("/path/to/client.key"));

        WebClient webClient = WebClient.create(vertx, clientOptions);

        // Server TLS configuration
        HttpServerOptions serverOptions = new HttpServerOptions()
            .setSsl(true)
            .setPemKeyCertOptions(new PemKeyCertOptions()
                .setCertPath("/path/to/server.crt")
                .setKeyPath("/path/to/server.key"));

        Router router = Router.router(vertx);
        router.route().handler(ctx -> proxyRequest(ctx, webClient));

        vertx.createHttpServer(serverOptions)
             .requestHandler(router)
             .listen(8443)
             .onSuccess(result -> {
                 System.out.println("TLS Proxy started on port 8443");
                 startPromise.complete();
             })
             .onFailure(startPromise::fail);
    }

    private void proxyRequest(RoutingContext ctx, WebClient client) {
        // Implementation details...
    }
}
```

### Connection Pooling

```java
import io.vertx.core.http.HttpClientOptions;

public class PooledProxyVerticle extends AbstractVerticle {

    @Override
    public void start(Promise<Void> startPromise) {
        HttpClientOptions clientOptions = new HttpClientOptions()
            .setMaxPoolSize(100)
            .setMaxWaitQueueSize(200)
            .setKeepAlive(true)
            .setTcpKeepAlive(true)
            .setIdleTimeout(30)
            .setConnectTimeout(5000)
            .setSsl(true)
            .setTrustAll(true);

        HttpClient httpClient = vertx.createHttpClient(clientOptions);
        
        HttpProxy proxy = HttpProxy.reverseProxy(httpClient);
        proxy.origin(443, "backend.example.com");

        Router router = Router.router(vertx);
        router.route().handler(ProxyHandler.create(proxy));

        vertx.createHttpServer()
             .requestHandler(router)
             .listen(8080)
             .onSuccess(result -> {
                 System.out.println("Pooled proxy started");
                 startPromise.complete();
             })
             .onFailure(startPromise::fail);
    }
}
```

## Filtros e Interceptors

### Request/Response Logging

```java
public class LoggingProxyVerticle extends AbstractVerticle {

    @Override
    public void start(Promise<Void> startPromise) {
        WebClient webClient = WebClient.create(vertx);

        Router router = Router.router(vertx);
        
        // Logging handler
        router.route().handler(ctx -> {
            long startTime = System.currentTimeMillis();
            String requestId = UUID.randomUUID().toString().substring(0, 8);
            
            System.out.printf("[%s] Request: %s %s%n", 
                requestId, ctx.request().method(), ctx.request().path());

            ctx.put("requestId", requestId);
            ctx.put("startTime", startTime);
            ctx.next();
        });

        // Proxy handler
        router.route().handler(ctx -> {
            String requestId = ctx.get("requestId");
            Long startTime = ctx.get("startTime");

            webClient.request(ctx.request().method(), 443, "backend.example.com", ctx.request().path())
                .putHeaders(ctx.request().headers())
                .ssl(true)
                .sendBuffer(ctx.getBody())
                .onSuccess(response -> {
                    long duration = System.currentTimeMillis() - startTime;
                    System.out.printf("[%s] Response: %d (%dms)%n", 
                        requestId, response.statusCode(), duration);

                    ctx.response()
                        .setStatusCode(response.statusCode())
                        .putHeaders(response.headers())
                        .end(response.bodyAsBuffer());
                })
                .onFailure(error -> {
                    long duration = System.currentTimeMillis() - startTime;
                    System.out.printf("[%s] Error: %s (%dms)%n", 
                        requestId, error.getMessage(), duration);

                    ctx.response()
                        .setStatusCode(500)
                        .end("Proxy error: " + error.getMessage());
                });
        });

        vertx.createHttpServer()
             .requestHandler(router)
             .listen(8080, startPromise);
    }
}
```

### Rate Limiting

```java
import io.vertx.core.json.JsonObject;

public class RateLimitedProxyVerticle extends AbstractVerticle {
    
    private final Map<String, TokenBucket> rateLimiters = new ConcurrentHashMap<>();

    @Override
    public void start(Promise<Void> startPromise) {
        WebClient webClient = WebClient.create(vertx);

        Router router = Router.router(vertx);
        
        // Rate limiting handler
        router.route().handler(ctx -> {
            String clientIp = getClientIp(ctx);
            TokenBucket bucket = rateLimiters.computeIfAbsent(clientIp, 
                k -> new TokenBucket(100, 100)); // 100 requests per minute

            if (bucket.tryConsume(1)) {
                ctx.next();
            } else {
                ctx.response()
                    .setStatusCode(429)
                    .putHeader("X-RateLimit-Limit", "100")
                    .putHeader("X-RateLimit-Remaining", "0")
                    .end("Rate limit exceeded");
            }
        });

        // Proxy handler
        router.route().handler(ctx -> proxyRequest(ctx, webClient));

        // Cleanup rate limiters periodically
        vertx.setPeriodic(60000, id -> {
            rateLimiters.entrySet().removeIf(entry -> 
                entry.getValue().getAvailableTokens() == 100);
        });

        vertx.createHttpServer()
             .requestHandler(router)
             .listen(8080, startPromise);
    }

    private String getClientIp(RoutingContext ctx) {
        String xForwardedFor = ctx.request().getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return ctx.request().remoteAddress().host();
    }

    private void proxyRequest(RoutingContext ctx, WebClient client) {
        // Proxy implementation
    }

    // Simple token bucket implementation
    private static class TokenBucket {
        private long tokens;
        private final long capacity;
        private long lastRefill;

        public TokenBucket(long capacity, long initialTokens) {
            this.capacity = capacity;
            this.tokens = initialTokens;
            this.lastRefill = System.currentTimeMillis();
        }

        public synchronized boolean tryConsume(long tokensRequested) {
            refill();
            if (tokens >= tokensRequested) {
                tokens -= tokensRequested;
                return true;
            }
            return false;
        }

        private void refill() {
            long now = System.currentTimeMillis();
            long tokensToAdd = (now - lastRefill) / 1000; // 1 token per second
            tokens = Math.min(capacity, tokens + tokensToAdd);
            lastRefill = now;
        }

        public long getAvailableTokens() {
            refill();
            return tokens;
        }
    }
}
```

## Circuit Breaker Pattern

```java
import io.vertx.circuitbreaker.CircuitBreaker;
import io.vertx.circuitbreaker.CircuitBreakerOptions;

public class CircuitBreakerProxyVerticle extends AbstractVerticle {

    @Override
    public void start(Promise<Void> startPromise) {
        WebClient webClient = WebClient.create(vertx);

        CircuitBreakerOptions options = new CircuitBreakerOptions()
            .setMaxFailures(5)
            .setTimeout(5000)
            .setFallbackOnFailure(true)
            .setResetTimeout(30000);

        CircuitBreaker breaker = CircuitBreaker.create("proxy-breaker", vertx, options);

        Router router = Router.router(vertx);
        
        router.route().handler(ctx -> {
            breaker.<Void>execute(promise -> {
                webClient.request(ctx.request().method(), 443, "backend.example.com", ctx.request().path())
                    .putHeaders(ctx.request().headers())
                    .ssl(true)
                    .sendBuffer(ctx.getBody())
                    .onSuccess(response -> {
                        ctx.response()
                            .setStatusCode(response.statusCode())
                            .putHeaders(response.headers())
                            .end(response.bodyAsBuffer());
                        promise.complete();
                    })
                    .onFailure(promise::fail);
            }).onComplete(ar -> {
                if (ar.failed()) {
                    // Fallback response
                    ctx.response()
                        .setStatusCode(503)
                        .putHeader("X-Circuit-Breaker", "OPEN")
                        .end("Service temporarily unavailable");
                }
            });
        });

        vertx.createHttpServer()
             .requestHandler(router)
             .listen(8080, startPromise);
    }
}
```

## Observabilidade e Métricas

### Health Check

```java
public class HealthCheckProxyVerticle extends AbstractVerticle {

    private final AtomicLong requestCount = new AtomicLong(0);
    private final AtomicLong errorCount = new AtomicLong(0);
    private volatile boolean upstreamHealthy = true;

    @Override
    public void start(Promise<Void> startPromise) {
        WebClient webClient = WebClient.create(vertx);

        Router router = Router.router(vertx);

        // Health check endpoint
        router.get("/health").handler(ctx -> {
            JsonObject health = new JsonObject()
                .put("status", upstreamHealthy ? "UP" : "DOWN")
                .put("timestamp", Instant.now().toString())
                .put("details", new JsonObject()
                    .put("proxy", new JsonObject()
                        .put("requests", requestCount.get())
                        .put("errors", errorCount.get())
                        .put("errorRate", calculateErrorRate())));

            ctx.response()
                .putHeader("Content-Type", "application/json")
                .setStatusCode(upstreamHealthy ? 200 : 503)
                .end(health.encode());
        });

        // Metrics endpoint
        router.get("/metrics").handler(ctx -> {
            JsonObject metrics = new JsonObject()
                .put("proxy_requests_total", requestCount.get())
                .put("proxy_errors_total", errorCount.get())
                .put("proxy_error_rate", calculateErrorRate());

            ctx.response()
                .putHeader("Content-Type", "application/json")
                .end(metrics.encode());
        });

        // Proxy requests
        router.route().handler(ctx -> {
            requestCount.incrementAndGet();
            
            webClient.request(ctx.request().method(), 443, "backend.example.com", ctx.request().path())
                .putHeaders(ctx.request().headers())
                .ssl(true)
                .sendBuffer(ctx.getBody())
                .onSuccess(response -> {
                    upstreamHealthy = true;
                    ctx.response()
                        .setStatusCode(response.statusCode())
                        .putHeaders(response.headers())
                        .end(response.bodyAsBuffer());
                })
                .onFailure(error -> {
                    errorCount.incrementAndGet();
                    upstreamHealthy = false;
                    ctx.response()
                        .setStatusCode(500)
                        .end("Proxy error: " + error.getMessage());
                });
        });

        // Periodic health check of upstream
        vertx.setPeriodic(30000, id -> checkUpstreamHealth(webClient));

        vertx.createHttpServer()
             .requestHandler(router)
             .listen(8080, startPromise);
    }

    private void checkUpstreamHealth(WebClient client) {
        client.get(443, "backend.example.com", "/health")
            .ssl(true)
            .send()
            .onSuccess(response -> upstreamHealthy = response.statusCode() == 200)
            .onFailure(error -> upstreamHealthy = false);
    }

    private double calculateErrorRate() {
        long total = requestCount.get();
        long errors = errorCount.get();
        return total > 0 ? (double) errors / total : 0.0;
    }
}
```

## Testing

### Unit Tests

```java
import io.vertx.core.Vertx;
import io.vertx.ext.web.client.WebClient;
import io.vertx.junit5.VertxExtension;
import io.vertx.junit5.VertxTestContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

@ExtendWith(VertxExtension.class)
class ProxyVerticleTest {

    private WebClient client;

    @BeforeEach
    void setUp(Vertx vertx) {
        client = WebClient.create(vertx);
    }

    @Test
    void testProxyForwardsRequest(Vertx vertx, VertxTestContext context) {
        // Deploy test verticle
        vertx.deployVerticle(new SimpleProxyVerticle())
            .compose(deploymentId -> {
                // Test request
                return client.get(8080, "localhost", "/test")
                    .send();
            })
            .onSuccess(response -> {
                context.verify(() -> {
                    assertEquals(200, response.statusCode());
                });
                context.completeNow();
            })
            .onFailure(context::failNow);
    }
}
```

### Integration Tests

```java
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@ExtendWith(VertxExtension.class)
class ProxyIntegrationTest {

    @Container
    static GenericContainer<?> mockServer = new GenericContainer<>("mockserver/mockserver")
            .withExposedPorts(1080);

    @Test
    void testFullProxyFlow(Vertx vertx, VertxTestContext context) {
        String mockServerHost = mockServer.getHost();
        Integer mockServerPort = mockServer.getMappedPort(1080);

        // Configure proxy to use mock server
        ProxyVerticle verticle = new ProxyVerticle(mockServerHost, mockServerPort);
        
        vertx.deployVerticle(verticle)
            .compose(deploymentId -> {
                WebClient client = WebClient.create(vertx);
                return client.get(8080, "localhost", "/api/test")
                    .send();
            })
            .onSuccess(response -> {
                context.verify(() -> {
                    assertEquals(200, response.statusCode());
                    assertNotNull(response.bodyAsString());
                });
                context.completeNow();
            })
            .onFailure(context::failNow);
    }
}
```

## Deployment

### Docker Configuration

```dockerfile
FROM openjdk:17-jre-slim

COPY target/vertx-proxy-*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vertx-proxy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: vertx-proxy
  template:
    metadata:
      labels:
        app: vertx-proxy
    spec:
      containers:
      - name: proxy
        image: vertx-proxy:latest
        ports:
        - containerPort: 8080
        env:
        - name: JAVA_OPTS
          value: "-Xmx256m -Xms128m"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

## Performance Optimization

### Event Loop Tuning

```java
public class OptimizedProxyVerticle extends AbstractVerticle {

    @Override
    public void start(Promise<Void> startPromise) {
        // Configure for high performance
        HttpServerOptions serverOptions = new HttpServerOptions()
            .setTcpNoDelay(true)
            .setTcpKeepAlive(true)
            .setReuseAddress(true)
            .setReusePort(true)
            .setAcceptBacklog(1024);

        HttpClientOptions clientOptions = new HttpClientOptions()
            .setTcpNoDelay(true)
            .setTcpKeepAlive(true)
            .setMaxPoolSize(200)
            .setKeepAlive(true)
            .setPipelining(true)
            .setPipeliningLimit(10);

        HttpClient httpClient = vertx.createHttpClient(clientOptions);
        HttpProxy proxy = HttpProxy.reverseProxy(httpClient);
        proxy.origin(443, "backend.example.com");

        Router router = Router.router(vertx);
        router.route().handler(ProxyHandler.create(proxy));

        vertx.createHttpServer(serverOptions)
             .requestHandler(router)
             .listen(8080, startPromise);
    }
}
```

### JVM Options para Performance

```bash
java -XX:+UseG1GC \
     -XX:+UseStringDeduplication \
     -XX:MaxGCPauseMillis=50 \
     -Xmx1g \
     -Xms512m \
     -jar vertx-proxy.jar
```

## Referências e Documentação

### Documentação Oficial

- [Eclipse Vert.x Documentation](https://vertx.io/docs/)
- [Vert.x Web Proxy](https://vertx.io/docs/vertx-web-proxy/java/)
- [Vert.x Web Client](https://vertx.io/docs/vertx-web-client/java/)

### Tutoriais e Guias

- [Building a Proxy with Vert.x](https://vertx.io/blog/building-a-reverse-proxy-with-vert-x/)
- [Vert.x High Performance](https://vertx.io/docs/guide-for-java-devs/)
- [Event Loop Best Practices](https://vertx.io/docs/vertx-core/java/#golden_rule)

### Livros e Recursos

- "Vert.x in Action" por Julien Ponge
- "Building Reactive Microservices in Java" por Clément Escoffier
- "High Performance Browser Networking" por Ilya Grigorik

### Artigos Técnicos

- [Vert.x Performance Analysis](https://www.techempower.com/benchmarks/)
- [Event Loop vs Thread Pool](https://blog.hbfs.com.br/event-loop-vs-thread-pool/)
- [Vert.x Memory Management](https://vertx.io/blog/vertx-memory-management/)

### Comunidade e Suporte

- [Vert.x GitHub](https://github.com/eclipse-vertx/vert.x)
- [Vert.x Google Group](https://groups.google.com/g/vertx)
- [Stack Overflow Tag](https://stackoverflow.com/questions/tagged/vert.x)

## Troubleshooting Comum

### Problema: Event Loop Blocked

**Sintoma**: "Thread blocked" warnings

**Solução**:

```java
// Usar executeBlocking para operações CPU-intensive
vertx.executeBlocking(promise -> {
    // Operação bloqueante
    String result = heavyComputation();
    promise.complete(result);
}, result -> {
    // Callback no event loop
});
```

### Problema: Memory Leaks

**Sintoma**: OutOfMemoryError após tempo

**Solução**:

```java
// Sempre fechar recursos
webClient.close();
httpClient.close();

// Cancelar timers
vertx.cancelTimer(timerId);
```

### Problema: Connection Pool Exhaustion

**Sintoma**: Connection timeout errors

**Solução**:

```java
HttpClientOptions options = new HttpClientOptions()
    .setMaxPoolSize(100)
    .setMaxWaitQueueSize(200)
    .setPoolCleanerPeriod(10000);
```

## Conclusão

Vert.x Web Proxy é ideal para cenários que requerem:

- Performance máxima com recursos limitados
- Controle total sobre comportamento do proxy
- Arquiteturas event-driven
- Integração com sistemas de alta throughput

É especialmente adequado para equipes experientes em programação assíncrona e casos de uso que demandam customização específica do comportamento de proxy.
