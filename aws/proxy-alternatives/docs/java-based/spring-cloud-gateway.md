# Spring Cloud Gateway

## Visão Geral

O Spring Cloud Gateway é um gateway de API baseado no Spring Framework que fornece uma forma simples, mas eficaz, de rotear para APIs e fornecer cross cutting concerns como segurança, monitoramento/métricas e resiliência.

## Características Principais

- **Arquitetura Reativa**: Construído sobre Spring WebFlux e Reactor Netty
- **Integração nativa com Spring**: Aproveitamento do ecossistema Spring
- **Filtros customizáveis**: Sistema extensível de filtros para modificar requests/responses
- **Roteamento dinâmico**: Predicados e filtros configuráveis
- **Observabilidade**: Integração nativa com Micrometer e sistemas de monitoramento

## Vantagens

### ✅ Prós

1. **Ecossistema Spring Maduro**
   - Integração nativa com Spring Boot
   - Extenso sistema de auto-configuração
   - Suporte a Spring Security out-of-the-box

2. **Flexibilidade de Programação**
   - Filtros customizados em Java
   - Configuração via YAML ou código
   - Sistema de predicados robusto

3. **Performance Reativa**
   - Non-blocking I/O via Reactor Netty
   - Suporte a backpressure
   - Eficiente no uso de recursos

4. **Observabilidade Integrada**
   - Micrometer para métricas
   - Tracing distribuído com Spring Cloud Sleuth
   - Health checks e actuator endpoints

5. **Facilidade de Teste**
   - Spring Test framework
   - Testcontainers integration
   - WebTestClient para testes integrados

## Desvantagens

### ❌ Contras

1. **Complexidade do Modelo Reativo**
   - Curva de aprendizado para programação reativa
   - Debugging pode ser desafiador
   - Tratamento de erros complexo

2. **Overhead da JVM**
   - Startup time mais lento
   - Memory footprint maior
   - Necessita tuning da JVM

3. **Problemas com Clientes Síncronos**
   - Chunked transfer encoding por padrão
   - Necessita configuração específica para buffering
   - Possíveis premature close exceptions

4. **Dependência do Ecossistema Spring**
   - Lock-in tecnológico
   - Atualizações dependem do roadmap Spring
   - Configuração pode ser verbosa

## Casos de Uso Ideais

### 🎯 Quando Usar

1. **Aplicações Java/Spring Existentes**
   - Quando já existe expertise em Spring
   - Integração com microserviços Spring Boot
   - Necessidade de customizações complexas

2. **Requisitos de Transformação de Dados**
   - Modificação de headers
   - Transformação de payloads
   - Validação de requests

3. **Integração com Spring Security**
   - Autenticação JWT
   - OAuth2/OIDC integration
   - Rate limiting avançado

4. **Observabilidade Avançada**
   - Métricas customizadas
   - Distributed tracing
   - Circuit breaker patterns

### ⚠️ Quando Evitar

1. **Proxy Transparente Simples**
   - Apenas roteamento básico
   - Performance crítica
   - Ambientes cloud-native

2. **Equipes Não-Java**
   - Falta de expertise em Spring
   - Preferência por soluções infrastructure-level
   - Arquiteturas polyglot

## Configurações

### Configuração Básica para Proxy Transparente

```yaml
server:
  port: 8080

spring:
  main:
    web-application-type: reactive
  cloud:
    gateway:
      httpserver:
        wiretap: false
      httpclient:
        wiretap: false
        connect-timeout: 5000
        response-timeout: 30s
        pool:
          type: fixed
          max-connections: 200
          acquire-timeout: 1000
        ssl:
          use-insecure-trust-manager: false
      default-filters:
        - PreserveHostHeader
      routes:
        - id: transparent-proxy
          uri: https://upstream.example.com
          predicates:
            - Path=/**
          filters:
            - RemoveRequestHeader=Cookie
```

