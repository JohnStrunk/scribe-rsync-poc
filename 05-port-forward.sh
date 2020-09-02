#! /bin/bash

kubectl -n wp port-forward service/wp-wordpress 8080:80
