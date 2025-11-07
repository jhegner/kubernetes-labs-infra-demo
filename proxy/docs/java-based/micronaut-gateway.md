# Micronaut Gateway

## Visão Geral

Micronaut é um framework full-stack moderno para construir aplicações modulares e facilmente testáveis. Para proxy reverso, o Micronaut oferece uma alternativa leve ao Spring Cloud Gateway, utilizando Netty como base, mas com menor overhead e startup mais rápido.

## Características Principais

- **Arquitetura Reativa**: Baseado em Reactor e RxJava com Netty
- **Startup Rápido**: AOT (Ahead of Time) compilation
- **Baixo Memory Footprint**: Otimizado para microserviços
- **Compilação Nativa**: Suporte a GraalVM native image
- **Dependency Injection**: Compile-time DI sem reflection

## Vantagens

### ✅ Prós

1. **Performance Superior**
   - Startup time extremamente rápido (< 1 segundo)
   - Memory footprint reduzido (< 20MB)
   - AOT compilation elimina reflection overhead

2. **Cloud Native por Design**
   - Otimizado para containers
   - Suporte nativo a Kubernetes
   - Service discovery integrado

3. **Programação Reativa Simplificada**
   - API mais simples que Spring WebFlux
   - Suporte tanto RxJava quanto Reactor
   - Non-blocking por padrão

4. **Facilidade de Configuração**
   - Configuration as code
   - Type-safe configuration
   - Minimal boilerplate

5. **Observabilidade Integrada**
   - Micrometer built-in
   - Tracing distribuído
   - Health checks automáticos

## Desvantagens

### ❌ Contras

1. **Ecossistema Menor**
   - Menos bibliotecas de terceiros
   - Comunidade menor que Spring
   - Documentação menos extensa

2. **Curva de Aprendizado**
   - Diferenças conceituais com Spring
   - AOT compilation requer adaptação
   - Debugging pode ser desafiador

3. **Maturidade**
   - Framework relativamente novo
   - Algumas features ainda em desenvolvimento
   - Menos casos de uso em produção

4. **Limitações do Ecossistema**
   - Integração limitada com alguns sistemas legados
   - Menos plugins e extensões
   - Suporte corporativo limitado

## Casos de Uso Ideais

### 🎯 Quando Usar

1. **Microserviços Cloud-Native**
   - Aplicações containerizadas
   - Kubernetes deployments
   - Serverless functions

2. **Performance Crítica**
   - Low latency requirements
   - High throughput scenarios
   - Resource-constrained environments

3. **Desenvolvimento Ágil**
   - Prototipagem rápida
   - Desenvolvimento iterativo
   - CI/CD pipelines otimizados

4. **Modernização de Aplicações**
   - Migração de monolitos
   - Substituição de proxies pesados
   - Arquiteturas reativas

### ⚠️ Quando Evitar

1. **Equipes com Expertise Spring**
   - Investment pesado em Spring ecosystem
   - Equipes resistentes a mudanças
   - Sistemas legados complexos

2. **Requisitos de Integração Complexa**
   - Múltiplos sistemas enterprise
   - Transformações complexas de dados
   - Workflows de negócio sofisticados

## Implementação Básica

### Dependências Maven

```xml
<dependencies>
    <!-- Micronaut core -->
    <dependency>
        <groupId>io.micronaut</groupId>
        <artifactId>micronaut-http-server-netty</artifactId>
    </dependency>

    <!-- Reactive HTTP client -->
    <dependency>
        <groupId>io.micronaut</groupId>
        <artifactId>micronaut-http-client</artifactId>
    </dependency>

    <!-- Micrometer integration -->
    <dependency>
        <groupId>io.micronaut.micrometer</groupId>
        <artifactId>micronaut-micrometer-core</artifactId>
    </dependency>

    <!-- Prometheus -->
    <dependency>
        <groupId>io.micronaut.micrometer</groupId>
        <artifactId>micronaut-micrometer-registry-prometheus</artifactId>
    </dependency>

    <!-- Jackson for JSON -->
    <dependency>
        <groupId>io.micronaut</groupId>
        <artifactId>micronaut-jackson-databind</artifactId>
    </dependency>
</dependencies>
```

### Configuração Básica

```yaml
micronaut:
  application:
    name: micronaut-gateway
  server:
    port: 8080
    ssl:
      enabled: false
  http:
    services:
      upstream:
        url: https://backend.example.com
    client:
      read-timeout: 30s
      connect-timeout: 5s
      ssl:
        handshake-timeout: 10s

# Micrometer metrics
micrometer:
  enabled: true
  export:
    prometheus:
      enabled: true
      step: PT10S

endpoints:
  prometheus:
    enabled: true
    sensitive: false
```

