#!/usr/bin/env bash
set -euo pipefail

# set -euo pipefail - torna a execução mais segura e previsível
# -e: pare no primeiro erro
# -u: erro se variável não estiver definida
# -o pipefail: detecta falha em qualquer parte do pipeline

echo "SCRIPT DE TESTE DE CI - REMOVER LISTA DOS LOAD BALANCER"

load_balancers_json=$(curl --request GET --url 'http://localhost:3003/mock/vultr/v2/load-balancers' \
            --header "Authorization: Bearer $VULTR_API_KEY")

if [ "$(echo "$load_balancers_json" | jq '.load_balancers | length')" -eq 0 ]; then
  echo "😉 Não foi encontrado load balancers provisionados no ambiente."
  exit 0
fi

load_balancer_ids=$(echo $load_balancers_json | jq -r '.load_balancers[] | .id')

if [[ -z "$load_balancer_ids" ]]; then
  echo "😉 Nenhum load balancer encontrado para remoção."
  exit 0
fi

echo "✅ Load balancers encontrados:"
echo "$load_balancer_ids"

while read -r load_balancer_id; do
  
  echo "---"
  echo "🔥 Removendo load balancer: ${load_balancer_id}"

  response_code=$(curl "http://localhost:3003/mock/vultr/v2/load-balancers/$load_balancer_id" \
    -X DELETE -H "Authorization: Bearer $VULTR_API_KEY" \
    -o /dev/null -w "%{http_code}")

  if [ "$response_code" -eq 204 ]; then
    echo "✅ Load balancer ${load_balancer_id} removido com sucesso."
  else
    echo "❌ Falha ao remover o load balancer ${load_balancer_id}. Código de resposta: $response_code"
  fi

done <<< "$load_balancer_ids"

echo ""
echo ""
echo "✅ Processo de remoção de load balancers concluído."
exit 0 