# Helm Charts for Kubernetes

This repository acts like a helm chart repository for various Kubernetes applications.

## TL;DR

```bash
helm repo add felina22 https://felina22.github.io/helms
helm search repo felina22
helm install example felina22/<chart>
helm uninstall example
```

## ArgoCD Image Updater Support

All charts now support ArgoCD Image Updater integration for automatic container image updates. This feature is **disabled by default** and can be enabled via `values.yaml`.

### Enabling Image Updater

To enable ArgoCD Image Updater for a chart, set `imageUpdater.enabled=true` in your values:

```yaml
imageUpdater:
  enabled: true
  updateStrategy: semver  # Options: semver, latest, name, digest
  allowTags: ""           # Optional: regex to allow specific tags
  ignoreTags: ""          # Optional: regex to ignore specific tags
```

### How It Works

When enabled, each chart creates a ConfigMap containing the ArgoCD Image Updater annotations for all container images used by that chart. These annotations need to be applied to your ArgoCD Application resource.

**Example for single-service charts** (outline, homepage, vaultwarden, etc.):
```yaml
annotations:
  argocd-image-updater.argoproj.io/image-list: outlinewiki/outline
  argocd-image-updater.argoproj.io/outlinewiki_outline.update-strategy: semver
```

**For the servarr umbrella chart**, it automatically tracks all enabled services and their sidecars:
```yaml
annotations:
  argocd-image-updater.argoproj.io/image-list: lscr.io/linuxserver/jellyfin, lscr.io/linuxserver/sonarr, ...
  argocd-image-updater.argoproj.io/lscr_io_linuxserver_jellyfin.update-strategy: semver
  argocd-image-updater.argoproj.io/lscr_io_linuxserver_sonarr.update-strategy: semver
```

### Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `imageUpdater.enabled` | Enable ArgoCD Image Updater integration | `false` |
| `imageUpdater.updateStrategy` | Update strategy (semver, latest, name, digest) | `semver` |
| `imageUpdater.allowTags` | Regex to allow specific image tags | `""` |
| `imageUpdater.ignoreTags` | Regex to ignore specific image tags | `""` |
| `imageUpdater.pullSecret` | Secret for private registries (single-service charts only) | `""` |
| `imageUpdater.extraAnnotations` | Additional custom annotations | `{}` |

### Prerequisites

- ArgoCD Image Updater must be installed in your cluster
- Your application must be deployed via ArgoCD Application CRD

For more information, see the [ArgoCD Image Updater documentation](https://argocd-image-updater.readthedocs.io/).