### Proxy Controller Transparente

```java
import io.micronaut.http.*;
import io.micronaut.http.annotation.*;
import io.micronaut.http.client.*;
import io.micronaut.http.client.annotation.Client;
import io.micrometer.core.instrument.MeterRegistry;
import jakarta.inject.Inject;

@Controller
public class ProxyController {

    @Inject
    @Client("upstream")
    RxHttpClient httpClient;

    @Inject
    MeterRegistry meterRegistry;

    @Any
    @Consumes(MediaType.ALL)
    @Produces(MediaType.ALL)
    public HttpResponse<byte[]> proxy(HttpRequest<byte[]> request) {
        long start = System.nanoTime();

        HttpRequest<?> forwardReq = HttpRequest.create(
                request.getMethod(),
                request.getPath()
        )
        .headers(h -> h.addAll(request.getHeaders()))
        .body(request.getBody().orElse(null));

        try {
            // Fully block until upstream completes
            HttpResponse<byte[]> upstreamResponse =
                    httpClient.toBlocking()
                              .exchange(forwardReq, byte[].class);

            long duration = System.nanoTime() - start;
            meterRegistry.timer("proxy.requests", 
                "status", String.valueOf(upstreamResponse.getStatus().getCode()))
                         .record(duration, java.util.concurrent.TimeUnit.NANOSECONDS);

            return HttpResponse.status(upstreamResponse.getStatus())
                    .headers(h -> h.addAll(upstreamResponse.getHeaders()))
                    .body(upstreamResponse.body());

        } catch (Exception e) {
            meterRegistry.counter("proxy.errors",
                    "exception", e.getClass().getSimpleName()).increment();

            return HttpResponse.<byte[]>serverError(
                    ("Proxy error: " + e.getMessage()).getBytes()
            );
        }
    }
}
```

### Proxy Reativo (Não-Blocante)

```java
import reactor.core.publisher.Mono;

@Controller
public class ReactiveProxyController {

    @Inject
    @Client("upstream")
    RxHttpClient httpClient;

    @Any
    @Consumes(MediaType.ALL)
    @Produces(MediaType.ALL)
    public Mono<HttpResponse<byte[]>> proxyReactive(HttpRequest<byte[]> request) {
        HttpRequest<?> forwardReq = HttpRequest.create(
                request.getMethod(),
                request.getPath()
        )
        .headers(h -> h.addAll(request.getHeaders()))
        .body(request.getBody().orElse(null));

        return Mono.from(httpClient.exchange(forwardReq, byte[].class))
                .map(resp -> HttpResponse.status(resp.getStatus())
                        .headers(h -> h.addAll(resp.getHeaders()))
                        .body(resp.body()))
                .onErrorReturn(HttpResponse.serverError());
    }
}
```

## Configuração Avançada

### TLS e Certificados

```yaml
micronaut:
  http:
    client:
      ssl:
        insecure-trust-all-certificates: false
        trust-store:
          path: /path/to/truststore.jks
          password: changeit
          type: JKS
        key-store:
          path: /path/to/keystore.jks
          password: changeit
          type: JKS
```

### Connection Pooling

```yaml
micronaut:
  http:
    client:
      pool:
        enabled: true
        max-connections: 50
        max-pending-acquires: 100
        acquire-timeout: 1000ms
        max-idle-time: 30s
        max-life-time: 5m
```

### Health Checks

```java
@Singleton
public class UpstreamHealthIndicator implements HealthIndicator {

    @Inject
    @Client("upstream")
    RxHttpClient httpClient;

    @Override
    public Publisher<HealthResult> getResult() {
        return Mono.fromCallable(() -> {
            try {
                HttpResponse<?> response = httpClient.toBlocking()
                    .exchange(HttpRequest.GET("/health"));
                
                if (response.getStatus().getCode() == 200) {
                    return HealthResult.builder("upstream")
                        .status(HealthStatus.UP)
                        .build();
                } else {
                    return HealthResult.builder("upstream")
                        .status(HealthStatus.DOWN)
                        .build();
                }
            } catch (Exception e) {
                return HealthResult.builder("upstream")
                    .status(HealthStatus.DOWN)
                    .exception(e)
                    .build();
            }
        });
    }
}
```

## Filtros e Interceptors

### HTTP Filter Global

```java
@Filter("/**")
public class RequestResponseLoggingFilter implements HttpServerFilter {

    private static final Logger LOG = LoggerFactory.getLogger(RequestResponseLoggingFilter.class);

    @Override
    public Publisher<MutableHttpResponse<?>> doFilter(HttpRequest<?> request,
                                                      ServerFilterChain chain) {
        LOG.info("Request: {} {}", request.getMethod(), request.getUri());
        
        return Mono.from(chain.proceed(request))
                .doOnNext(response -> 
                    LOG.info("Response: {}", response.getStatus()));
    }
}
```

