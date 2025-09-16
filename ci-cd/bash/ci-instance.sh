#!/usr/bin/env bash
set -euo pipefail

# set -euo pipefail - torna a execução mais segura e previsível
# -e: pare no primeiro erro
# -u: erro se variável não estiver definida
# -o pipefail: detecta falha em qualquer parte do pipeline

echo "SCRIPT DE TESTE DE CI - REMOVER LISTA DOS LOAD BALANCER"

instances_json=$(curl --request GET --url 'http://localhost:3003/mock/vultr/v2/instances' \
            --header "Authorization: Bearer $VULTR_API_KEY")

if [ "$(echo "$instances_json" | jq '.instances | length')" -eq 0 ]; then
  echo "😉 Não foi encontrado instancias provisionados no ambiente."
  exit 0
fi

instances_ids=$(echo $instances_json | jq -r '.instances[] | .id')

if [[ -z "$instances_ids" ]]; then
  echo "😉 Nenhuma instancia encontrada para remoção."
  exit 0
fi

echo "✅ Instancias de computacao encontradas:"
echo "$instances_ids"

while read -r instance_id; do
  
  echo "---"
  echo "🔥 Removendo compute instance: ${instance_id}"

  response_code=$(curl "http://localhost:3003/mock/vultr/v2/instances/$instance_id" \
    -X DELETE -H "Authorization: Bearer $VULTR_API_KEY" \
    -o /dev/null -w "%{http_code}")

  if [ "$response_code" -eq 204 ]; then
    echo "✅ Instancia ${instance_id} removida com sucesso."
  else
    echo "❌ Falha ao remover instancia ${instance_id}. Código de resposta: $response_code"
  fi

done <<< "$instances_ids"

echo "---"
echo "✅ Processo adicional de remoção de instancias de computacao concluído."
exit 0 