### Configuração para Buffering (Clientes Síncronos)

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: buffered-proxy
          uri: https://upstream-backend.com
          predicates:
            - Path=/**
          filters:
            - PreserveHostHeader
            - name: ModifyResponseBody
              args:
                rewrite-function: com.example.BufferResponseFunction
```

### Configuração Avançada de TLS

```java
@Bean
public HttpClient httpClient() {
    return HttpClient.create()
        .secure(spec -> spec.sslContext(SslContextBuilder.forClient().build())
            .handlerConfigurator(handler -> {
                SSLParameters params = handler.engine().getSSLParameters();
                params.setServerNames(List.of(new SNIHostName("backend.example.com")));
                handler.engine().setSSLParameters(params);
            }));
}

@Bean
public GatewayHttpClientCustomizer customizer(HttpClient httpClient) {
    return builder -> builder.httpClient(httpClient);
}
```

## Métricas e Observabilidade

### Configuração Micrometer

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: gateway
      environment: production
```

### Filtros de Logging

```java
@Component
public class LoggingFilter implements GlobalFilter, Ordered {
    
    private static final Logger logger = LoggerFactory.getLogger(LoggingFilter.class);
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        logger.info("Request: {} {}", request.getMethod(), request.getURI());
        
        return chain.filter(exchange)
            .doOnSuccess(aVoid -> {
                ServerHttpResponse response = exchange.getResponse();
                logger.info("Response: {}", response.getStatusCode());
            });
    }
    
    @Override
    public int getOrder() {
        return -1;
    }
}
```

## Performance e Tuning

### Configurações de Performance

```yaml
spring:
  cloud:
    gateway:
      httpclient:
        pool:
          type: fixed
          max-connections: 100
          max-idle-time: 30s
          max-life-time: 60s
          acquire-timeout: 1000
        response-timeout: 30s
      httpserver:
        chunked-transfer: false  # Para clientes síncronos
```

### Configurações JVM Recomendadas

```bash
-Xms512m
-Xmx2g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=100
-XX:+HeapDumpOnOutOfMemoryError
-Dreactor.netty.ioWorkerCount=4
```

## Exemplos Práticos

### Filtro de Rate Limiting

```java
@Component
public class RateLimitingGlobalFilter implements GlobalFilter, Ordered {
    
    private final RedisTemplate<String, String> redisTemplate;
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String clientIp = getClientIp(exchange);
        
        return checkRateLimit(clientIp)
            .flatMap(allowed -> {
                if (allowed) {
                    return chain.filter(exchange);
                } else {
                    exchange.getResponse().setStatusCode(HttpStatus.TOO_MANY_REQUESTS);
                    return exchange.getResponse().setComplete();
                }
            });
    }
    
    private Mono<Boolean> checkRateLimit(String clientIp) {
        // Implementação Redis-based rate limiting
        return Mono.fromCallable(() -> {
            String key = "rate_limit:" + clientIp;
            String current = redisTemplate.opsForValue().get(key);
            
            if (current == null) {
                redisTemplate.opsForValue().set(key, "1", Duration.ofMinutes(1));
                return true;
            }
            
            int count = Integer.parseInt(current);
            if (count < 100) { // 100 requests per minute
                redisTemplate.opsForValue().increment(key);
                return true;
            }
            
            return false;
        });
    }
    
    @Override
    public int getOrder() {
        return -100;
    }
}
```

### Circuit Breaker Integration

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: circuit-breaker-route
          uri: https://upstream-service.com
          predicates:
            - Path=/api/**
          filters:
            - name: CircuitBreaker
              args:
                name: backendCircuitBreaker
                fallbackUri: forward:/fallback
resilience4j:
  circuitbreaker:
    instances:
      backendCircuitBreaker:
        slidingWindowSize: 10
        failureRateThreshold: 50
        waitDurationInOpenState: 30s
```

## Referências e Documentação

### Documentação Oficial

- [Spring Cloud Gateway Documentation](https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/)
- [Spring WebFlux Reference](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html)
- [Reactor Netty Reference](https://projectreactor.io/docs/netty/release/reference/index.html)

### Tutoriais e Guias

- [Building a Gateway with Spring Cloud Gateway](https://spring.io/guides/gs/gateway/)
- [Spring Cloud Gateway Circuit Breaker](https://spring.io/guides/gs/spring-cloud-circuit-breaker/)
- [Securing Spring Cloud Gateway](https://spring.io/blog/2019/08/16/securing-services-with-spring-cloud-gateway)

### Livros e Recursos

- "Spring in Action" por Craig Walls (6ª edição)
- "Reactive Programming with RxJava" por Tomasz Nurkiewicz
- "Building Microservices with Spring Boot" por Dinesh Rajput

### Artigos Técnicos

- [Spring Cloud Gateway Performance Tuning](https://medium.com/@niral22/spring-cloud-gateway-tutorial-5311ddd59816)
- [Troubleshooting Spring Cloud Gateway](https://www.baeldung.com/spring-cloud-gateway)
- [Spring Cloud Gateway vs Netflix Zuul](https://www.baeldung.com/spring-cloud-zuul-vs-gateway)

### Comunidade e Suporte

- [Spring Cloud Gateway GitHub](https://github.com/spring-cloud/spring-cloud-gateway)
- [Stack Overflow Tag](https://stackoverflow.com/questions/tagged/spring-cloud-gateway)
- [Spring Community Forum](https://community.spring.io/)

## Troubleshooting Comum

### Problema: PrematureCloseException

**Sintoma**: `reactor.netty.http.client.PrematureCloseException`

**Solução**:

```yaml
spring:
  cloud:
    gateway:
      httpclient:
        response-timeout: 60s
        pool:
          max-idle-time: 30s
```

### Problema: Memory Leaks

**Sintoma**: OutOfMemoryError após tempo de execução

**Solução**:

```java
@Bean
public NettyReactiveWebServerFactory nettyReactiveWebServerFactory() {
    NettyReactiveWebServerFactory factory = new NettyReactiveWebServerFactory();
    factory.addServerCustomizers(server -> server.tcpConfiguration(tcp -> 
        tcp.bootstrap(bootstrap -> bootstrap.option(ChannelOption.SO_KEEPALIVE, true))
    ));
    return factory;
}
```

### Problema: SSL Handshake Failures

**Sintoma**: SSLHandshakeException com upstream HTTPS

**Solução**:

```java
@Bean
public HttpClient httpClient() {
    return HttpClient.create()
        .secure(sslContextSpec -> sslContextSpec
            .sslContext(SslContextBuilder.forClient()
                .trustManager(InsecureTrustManagerFactory.INSTANCE))
            .handshakeTimeout(Duration.ofSeconds(30))
            .closeNotifyFlushTimeout(Duration.ofSeconds(10)));
}
```

## Conclusão

Spring Cloud Gateway é uma solução robusta para cenários que requerem:

- Integração profunda com ecossistema Spring
- Customizações complexas de lógica de roteamento
- Transformação de dados em tempo real
- Observabilidade avançada

Para cenários de proxy transparente simples ou ambientes que priorizam performance máxima, considere alternativas como Envoy Proxy ou NGINX.