### Rate Limiting Filter

```java
@Filter("/**")
public class RateLimitingFilter implements HttpServerFilter {

    private final Map<String, AtomicInteger> requestCounts = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

    @PostConstruct
    public void init() {
        scheduler.scheduleAtFixedRate(() -> requestCounts.clear(), 1, 1, TimeUnit.MINUTES);
    }

    @Override
    public Publisher<MutableHttpResponse<?>> doFilter(HttpRequest<?> request,
                                                      ServerFilterChain chain) {
        String clientIp = getClientIp(request);
        int currentCount = requestCounts.computeIfAbsent(clientIp, k -> new AtomicInteger(0))
                                      .incrementAndGet();

        if (currentCount > 100) { // 100 requests per minute
            return Mono.just(HttpResponse.status(HttpStatus.TOO_MANY_REQUESTS));
        }

        return chain.proceed(request);
    }

    private String getClientIp(HttpRequest<?> request) {
        return request.getHeaders().get("X-Forwarded-For")
                .orElse(request.getRemoteAddress().getAddress().getHostAddress());
    }
}
```

## Testing

### Unit Tests

```java
@MicronautTest
class ProxyControllerTest {

    @Inject
    @Client("/")
    RxHttpClient client;

    @MockBean(RxHttpClient.class)
    RxHttpClient mockUpstreamClient() {
        return Mockito.mock(RxHttpClient.class);
    }

    @Test
    void testProxyForwardsRequest() {
        // Given
        HttpRequest<String> request = HttpRequest.POST("/api/data", "test");
        HttpResponse<String> mockResponse = HttpResponse.ok("response");

        when(mockUpstreamClient.toBlocking().exchange(any(), eq(byte[].class)))
            .thenReturn(HttpResponse.ok("response".getBytes()));

        // When
        HttpResponse<String> response = client.toBlocking()
            .exchange(request, String.class);

        // Then
        assertEquals(HttpStatus.OK, response.getStatus());
        assertEquals("response", response.body());
    }
}
```

### Integration Tests

```java
@MicronautTest
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class ProxyIntegrationTest {

    @Inject
    @Client("/")
    RxHttpClient client;

    @Container
    static GenericContainer<?> mockServer = new GenericContainer<>("mockserver/mockserver")
            .withExposedPorts(1080);

    @Test
    void testFullProxyFlow() {
        // Given: Configure mock server expectations
        mockServer.followOutput(Slf4jLogConsumer.withLogger(LOG));

        // When: Send request through proxy
        HttpResponse<String> response = client.toBlocking()
            .exchange(HttpRequest.GET("/api/test"), String.class);

        // Then: Verify response
        assertEquals(HttpStatus.OK, response.getStatus());
    }
}
```

## Observabilidade

### Configuração Micrometer

```java
@Factory
public class MetricsConfiguration {

    @Bean
    @Singleton
    public MeterRegistryCustomizer<PrometheusMeterRegistry> configureMeterRegistry() {
        return registry -> registry.config()
            .commonTags("application", "micronaut-gateway")
            .commonTags("version", "1.0.0");
    }

    @Bean
    @Singleton
    public TimedAspect timedAspect(MeterRegistry registry) {
        return new TimedAspect(registry);
    }
}
```

### Métricas Customizadas

```java
@Singleton
public class ProxyMetrics {

    private final Counter requestCounter;
    private final Timer responseTimer;
    private final Gauge upstreamConnections;

    public ProxyMetrics(MeterRegistry meterRegistry) {
        this.requestCounter = Counter.builder("proxy.requests.total")
            .description("Total number of proxy requests")
            .register(meterRegistry);

        this.responseTimer = Timer.builder("proxy.response.time")
            .description("Proxy response time")
            .register(meterRegistry);

        this.upstreamConnections = Gauge.builder("proxy.upstream.connections")
            .description("Active upstream connections")
            .register(meterRegistry, this, ProxyMetrics::getActiveConnections);
    }

    public void incrementRequests() {
        requestCounter.increment();
    }

    public Timer.Sample startTimer() {
        return Timer.start();
    }

    public void recordResponseTime(Timer.Sample sample) {
        sample.stop(responseTimer);
    }

    private double getActiveConnections() {
        // Implementation to get active connections
        return 0.0;
    }
}
```

## Deployment

### Docker Configuration

