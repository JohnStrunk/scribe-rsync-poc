#! /bin/bash

. ./configuration

kubectl --kubeconfig "${DEST_KUBECONFIG}" -n wp delete \
        job/scribe-rsync-dest-maria  job/scribe-rsync-dest-wp \
        pvc/dest-data-wp-mariadb-0 pvc/dest-wp-wordpress \
        volumesnapshot/dest-data-wp-mariadb-0 volumesnapshot/dest-wp-wordpress
