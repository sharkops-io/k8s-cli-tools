ARG HELM_VERSION=3.19.0
ARG RANCHER_CLI_VERSION=v2.14.0

FROM bitnami/kubectl:latest AS kubectl
FROM ghcr.io/helmfile/helmfile:latest AS helmfile
FROM alpine/helm:${HELM_VERSION} AS helm
FROM rancher/cli2:${RANCHER_CLI_VERSION} AS rancher

FROM alpine

RUN apk add --update --no-cache curl ca-certificates bash git wget && \
    rm -f /var/cache/apk/*

COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl
COPY --from=helm /usr/bin/helm /usr/bin/helm
COPY --from=helmfile /usr/local/bin/helmfile /usr/bin/helmfile
COPY --from=rancher /usr/bin/rancher /usr/bin/rancher

RUN /usr/bin/helm plugin install https://github.com/databus23/helm-diff

LABEL maintaner="dewdew@gmail.com Andrew Landsverk"