```dockerfile
FROM openjdk:17-jre-slim

COPY target/micronaut-gateway-*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: micronaut-gateway
spec:
  replicas: 3
  selector:
    matchLabels:
      app: micronaut-gateway
  template:
    metadata:
      labels:
        app: micronaut-gateway
    spec:
      containers:
      - name: gateway
        image: micronaut-gateway:latest
        ports:
        - containerPort: 8080
        env:
        - name: MICRONAUT_ENVIRONMENTS
          value: "k8s"
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

## GraalVM Native Image

### Configuração

```xml
<plugin>
    <groupId>org.graalvm.buildtools</groupId>
    <artifactId>native-maven-plugin</artifactId>
    <configuration>
        <imageName>micronaut-gateway</imageName>
        <mainClass>com.example.Application</mainClass>
        <buildArgs>
            <buildArg>--no-fallback</buildArg>
            <buildArg>--install-exit-handlers</buildArg>
        </buildArgs>
    </configuration>
</plugin>
```

### Dockerfile Multi-stage

```dockerfile
FROM ghcr.io/graalvm/graalvm-ce:ol8-java17-22.3.0 AS builder

WORKDIR /app
COPY . .

RUN ./mvnw package -Pnative

FROM scratch
COPY --from=builder /app/target/micronaut-gateway ./micronaut-gateway

EXPOSE 8080
ENTRYPOINT ["./micronaut-gateway"]
```

## Performance Benchmarks

### Comparação de Startup Time

| Framework             | Startup Time | Memory (MB) |
|----------------------|--------------|-------------|
| Spring Cloud Gateway | 3.2s         | 180         |
| Micronaut Gateway    | 0.8s         | 45          |
| Micronaut Native     | 0.015s       | 8           |

### Throughput Comparison

| Framework             | RPS    | Latency P95 |
|----------------------|--------|-------------|
| Spring Cloud Gateway | 12,000 | 25ms        |
| Micronaut Gateway    | 15,000 | 18ms        |
| Micronaut Native     | 18,000 | 12ms        |

## Referências e Documentação

### Documentação Oficial

- [Micronaut Framework Documentation](https://docs.micronaut.io/)
- [Micronaut HTTP Client](https://docs.micronaut.io/latest/guide/index.html#httpClient)
- [Micronaut Reactive Programming](https://docs.micronaut.io/latest/guide/index.html#reactive)

### Tutoriais e Guias

- [Building a Gateway with Micronaut](https://guides.micronaut.io/latest/micronaut-http-client-maven-java.html)
- [Micronaut and GraalVM](https://guides.micronaut.io/latest/micronaut-creating-first-graal-app-maven-java.html)
- [Micronaut Kubernetes Integration](https://guides.micronaut.io/latest/micronaut-k8s-maven-java.html)

### Livros e Recursos

- "Building Microservices with Micronaut" por Nirmal Singh
- "Hands-On Reactive Programming with Reactor" por Rahul Sharma
- "Cloud Native Java" por Josh Long e Kenny Bastani

### Artigos Técnicos

- [Micronaut vs Spring Boot Performance](https://micronaut.io/blog/2020-06-26-micronaut-vs-spring-boot-performance.html)
- [Building Native Images with Micronaut](https://www.baeldung.com/micronaut-graalvm)
- [Micronaut HTTP Client Configuration](https://mrhaki.blogspot.com/2019/11/micronaut-mastery-configure-http-client.html)

### Comunidade e Suporte

- [Micronaut GitHub](https://github.com/micronaut-projects/micronaut-core)
- [Micronaut Community Slack](https://micronaut.io/community/)
- [Stack Overflow Tag](https://stackoverflow.com/questions/tagged/micronaut)

## Troubleshooting Comum

### Problema: Connection Pool Exhaustion

**Sintoma**: "Connection pool exhausted" exceptions

**Solução**:

```yaml
micronaut:
  http:
    client:
      pool:
        max-connections: 100
        max-pending-acquires: 200
        acquire-timeout: 2000ms
```

### Problema: SSL Certificate Issues

**Sintoma**: SSL handshake failures

**Solução**:

```java
@Bean
@Singleton
public SslContext sslContext() {
    return SslContextBuilder.forClient()
        .trustManager(InsecureTrustManagerFactory.INSTANCE)
        .build();
}
```

### Problema: Memory Leaks

**Sintoma**: OutOfMemoryError em produção

**Solução**:

```yaml
micronaut:
  server:
    netty:
      worker:
        threads: 4
      allocator:
        max-order: 3
```

## Conclusão

Micronaut Gateway oferece uma alternativa moderna e performática ao Spring Cloud Gateway, especialmente adequada para:

- Aplicações cloud-native que requerem startup rápido
- Ambientes com restrições de recursos
- Desenvolvimento de microserviços modernos
- Cenários que se beneficiam de GraalVM native images

A escolha entre Micronaut e Spring Cloud Gateway deve considerar fatores como expertise da equipe, requisitos de performance e integração com ecossistemas existentes.
