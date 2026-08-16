ARG HELM_VERSION=3.21.3
ARG RANCHER_CLI_VERSION=v2.15.0
# helmfile shells out to kustomize for strategicMergePatches/jsonPatches;
# without it those silently fail the render with "kustomize: executable file
# not found in $PATH".
ARG KUSTOMIZE_VERSION=v5.8.1

FROM bitnami/kubectl:latest AS kubectl
FROM ghcr.io/helmfile/helmfile:latest AS helmfile
FROM alpine/helm:${HELM_VERSION} AS helm
FROM rancher/cli2:${RANCHER_CLI_VERSION} AS rancher
FROM registry.k8s.io/kustomize/kustomize:${KUSTOMIZE_VERSION} AS kustomize

FROM alpine

RUN apk add --update --no-cache curl ca-certificates bash git wget && \
    rm -f /var/cache/apk/*

COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl
COPY --from=helm /usr/bin/helm /usr/bin/helm
COPY --from=helmfile /usr/local/bin/helmfile /usr/bin/helmfile
COPY --from=rancher /usr/bin/rancher /usr/bin/rancher
COPY --from=kustomize /app/kustomize /usr/bin/kustomize

RUN /usr/bin/helm plugin install https://github.com/databus23/helm-diff

LABEL maintaner="dewdew@gmail.com Andrew Landsverk"
