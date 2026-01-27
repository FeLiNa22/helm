# Helm Charts for Kubernetes

A comprehensive collection of production-ready Helm charts for deploying popular self-hosted applications on Kubernetes. This repository provides ready-to-use charts for media management, productivity tools, home automation, AI services, and more.

## Quick Start

Add the Helm repository and start deploying:

```bash
# Add the repository
helm repo add felina22 https://felina22.github.io/helms

# Search available charts
helm search repo felina22

# Install a chart (example: Homepage dashboard)
helm install my-homepage felina22/homepage

# View installed releases
helm list

# Uninstall a release
helm uninstall my-homepage
```

## 📚 Available Charts

### 🎬 Media Management & Streaming

| Chart | Description | Key Features |
|-------|-------------|--------------|
| **[servarr](charts/servarr)** | Complete media automation stack | Sonarr, Radarr, Lidarr, Prowlarr, Jellyfin, qBittorrent, and more in one chart |
| **[frigate](charts/frigate)** | NVR with real-time AI object detection | Security camera management with hardware acceleration support |
| **[immich](charts/immich)** | High-performance photo and video management | Self-hosted Google Photos alternative with ML features |

### 💼 Productivity & Collaboration

| Chart | Description | Key Features |
|-------|-------------|--------------|
| **[nextcloud](charts/nextcloud)** | File sync and collaboration platform | Self-hosted cloud storage with office suite integration |
| **[outline](charts/outline)** | Modern team knowledge base | Real-time collaborative wiki with Markdown support |
| **[vaultwarden](charts/vaultwarden)** | Password manager | Bitwarden-compatible password vault |
| **[mealie](charts/mealie)** | Recipe manager and meal planner | Organize recipes, plan meals, generate shopping lists |
| **[penpot](charts/penpot)** | Open-source design platform | Collaborative design tool alternative to Figma |
| **[excalidraw](charts/excalidraw)** | Virtual whiteboard for sketching | Hand-drawn style diagrams and wireframes |

### 🏠 Home Automation & Utilities

| Chart | Description | Key Features |
|-------|-------------|--------------|
| **[home-assistant](charts/home-assistant)** | Home automation hub | Control and automate smart home devices |
| **[homepage](charts/homepage)** | Application dashboard | Auto-discovers and displays all services with Kubernetes integration |
| **[ntfy](charts/ntfy)** | Simple notification service | HTTP-based pub-sub notifications for scripts and apps |

### 🔧 Infrastructure & Networking

| Chart | Description | Key Features |
|-------|-------------|--------------|
| **[cloudflare-tunnel](charts/cloudflare-tunnel)** | Secure tunnel to Cloudflare | Expose services without public IPs or port forwarding |
| **[cloudflare-dynamic-ip-updater](charts/cloudflare-dynamic-ip-updater)** | Dynamic DNS updater | Keep Cloudflare DNS records updated with changing IP |
| **[searxng](charts/searxng)** | Privacy-respecting metasearch engine | Aggregate search results without tracking |

### 🤖 AI & Development

| Chart | Description | Key Features |
|-------|-------------|--------------|
| **[crewai](charts/crewai)** | AI agent workflow platform | Deploy and orchestrate AI agents on Kubernetes |

## 🏗️ Chart Structure

All charts in this repository follow a consistent structure:

```
chart-name/
├── Chart.yaml              # Chart metadata (name, version, description)
├── values.yaml             # Default configuration values
├── README.md              # Chart-specific documentation
└── templates/
    ├── deployment.yaml     # Main application deployment
    ├── service.yaml        # Kubernetes service
    ├── ingress.yaml        # Ingress configuration (optional)
    ├── pvc.yaml           # Persistent volume claims
    ├── configmap.yaml     # Configuration files
    ├── secret.yaml        # Sensitive data (if needed)
    ├── serviceaccount.yaml # Service account for RBAC
    └── imageupdater.yaml  # ArgoCD Image Updater CRD (optional)
```

### Common Components

Most charts include:

- **Deployment/StatefulSet**: Runs the application workload
- **Service**: Exposes the application within the cluster
- **PersistentVolumeClaim**: Stores application data
- **ConfigMap**: Application configuration files
- **Ingress**: External HTTP/HTTPS access (optional)
- **ServiceAccount + RBAC**: Kubernetes permissions (when needed)

