#!/usr/bin/env bash
#
# https://k3d.io/v5.0.0/usage/exposing_services/

k3d cluster create --api-port 6550 -p "80:80@loadbalancer" --agents 2

sleep 30  # TODO find a better way
# wait for Traefik CRDs
 kubectl -n kube-system wait pod \
    --selector=app.kubernetes.io/name=traefik \
    --for=condition=Ready
kubectl -n kube-system wait --for=condition=Established customresourcedefinition/ingressroutes.traefik.containo.us

# Enable Traefik logging and expose dashboard on traefik.localhost:8080
#
cat <<EOF | kubectl apply -f -
# https://github.com/k3s-io/k3s/issues/2893#issuecomment-773654746
# https://github.com/traefik/traefik-helm-chart/blob/master/traefik/values.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    logs:
      access:
        enabled: true
    dashboard:
      domain: "traefik.localhost"
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dashboard-exposed
  namespace: kube-system
spec:
  entryPoints:
    - web
  routes:
    - match: Host(\`traefik.localhost\`) && (PathPrefix(\`/dashboard\`) || PathPrefix(\`/api\`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
EOF

