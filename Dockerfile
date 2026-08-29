ARG HELM_VERSION=4.2.4
ARG RANCHER_CLI_VERSION=v2.15.1
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
# *** DERIVE THE ARCH, DO NOT USE TARGETOS/TARGETARCH HERE. ***
#
# Those are BUILDKIT automatic build args. This repo builds with KANIKO
# (sharkops/gitlab-ci-common-config docker/build.yml), which does not set them
# and is not passed them with --build-arg -- so both expanded EMPTY, the URL
# became ".../kustomize_v5.8.1__.tar.gz", and GitHub returned 404. That broke
# every build of this image from 2026-08-16, when kustomize moved to the release
# tarball, until 2026-08-29. The failure is easy to misread: three Renovate MRs
# sat "failed" and looked like bad bumps, when nothing was wrong with any of
# them and main could not build either.
#
# `uname -m` is correct under any builder and keeps the arm64 intent that moving
# off the amd64-only container image was for in the first place.
RUN set -eu; \
    case "$(uname -m)" in \
      x86_64)  ARCH=amd64 ;; \
      aarch64) ARCH=arm64 ;; \
      *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;; \
    esac; \
    curl -fsSL \
      "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz" \
      | tar -xz -C /usr/bin kustomize && \
    kustomize version

# *** `--verify=false` IS REQUIRED BY HELM 4, AND IT IS A REAL TRADE-OFF. ***
#
# Helm 4 verifies plugin provenance by default. helm-diff does not publish
# provenance artefacts, so the plain install fails outright:
#
#   Error: plugin source does not support verification.
#   Use --verify=false to skip verification
#
# That is not cosmetic -- it breaks the BUILD, so this image (which deploys the
# whole cluster via `helmfile apply`) cannot be produced at all on Helm 4 without
# this flag. helm-diff's own README documents the same workaround.
#
# What the flag costs: Helm 4 added plugin verification deliberately, and this
# turns it off for this plugin. We are choosing to install an unverified plugin
# from GitHub at build time -- which is exactly what Helm 3 always did, so this
# is not a REGRESSION against today, but it does decline a new protection rather
# than adopt it. Revisit when helm-diff ships provenance; then drop the flag.
#
# Under Helm 4 the plugin loads through the legacy subprocess handler and
# reports as `cli/v1 legacy`. That path is supported, not deprecated-and-broken.
RUN /usr/bin/helm plugin install --verify=false https://github.com/databus23/helm-diff

LABEL maintaner="dewdew@gmail.com Andrew Landsverk"
