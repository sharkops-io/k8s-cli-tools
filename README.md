# k8s-cli-tools

This image simply pulls specified versions of `helm` `kubectl` and `Rancher CLI` from their Docker images. This image is based on `alpine`

Published for **linux/amd64 and linux/arm64** as one multi-arch tag, so `docker pull` on an Apple Silicon Mac or an arm64 runner gets a native image. See `.gitlab-ci.yml` for how.

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

This image is mostly intended to be used in CI/CD Pipelines, such as GitLab CI/CD. You can find the latest version in the [GitLab Container Registry](https://gitlab.com/sharkops/docker-images/k8s-cli-tools/container_registry) or in the [Releases Section](https://gitlab.com/sharkops/docker-images/k8s-cli-tools/-/releases)

### Locally, Using docker

```bash
docker pull registry.gitlab.com/sharkops/docker-images/k8s-cli-tools:latest
```

### In a Stage on GitLab CI/CD

```yaml
build:
  stage: build
  image: registry.gitlab.com/sharkops/docker-images/k8s-cli-tools:latest
  script:
    - kubectl get nodes
```