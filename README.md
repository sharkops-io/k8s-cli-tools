# k8s-cli-tools

A small Alpine image with pinned versions of the Kubernetes deploy tools, built for CI jobs that run `kubectl`, `helm` and `helmfile`.

Published for **linux/amd64 and linux/arm64** as one multi-arch tag, so `docker pull` on an Apple Silicon Mac or an arm64 runner gets a native image. Each architecture is built on a native runner and smoke-tested before the multi-arch tag exists; see `.github/workflows/ci.yml`.

## Installed CLI tools

- `kubectl`
- `helm` (with the `helm-diff` plugin)
- `helmfile`
- `kustomize`
- `rancher`
- `bash`
- `curl`
- `wget`
- `ca-certificates`
- `git`

## Using the Image

It is meant for CI pipelines. Versions are on [GHCR](https://github.com/sharkops-io/k8s-cli-tools/pkgs/container/k8s-cli-tools): each `X.Y.Z` release tag, `latest` for the newest release, and `master` for the newest build of the default branch.

### Locally, Using docker

```bash
docker pull ghcr.io/sharkops-io/k8s-cli-tools:latest
```

### In a GitHub Actions job

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container: ghcr.io/sharkops-io/k8s-cli-tools:latest
    steps:
      - run: kubectl version --client
```

### In a GitLab CI job

```yaml
deploy:
  image: ghcr.io/sharkops-io/k8s-cli-tools:latest
  script:
    - kubectl version --client
```
## Runner variant

`Dockerfile.runner` builds the GitHub Actions runner (`ghcr.io/actions/actions-runner`)
with this image's kubectl, helm, helm-diff, helmfile and kustomize copied in.
It is published as `ghcr.io/sharkops-io/k8s-cli-tools:<tag>-runner`
(and `:latest-runner` / `:master-runner`) for self-hosted ARC runner scale sets.

## License

Apache License 2.0. See [LICENSE](LICENSE).
