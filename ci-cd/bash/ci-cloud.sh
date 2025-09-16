echo "Remove instancias adicionais criadas por auto-scaling"

instances_json=$(curl --request GET --url 'https://api.vultr.com/v2/instances' \
  --header "Authorization: Bearer $VULTR_API_KEY")

#echo "DEBUG -> $instances_json"

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