## ⚙️ Common Configuration Patterns

### Environment Variables

All charts use a **map format** for environment variables:

```yaml
env:
  TZ: "America/New_York"
  LOG_LEVEL: "info"
  MY_CUSTOM_VAR: "value"
```

### Persistence

Enable and configure persistent storage:

```yaml
persistence:
  enabled: true
  storageClass: ""        # Use default storage class
  size: 10Gi
  accessMode: ReadWriteOnce
  existingClaim: ""       # Use an existing PVC
```

Many charts also support backup volumes:

```yaml
persistence:
  backup:
    enabled: true
    storageClass: "cephfs"
    size: 50Gi
    accessMode: ReadWriteMany
```

### Ingress Configuration

Expose services via HTTP/HTTPS:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com
```

### Service Types

Choose how to expose your service:

```yaml
service:
  type: ClusterIP      # Internal only (default for most apps)
  # type: LoadBalancer # External IP (cloud providers)
  # type: NodePort     # Access via node IP:port
  port: 8080
```

### Resource Limits

Set CPU and memory limits:

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 2Gi
  requests:
    cpu: 100m
    memory: 512Mi
```

### Node Scheduling

Control where pods are scheduled:

```yaml
nodeSelector:
  kubernetes.io/hostname: my-node

tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: node-type
              operator: In
              values:
                - compute
```

## 📋 Prerequisites

### Basic Requirements (All Charts)

- **Kubernetes**: 1.19+ (most charts), 1.20+ (database-dependent charts)
- **Helm**: 3.0+
- **Storage**: PersistentVolume provisioner (if persistence is enabled)

### Optional Operators (Specific Charts)

Some charts require additional operators for advanced features:

#### CloudNativePG Operator

Required for high-availability PostgreSQL clusters in:
- `nextcloud` (when `database.mode: cluster`)
- `immich` (when `database.mode: cluster`)
- `frigate` (when `database.mode: cluster`)
- `servarr` services (when `database.mode: cluster`)

**Installation**:
```bash
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.20/releases/cnpg-1.20.0.yaml
```

