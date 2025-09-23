echo "Aplicando a instrumentação automática de APM..."

kubectl apply -f ./apm-auto-instrumentation.yaml -n newrelic

echo "😴 Aguardando..."
sleep 15s

echo "Finalizando a instalacao..."