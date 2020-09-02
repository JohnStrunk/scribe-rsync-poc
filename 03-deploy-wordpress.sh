#! /bin/bash

. ./configuration

helm install --kubeconfig "${SRC_KUBECONFIG}" --create-namespace -n wp -f wordpress-values.yml --set mariadb.volumePermissions.enabled=true wp bitnami/wordpress

echo "Waiting for wordpress to be ready..."
sleep 5
kubectl --kubeconfig "${SRC_KUBECONFIG}" -n wp wait --for condition=Available --timeout 300s deploy/wp-wordpress
