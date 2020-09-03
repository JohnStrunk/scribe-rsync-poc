#! /bin/bash

. ./configuration

kubectl --kubeconfig "${DEST_KUBECONFIG}" create ns wp

# We're running WP as root, so give it access no anyuid SCC
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp apply -f - <<SCC
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: anyuid
rules:
  - apiGroups:
      - security.openshift.io
    resourceNames:
      - anyuid
    resources:
      - securitycontextconstraints
    verbs:
      - use

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: anyuid
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: anyuid
subjects:
  - kind: ServiceAccount
    name: default
SCC

helm install --kubeconfig "${DEST_KUBECONFIG}" -n wp -f wordpress-values.yml wp bitnami/wordpress

echo "Waiting for wordpress to be ready..."
sleep 5
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp wait --for condition=Available --timeout 300s deploy/wp-wordpress

echo "Scaling down wordpress..."
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp scale --replicas=0 deploy/wp-wordpress
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp scale --replicas=0 sts/wp-mariadb

echo "Removing volumes..."
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp delete pvc/wp-wordpress pvc/data-wp-mariadb-0

# copy the db secret across
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp delete secrets/wp-mariadb
kubectl --kubeconfig "${SRC_KUBECONFIG}" -n wp get secrets/wp-mariadb -oyaml | kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp apply -f -
