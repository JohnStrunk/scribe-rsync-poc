#! /bin/bash

. ./configuration

kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp apply -f destination-secret.yaml
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp apply -f deploy-destination.yaml
