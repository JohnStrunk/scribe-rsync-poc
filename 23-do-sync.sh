#! /bin/bash

. ./configuration

kubectl --kubeconfig "${SRC_KUBECONFIG}" -n wp apply -f source-secret.yaml

kubectl --kubeconfig "${SRC_KUBECONFIG}" -n wp delete job/scribe-rsync-source-wp job/scribe-rsync-source-maria
kubectl --kubeconfig "${SRC_KUBECONFIG}" -n wp delete pvc/source-wp-wordpress pvc/source-data-wp-mariadb-0

kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp delete job/scribe-rsync-dest-wp job/scribe-rsync-dest-maria
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp apply -f deploy-destination.yaml

sed -r "s/DEST_WP/${DEST_WP}/" deploy-source.yaml | \
sed -r "s/DEST_MARIA/${DEST_MARIA}/" | \
kubectl --kubeconfig "${SRC_KUBECONFIG}" -n wp apply -f -

echo Waiting for sync...
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp wait --for condition=Complete --timeout 300s job/scribe-rsync-dest-wp
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp wait --for condition=Complete --timeout 300s job/scribe-rsync-dest-maria

echo Snapshotting destination...
kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp apply -f - <<SNAPS
---
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshot
metadata:
  name: dest-data-wp-mariadb-0
spec:
  source:
    persistentVolumeClaimName: dest-data-wp-mariadb-0

---
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshot
metadata:
  name: dest-wp-wordpress
spec:
  source:
    persistentVolumeClaimName: dest-wp-wordpress
SNAPS
