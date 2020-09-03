#! /bin/bash

. ./configuration

echo "Scaling down wordpress..."
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp scale --replicas=0 deploy/wp-wordpress
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp scale --replicas=0 sts/wp-mariadb

echo "Removing volumes..."
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp delete pvc/wp-wordpress pvc/data-wp-mariadb-0
