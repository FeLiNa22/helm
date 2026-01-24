# Helm Charts for Kubernetes

This repository acts like a helm chart repository for various Kubernetes applications.

## TL;DR

```bash
helm repo add felina22 https://felina22.github.io/helms
helm search repo felina22
helm install example felina22/<chart>
helm uninstall example
```

## ArgoCD Image Updater Support (v1.x)

All charts now support ArgoCD Image Updater v1.x integration using the `ImageUpdater` CRD for automatic container image updates. This feature is **disabled by default** and can be enabled via `values.yaml`.

### Enabling Image Updater

To enable ArgoCD Image Updater for a chart, set `imageUpdater.enabled=true` in your values:

```yaml
imageUpdater:
  enabled: true
  namespace: argocd                    # Namespace for ImageUpdater CRD
  argocdNamespace: argocd              # Namespace where ArgoCD Applications are
  applicationName: "my-app"            # ArgoCD Application name (defaults to Release name)
  imageAlias: "myalias"                # Image alias (defaults to Release name)
  updateStrategy: semver               # semver, latest, newest-build, digest, name, alphabetical
  forceUpdate: false                   # Force update even if not deployed
  allowTags: ""                        # e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$"
  ignoreTags: []                       # List of glob patterns
  pullSecret: ""                       # e.g., "secret:namespace/name#field"
  platforms: []                        # e.g., ["linux/amd64", "linux/arm64"]
  helm: {}                             # Helm parameter mapping
  kustomize: {}                        # Kustomize configuration
  writeBackConfig: {}                  # Git write-back config
```

### How It Works

When enabled, each chart creates an `ImageUpdater` custom resource that ArgoCD Image Updater monitors. The CRD defines:

- Which ArgoCD Application to monitor (`applicationName`)
- Which images to track (`images` list with `alias` and `imageName`)
- Update strategy and constraints (`commonUpdateSettings`)

**Example for single-service charts** (outline, homepage, vaultwarden, etc.):

```yaml
apiVersion: argocd-image-updater.argoproj.io/v1alpha1
kind: ImageUpdater
metadata:
  name: my-app
  namespace: argocd
spec:
  namespace: argocd
  applicationRefs:
    - namePattern: "my-app"
      images:
        - alias: "myapp"
          imageName: "outlinewiki/outline:0.87.4"
          commonUpdateSettings:
            updateStrategy: semver
```

**For the servarr umbrella chart**, it automatically tracks all enabled services and their sidecars:

```yaml
apiVersion: argocd-image-updater.argoproj.io/v1alpha1
kind: ImageUpdater
metadata:
  name: servarr
  namespace: argocd
spec:
  namespace: argocd
  applicationRefs:
    - namePattern: "servarr"
      images:
        - alias: "jellyfin"
          imageName: "lscr.io/linuxserver/jellyfin:10.11.5"
          commonUpdateSettings:
            updateStrategy: semver
        - alias: "sonarr"
          imageName: "lscr.io/linuxserver/sonarr:4.0.16"
          commonUpdateSettings:
            updateStrategy: semver
        # ... more services
```

### Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `imageUpdater.enabled` | Enable ArgoCD Image Updater integration | `false` |
| `imageUpdater.namespace` | Namespace for ImageUpdater CRD | `argocd` |
| `imageUpdater.argocdNamespace` | Namespace where ArgoCD Applications are | `argocd` |
| `imageUpdater.applicationName` | ArgoCD Application name/pattern | Release name |
| `imageUpdater.imageAlias` | Image alias in CRD | Release name |
| `imageUpdater.updateStrategy` | Update strategy (semver, latest, newest-build, digest, name, alphabetical) | `semver` |
| `imageUpdater.forceUpdate` | Force update even if not deployed | `false` |
| `imageUpdater.allowTags` | Match function for allowed tags | `""` |
| `imageUpdater.ignoreTags` | List of glob patterns to ignore | `[]` |
| `imageUpdater.pullSecret` | Secret reference for private registries | `""` |
| `imageUpdater.platforms` | Target platforms list | `[]` |
| `imageUpdater.helm` | Helm parameter mapping | `{}` |
| `imageUpdater.kustomize` | Kustomize configuration | `{}` |
| `imageUpdater.writeBackConfig` | Git write-back configuration | `{}` |

### Advanced Configuration Examples

**Helm parameter mapping** (for images with custom parameter names):
```yaml
imageUpdater:
  enabled: true
  helm:
    name: "dex.image.name"
    tag: "dex.image.tag"
```

**Version constraints** (follow semver patch versions):
```yaml
imageUpdater:
  enabled: true
  # In imageName field, use constraint syntax: nginx:~1.26
  # This is set in the template automatically from image.tag
```

**Filter tags with regex**:
```yaml
imageUpdater:
  enabled: true
  allowTags: "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$"  # Only semver tags
  ignoreTags:
    - "*-beta"
    - "*-alpha"
```

**Private registry authentication**:
```yaml
imageUpdater:
  enabled: true
  pullSecret: "secret:argocd/registry-creds#token"
  # Or: "pullsecret:argocd/docker-config"
  # Or: "env:REGISTRY_TOKEN"
```

### Prerequisites

- ArgoCD Image Updater **v1.x** or later must be installed in your cluster
- Your application must be deployed via ArgoCD Application CRD

For more information, see the [ArgoCD Image Updater v1.x documentation](https://argocd-image-updater.readthedocs.io/en/stable/).

### Migration from v0.x

If you were using the old annotation-based approach (v0.x), the new CRD-based approach is incompatible. Charts now create `ImageUpdater` CRDs instead of ConfigMaps with annotations. Please upgrade your ArgoCD Image Updater installation to v1.x before enabling this feature.
