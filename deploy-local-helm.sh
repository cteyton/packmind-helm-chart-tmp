#!/bin/bash

BRANCH_NAME=packmind-prod
#helm repo update --kubeconfig=.kubeconfig
helm upgrade --install packmind -f charts/packmind/values.yaml \
        charts/packmind \
        --namespace packmind-prod --create-namespace --kubeconfig=.kubeconfig \
        --set app.databaseEmbedded.enabled=true \
        --set app.images.imagePullPolicy=Always \
        --set app.variables.PACKMIND_URL=https://$BRANCH_NAME.taild73f.ts.net \
        --set app.variables.SMTP_FROM=cedric.teyton@packmind.com \
        --set app.variables.TS_ACCEPT_DNS=true \
        --set app.detection.replicas=1 \
        --set app.aiagent.replicas=1 \
        --set-string ingress.hostnames.app=$BRANCH_NAME \
        --set ingress.className=tailscale \
        --set ingress.tls.enabled=true
