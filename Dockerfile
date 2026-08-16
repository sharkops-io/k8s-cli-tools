ARG HELM_VERSION=3.21.3
ARG RANCHER_CLI_VERSION=v2.15.0
# helmfile shells out to kustomize for strategicMergePatches/jsonPatches;
# without it the render fails with "kustomize: executable file not found in
# $PATH" -- and under `helmfile --quiet` that error is swallowed, leaving
# empty output that reads like the patch deleted everything.
#
# Installed from the release tarball rather than registry.k8s.io/kustomize,
# because that image is published amd64-only and would break an arm64 build.
ARG KUSTOMIZE_VERSION=5.8.1

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

ARG KUSTOMIZE_VERSION
ARG TARGETOS
ARG TARGETARCH
RUN curl -fsSL \
      "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz" \
      | tar -xz -C /usr/bin kustomize && \
    kustomize version

RUN /usr/bin/helm plugin install https://github.com/databus23/helm-diff

LABEL maintaner="dewdew@gmail.com Andrew Landsverk"
