echo "Installing New Relic K8s integration"

KSM_IMAGE_VERSION="v2.13.0" && \
helm repo add newrelic https://helm-charts.newrelic.com && \
helm repo update && \
kubectl create namespace newrelic

echo "😴 Aguardando..."
sleep 15s

echo "Continuing the installation of New Relic K8s integration..."

helm upgrade --install newrelic-bundle newrelic/nri-bundle \
    --set global.licenseKey=${NEW_RELIC_LICENSE_KEY} \
    --set global.cluster=kubernetes-labs-cluster --namespace=newrelic \
    --set global.lowDataMode=true \
    --set kube-state-metrics.image.tag=${KSM_IMAGE_VERSION} \
    --set kube-state-metrics.enabled=true \
    --set kubeEvents.enabled=true \
    --set newrelic-prometheus-agent.enabled=true \
    --set newrelic-prometheus-agent.lowDataMode=true \
    --set newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled=false \
    --set k8s-agents-operator.enabled=true

echo "Finalizando a instalacao..."