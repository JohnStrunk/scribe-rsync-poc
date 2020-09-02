#! /bin/bash

. ./configuration

# clone sync destination for app
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp apply -f - <<PVCS
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    meta.helm.sh/release-name: wp
    meta.helm.sh/release-namespace: wp
  labels:
    app.kubernetes.io/instance: wp
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: wordpress
    helm.sh/chart: wordpress-9.5.1
  name: wp-wordpress
spec:
  accessModes:
  - ReadWriteOnce
  dataSource:
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
    name: dest-wp-wordpress
  resources:
    requests:
      storage: 10Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app: mariadb
    component: master
    heritage: Helm
    release: wp
  name: data-wp-mariadb-0
spec:
  accessModes:
  - ReadWriteOnce
  dataSource:
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
    name: dest-data-wp-mariadb-0
  resources:
    requests:
      storage: 8Gi
PVCS

echo "Scaling up wordpress..."
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp scale --replicas=1 sts/wp-mariadb
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp scale --replicas=1 deploy/wp-wordpress

echo "Waiting for wordpress to be ready..."
sleep 5
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp wait --for condition=Available --timeout 120s deploy/wp-wordpress
