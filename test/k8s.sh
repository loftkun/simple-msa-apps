#! /bin/bash

# deploy
kubectl apply -f simple-msa-apps.yaml

# test
curl 192.168.99.100:32579
curl 192.168.99.100:32579?sleep=0
curl 192.168.99.100:32579?sleep=3
curl 192.168.99.100:32579?sleep=7
