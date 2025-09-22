echo "Upgrading New Relic Stack..." ;

helm repo update ; \
helm upgrade --install newrelic-bundle newrelic/nri-bundle -n newrelic --values values.yaml