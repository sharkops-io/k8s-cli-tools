ARG KUBECTL_VERSION=1.24.2
ARG HELM_VERSION=3.9.0
ARG RANCHER_CLI_VERSION=v2.6.5

FROM bitnami/kubectl:${KUBECTL_VERSION} as kubectl
FROM alpine/helm:${HELM_VERSION} as helm
FROM rancher/cli2:${RANCHER_CLI_VERSION} as rancher

FROM alpine

RUN apk add --update --no-cache curl ca-certificates bash git wget && \
    rm -f /var/cache/apk/*

COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl
COPY --from=helm /usr/bin/helm /usr/bin/helm
COPY --from=rancher /usr/bin/rancher /usr/bin/rancher

LABEL maintaner="dewdew@gmail.com Andrew Landsverk"
