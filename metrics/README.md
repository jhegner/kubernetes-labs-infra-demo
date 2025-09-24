# Lab metrics server and dashboard

## Doc referente a monitoramento do cluster

Integracao **NewRelic**

- https://docs.newrelic.com/
- https://learn.newrelic.com/page/courses#cost_free
- https://docs.newrelic.com/install/kubernetes/


## APM auto instrumentação

Permite instrumentar as aplicações a nível do cluster sem a necessidade de realizar a instrumentação dos agentes em cada app.

The Kubernetes APM auto-attach will automatically install, upgrade and remove APM agents.



> Notice: Please be sure to redeploy or deploy new applications after you deploy the Custom Resource. Auto-instrumentation only occurs for new pods deployed in the cluster.

## Uso no Deployment

Necessario referenciar o LICENSE para que o agente seja injetado corretamente no container

[General configuration settings](https://docs.newrelic.com/docs/apm/agents/java-agent/configuration/java-agent-configuration-config-file/#General)

## Referências:

- https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/
- https://kubernetes-sigs.github.io/metrics-server/
- https://docs.aws.amazon.com/pt_br/eks/latest/userguide/metrics-server.html
- https://artifacthub.io/packages/helm/metrics-server/metrics-server
- https://docs.vultr.com/how-to-deploy-metrics-server-on-vultr-kubernetes-engine
- https://docs.newrelic.com/docs/kubernetes-pixie/kubernetes-integration/installation/k8s-agent-operator/