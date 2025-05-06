# Contributing guide

All command lines must be ran from "charts/packmind" folder.

## Dependencies

Make sure to run `../../scripts/add_helm_repos.sh`.

Versions can be displayed with `helm search repo -l mongodb --versions`.

When you update `Chart.yaml`, run `helm dependency update` to update `Chart.lock`.

## Generated chart

Run `helm template packmind . -f values.yaml > temp.yaml` to look at what is generated.

## Validation

### Minimalist with MongoDB community operator

```bash
# installs or updates the Helm release
helm upgrade --install packmind-beta . -f values.yaml --create-namespace \
  --set app.databaseUri.value=mongodb://root:admin@packmind-beta-mongodb:27017/packmind?authSource=admin \
  --set mongodb.enabled=true,mongodb.auth.rootPassword=admin \
  --namespace packmind-beta

# (optional) forwards MongoDB port for local access
kubectl port-forward service/packmind-beta-mongodb 27017:27017 -n packmind-beta

# accesses Packmind with http://localhost:3001/
curl http://localhost:3001/

# cleans up
helm delete packmind-beta -n packmind-beta
kubectl delete ns packmind-beta
```

### Real scenario with cert-manager, Let's Encrypt & NGINX Ingress Controller

```bash
# retrieves public IP
NGINX_PUBLIC_IP=`kubectl get service -n ingress-nginx ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}'`

# applies the manifest (add "--debug > output.yaml" in case of issue)
helm upgrade --install packmind-beta . -f values.yaml --create-namespace \
  --set app.databaseUri.value=mongodb://root:admin@packmind-beta-mongodb:27017/packmind?authSource=admin \
  --set ingress.enabled=true,ingress.className=nginx,ingress.annotations.'cert-manager\.io/cluster-issuer'=letsencrypt-prod \
  --set ingress.tls.enabled=true,ingress.tls.secrets.app=packmind-tls \
  --set ingress.hostnames.app=packmind.${NGINX_PUBLIC_IP}.sslip.io \
  --set mongodb.enabled=true,mongodb.auth.rootPassword=admin \
  --namespace packmind-beta
```
