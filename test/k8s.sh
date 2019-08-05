#! /bin/bash

MANIFEST=simple-msa-apps.yaml

# deploy
kubectl apply -f ${MANIFEST}

# test
NODE=192.168.99.100
NODE_PORT=31168
curl ${NODE}:${NODE_PORT}
curl ${NODE}:${NODE_PORT}?sleep=0
curl ${NODE}:${NODE_PORT}?sleep=3
curl ${NODE}:${NODE_PORT}?sleep=7

# undeploy
kubectl delete -f ${MANIFEST}


# Istio : side car injection
INJECTED=simple-msa-apps-injected.yaml
istioctl kube-inject -f ${MANIFEST} > ${INJECTED}

# deploy
kubectl apply -f ${INJECTED}

NODE_PORT=31168

# test
curl ${NODE}:${NODE_PORT} --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=0 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=1 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=2 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=3 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=4 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=5 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=6 --w "%{time_total}\n"

# result
# $ curl ${NODE}:${NODE_PORT} --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 0.049954
# $ curl ${NODE}:${NODE_PORT}?sleep=0 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 0.028058
# $ curl ${NODE}:${NODE_PORT}?sleep=1 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 1.042021
# $ curl ${NODE}:${NODE_PORT}?sleep=2 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 2.014272
# $ curl ${NODE}:${NODE_PORT}?sleep=3 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 3.036054
# $ curl ${NODE}:${NODE_PORT}?sleep=4 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 4.018709
# $ curl ${NODE}:${NODE_PORT}?sleep=5 --w "%{time_total}\n"
# {"app1":"HTTPConnectionPool(host='app2', port=5000): Read timed out. (read timeout=5.0)"}
# 5.024508
# $ curl ${NODE}:${NODE_PORT}?sleep=6 --w "%{time_total}\n"
# {"app1":"HTTPConnectionPool(host='app2', port=5000): Read timed out. (read timeout=5.0)"}
# 5.014393
# $

# Istio : Injecting an HTTP delay fault
kubectl apply -f fault-injection.yaml

curl ${NODE}:${NODE_PORT} --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=0 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=1 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=2 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=3 --w "%{time_total}\n"


# result
# $ kubectl apply -f fault-injection.yaml
# virtualservice.networking.istio.io/inject-delay created
# $ curl ${NODE}:${NODE_PORT} --w "%{time_total}\n"
# {"app1":"HTTPConnectionPool(host='app2', port=5000): Read timed out. (read timeout=5.0)"}
# 5.019319
# $ curl ${NODE}:${NODE_PORT}?sleep=0 --w "%{time_total}\n"
# {"app1":"HTTPConnectionPool(host='app2', port=5000): Read timed out. (read timeout=5.0)"}
# 5.017967
# $ curl ${NODE}:${NODE_PORT}?sleep=1 --w "%{time_total}\n"
# {"app1":"HTTPConnectionPool(host='app2', port=5000): Read timed out. (read timeout=5.0)"}
# 5.023193
# $ curl ${NODE}:${NODE_PORT}?sleep=2 --w "%{time_total}\n"
# {"app1":"HTTPConnectionPool(host='app2', port=5000): Read timed out. (read timeout=5.0)"}
# 5.032757
# $ curl ${NODE}:${NODE_PORT}?sleep=3 --w "%{time_total}\n"
# {"app1":"HTTPConnectionPool(host='app2', port=5000): Read timed out. (read timeout=5.0)"}
# 5.047976
# $

kubectl delete -f fault-injection.yaml

# Istio Request timeouts
kubectl apply -f timeout.yaml

curl ${NODE}:${NODE_PORT}?sleep=0 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=1 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=2 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=3 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=4 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=5 --w "%{time_total}\n"

# result
# $ kubectl apply -f timeout.yaml
# virtualservice.networking.istio.io/timeout created
# $ curl ${NODE}:${NODE_PORT}?sleep=0 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 0.025724
# $ curl ${NODE}:${NODE_PORT}?sleep=1 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 1.017233
# $ curl ${NODE}:${NODE_PORT}?sleep=2 --w "%{time_total}\n"
# {"app1":"<Response [504]>"}
# 2.022647
# $ curl ${NODE}:${NODE_PORT}?sleep=3 --w "%{time_total}\n"
# {"app1":"<Response [504]>"}
# 2.030336
# $ curl ${NODE}:${NODE_PORT}?sleep=4 --w "%{time_total}\n"
# {"app1":"<Response [504]>"}
# 2.018225
# $ curl ${NODE}:${NODE_PORT}?sleep=5 --w "%{time_total}\n"
# {"app1":"<Response [504]>"}
# 2.006588
# $

kubectl delete -f timeout.yaml
curl ${NODE}:${NODE_PORT}?sleep=0 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=1 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=2 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=3 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=4 --w "%{time_total}\n"
curl ${NODE}:${NODE_PORT}?sleep=5 --w "%{time_total}\n"

# result
# $ kubectl delete -f timeout.yaml
# virtualservice.networking.istio.io "timeout" deleted
# $ curl ${NODE}:${NODE_PORT}?sleep=0 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 0.021271
# $ curl ${NODE}:${NODE_PORT}?sleep=1 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 1.021662
# $ curl ${NODE}:${NODE_PORT}?sleep=2 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 2.037967
# $ curl ${NODE}:${NODE_PORT}?sleep=3 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 3.036650
# $ curl ${NODE}:${NODE_PORT}?sleep=4 --w "%{time_total}\n"
# {"app1":"<Response [200]>"}
# 4.032592
# $ curl ${NODE}:${NODE_PORT}?sleep=5 --w "%{time_total}\n"
# {"app1":"HTTPConnectionPool(host='app2', port=5000): Read timed out. (read timeout=5.0)"}
# 5.045736
# $