See [CloudNativePG documentation](https://cloudnative-pg.io/) for details.

#### DragonflyDB Operator

Optional for Redis-compatible caching in:
- `nextcloud` (when `dragonfly.mode: cluster`)
- `immich` (when `dragonfly.mode: cluster`)

**Installation**: See [DragonflyDB Operator documentation](https://www.dragonflydb.io/docs/managing-dragonfly/operator/installation) for installation instructions.

Note: Most charts also support standalone DragonflyDB mode which doesn't require the operator.

#### ArgoCD Image Updater

Optional for automatic image updates (see [ArgoCD Image Updater](#argocd-image-updater-support-v1x) section below).

### Application-Specific Requirements

- **cloudflare-tunnel**: Cloudflare Tunnel token (for managed tunnels) or tunnel ID, account tag, tunnel name, and tunnel secret (for local tunnels)
- **cloudflare-dynamic-ip-updater**: Cloudflare API token (authKey), zone ID, DNS record name, and record ID
- **crewai**: API key from LLM provider (OpenAI, Anthropic, or Azure OpenAI)

## 🚀 Installation Examples

### Simple Installation

Install with default values:

```bash
helm install my-release felina22/<chart-name>
```

### Custom Values File

Create a `values.yaml` file with your customizations:

```yaml
# my-values.yaml
image:
  tag: "latest"

env:
  TZ: "America/New_York"

persistence:
  enabled: true
  size: 20Gi

ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
```

Install using your values:

```bash
helm install my-release felina22/<chart-name> -f my-values.yaml
```

### Inline Value Overrides

Override specific values directly:

```bash
helm install my-release felina22/<chart-name> \
  --set image.tag=v1.2.3 \
  --set persistence.size=50Gi \
  --set ingress.enabled=true
```

### Namespace Installation

Install in a specific namespace:

```bash
# Create namespace
kubectl create namespace media

# Install chart
helm install my-release felina22/<chart-name> \
  --namespace media \
  -f my-values.yaml
```

### Upgrade Existing Release

Update a running deployment:

```bash
# Upgrade with new values
helm upgrade my-release felina22/<chart-name> -f my-values.yaml

# Upgrade to latest chart version
helm repo update
helm upgrade my-release felina22/<chart-name>
```

## 📖 Chart-Specific Documentation

Each chart has detailed documentation in its subdirectory:

- **Configuration**: See `charts/<chart-name>/values.yaml` for all available parameters
- **Examples**: Check `charts/<chart-name>/README.md` for usage examples
- **Prerequisites**: Review chart-specific requirements before installation

### Example: Installing the Servarr Media Stack

```bash
# Create values file for your media stack
cat > servarr-values.yaml <<EOF
media:
  enabled: true
  size: 500Gi        # Shared media storage
  storageClass: "nfs"

jellyfin:
  enabled: true
  service:
    type: LoadBalancer

sonarr:
  enabled: true

radarr:
  enabled: true

prowlarr:
  enabled: true

qbittorrent:
  enabled: true
  persistence:
    size: 100Gi
EOF

# Install
helm install servarr felina22/servarr -f servarr-values.yaml
```

### Example: Installing Homepage Dashboard

```bash
# Homepage automatically discovers services in your cluster
helm install homepage felina22/homepage \
  --set config.enableKubernetes=true \
  --set rbac.create=true \
  --set service.type=LoadBalancer
```

### Example: Installing Nextcloud with PostgreSQL Cluster

```bash
# Ensure CloudNativePG operator is installed first

cat > nextcloud-values.yaml <<EOF
database:
  mode: cluster
  cluster:
    enabled: true
    instances: 3
    storage:
      size: 50Gi

persistence:
  enabled: true
  size: 100Gi

ingress:
  enabled: true
  hosts:
    - host: cloud.example.com
      paths:
        - path: /
          pathType: Prefix
EOF

helm install nextcloud felina22/nextcloud -f nextcloud-values.yaml
```

## 🔄 ArgoCD Image Updater Support (v1.x)

All charts support ArgoCD Image Updater v1.x integration for automatic container image updates. This feature is **disabled by default** and can be enabled via `values.yaml`.

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

## 🛠️ Development & Contributing

### Testing Charts Locally

```bash
# Lint a chart
helm lint charts/<chart-name>

# Template and review the output
helm template my-release charts/<chart-name> -f custom-values.yaml

# Dry-run installation
helm install my-release charts/<chart-name> --dry-run --debug

# Install locally
helm install my-release charts/<chart-name> -f custom-values.yaml
```

### Chart Versioning

When making changes to charts:
- **Patch version** (0.0.X): Bug fixes, minor tweaks
- **Minor version** (0.X.0): New features, backward-compatible changes
- **Major version** (X.0.0): Breaking changes

Always update the `version` field in `Chart.yaml` when modifying a chart.

## 📝 Additional Resources

- **[TESTING.md](TESTING.md)**: Detailed testing procedures
- **Individual Chart READMEs**: See `charts/<chart-name>/README.md` for specific chart documentation
- **values.yaml files**: Complete parameter references in each chart directory

## 🤝 Support & Community

For issues, questions, or contributions:
- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions for questions
- **Pull Requests**: Contributions are welcome!

## 📄 License

These Helm charts are open-source. Individual applications deployed by these charts are licensed by their respective authors. Please review the license for each application before use.

## ⭐ Popular Use Cases

### Home Lab Setup

Deploy a complete home media and productivity stack:

```bash
# Media management
helm install servarr felina22/servarr -f servarr-values.yaml

# Dashboard
helm install homepage felina22/homepage

# Password manager
helm install vaultwarden felina22/vaultwarden

# Cloud storage
helm install nextcloud felina22/nextcloud

# Photo management
helm install immich felina22/immich
```

### Secure Remote Access

Use Cloudflare Tunnel to expose services securely:

```bash
# Install Cloudflare Tunnel
helm install cf-tunnel felina22/cloudflare-tunnel \
  --set managed.enabled=true \
  --set managed.token="your-tunnel-token"

# Keep DNS updated with dynamic IP
helm install ddns felina22/cloudflare-dynamic-ip-updater \
  --set secret.authKey="your-api-token" \
  --set secret.zoneId="your-zone-id" \
  --set secret.dnsRecord="home.example.com" \
  --set secret.recordId="your-record-id"
```

### AI-Powered Workflows

Deploy AI agent workflows:

```bash
helm install crewai felina22/crewai \
  --set crewai.openaiApiKey.value="your-api-key" \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host="ai.example.com"
```

---

**Happy Helm charting! 🚀**
