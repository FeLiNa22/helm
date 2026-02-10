# Custom Helm Chart

This Helm chart deploys a generic Docker image with an optional PostgreSQL database. It's designed to be flexible and customizable for deploying various containerized applications.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- CloudNativePG operator (if using `database.mode: cluster`)

## Installation

Install the chart:

```bash
# Install the chart
helm install myapp ./custom

# Install with custom values
helm install myapp ./custom -f custom-values.yaml

# Install with specific image
helm install myapp ./custom --set image.repository=nginx --set image.tag=1.21
```

## Configuration

See `values.yaml` for all configuration options.

### Quick Start Examples

#### Deploy a simple application with persistent storage

```yaml
image:
  repository: myapp/myimage
  tag: "1.0.0"

service:
  port: 8080

persistence:
  data:
    enabled: true
    size: 5Gi
    mountPath: /app/data

database:
  enabled: false
```

#### Deploy with PostgreSQL database

```yaml
image:
  repository: myapp/myimage
  tag: "1.0.0"

database:
  enabled: true
  mode: standalone
  auth:
    username: myapp
    password: "mysecurepassword"
  persistence:
    size: 10Gi
```

## Architecture

This chart can deploy the following components:

1. **Application** - The main application container (configurable Docker image)
2. **PostgreSQL** - Optional database (standalone using StatefulSet or CloudNativePG cluster)
3. **Persistence** - Optional persistent volumes for application data
4. **Ingress** - Optional ingress for external access

### Database Modes

The chart supports PostgreSQL in three deployment modes, or can be disabled entirely:

#### 1. Database Disabled

By default, the database is enabled. To disable it:

```yaml
database:
  enabled: false
```

#### 2. Standalone Mode (default when enabled)

Deploys PostgreSQL using StatefulSet. This is the simplest option and suitable for development and single-instance deployments.

```yaml
database:
  enabled: true
  mode: standalone
  auth:
    username: myapp
    password: "your-password"  # Leave empty to auto-generate
  persistence:
    enabled: true
    size: 10Gi
```

#### 3. Cluster Mode

Uses CloudNativePG operator for high-availability PostgreSQL cluster. Requires the CloudNativePG operator to be installed in your cluster.

```yaml
database:
  enabled: true
  mode: cluster
  cluster:
    instances: 2
    name: myapp-db
  auth:
    username: myapp
  persistence:
    size: 20Gi
```

#### 4. External Mode

Connect to an existing external PostgreSQL instance:

```yaml
database:
  enabled: true
  mode: external
  external:
    host: "postgresql.example.com"
    port: 5432
    database: "myapp"
    username: "myapp"
  secret:
    name: "myapp-db-secret"  # Secret containing the password
    passwordKey: "password"
```

### Persistence Configuration

The chart supports persistent storage for the application:

```yaml
persistence:
  data:
    enabled: true
    storageClass: "fast-ssd"
    size: 10Gi
    mountPath: /data  # Where to mount in the container
    accessMode: ReadWriteOnce
```

You can also add additional volumes:

```yaml
persistence:
  additionalVolumes:
    - name: config
      configMap:
        name: my-config
  additionalMounts:
    - name: config
      mountPath: /etc/config
      readOnly: true
```

### Database Initialization

You can run SQL commands during database initialization:

```yaml
database:
  enabled: true
  initSQL:
    - "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    - "CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name VARCHAR(100));"
```

### Database Backups

Schedule automated backups using pg_dump:

```yaml
database:
  enabled: true
  backup:
    enabled: true
    cron: "0 2 * * *"  # Daily at 2am
    retention: 30  # Keep 30 backups
    persistence:
      enabled: true
      size: 10Gi
```

### Velero Backups

Enable Velero backup schedules for the application:

```yaml
velero:
  enabled: true
  namespace: "velero"
  schedule: "0 2 * * *"  # Daily at 2am
  ttl: "168h"  # 7 days retention
  snapshotVolumes: true

persistence:
  data:
    enabled: true  # Required for Velero backups
    size: 10Gi
```

**Note:** Velero backups require persistence to be enabled. The backup will include the data volume.

### Environment Variables

Environment variables are passed to the application container using a map format:

```yaml
env:
  TZ: "Europe/London"
  LOG_LEVEL: "info"
  APP_ENV: "production"
```

When the database is enabled, these environment variables are automatically set:
- `DB_HOST` - Database hostname
- `DB_PORT` - Database port
- `DB_DATABASE` - Database name
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password (from secret)

### Image Auto-update

The chart supports automatic image updates via ArgoCD Image Updater:

```yaml
image:
  repository: myapp/myimage
  tag: "1.0.0"
  autoupdate:
    enabled: true
    strategy: semver  # or 'latest', 'digest', etc.
    allowTags: "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$"  # Optional: filter tags
```

The auto-update feature will:
- Automatically detect and update to newer versions based on the strategy
- Support semver, digest, and other update strategies
- Allow filtering tags with regex patterns
- Support private registries with pull secrets

### Ingress

Enable ingress for external access:

```yaml
ingress:
  enabled: true
  className: nginx
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

### Resource Limits

Configure resource requests and limits:

```yaml
resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi
```

### Init Containers

Add init containers for setup tasks:

```yaml
initContainers:
  - name: wait-for-db
    image: busybox
    command: ['sh', '-c', 'until nc -z myapp-postgresql 5432; do sleep 1; done']
```

## Parameters

### Application Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Docker image repository | `nginx` |
| `image.tag` | Image tag (uses Chart.appVersion if not set) | `""` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.autoupdate.enabled` | Enable automatic image updates | `false` |
| `image.autoupdate.strategy` | Update strategy (semver, latest, digest, etc.) | `""` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |

### Database Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `database.enabled` | Enable PostgreSQL database | `false` |
| `database.mode` | Database mode: `standalone`, `cluster`, or `external` | `standalone` |
| `database.auth.username` | Database username | `custom` |
| `database.auth.password` | Database password (auto-generated if empty) | `""` |
| `database.persistence.enabled` | Enable database persistence | `true` |
| `database.persistence.size` | Database volume size | `1Gi` |

### Persistence Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.data.enabled` | Enable data persistence | `false` |
| `persistence.data.size` | Data volume size | `1Gi` |
| `persistence.data.mountPath` | Mount path for data | `/data` |
| `persistence.data.accessMode` | Access mode | `ReadWriteOnce` |

## Upgrading

### To upgrade the chart

```bash
helm upgrade myapp ./custom -f custom-values.yaml
```

### Important Notes

- Database passwords are auto-generated and stored in secrets if not provided
- Secrets persist across upgrades via Kubernetes secret lookup
- Always backup your data before upgrading
- Review the changelog for breaking changes

## Uninstalling

```bash
helm uninstall myapp
```

**Note:** This will delete the application but persistent volumes and their data may be retained depending on your cluster's reclaim policy.

## Examples

### Example 1: Simple Web Server

```yaml
image:
  repository: nginx
  tag: "1.21"

service:
  port: 80

ingress:
  enabled: true
  hosts:
    - host: web.example.com
      paths:
        - path: /
          pathType: Prefix

persistence:
  data:
    enabled: true
    size: 1Gi
    mountPath: /usr/share/nginx/html

database:
  enabled: false
```

### Example 2: Application with Database

```yaml
image:
  repository: myapp/backend
  tag: "2.0.0"

service:
  port: 8080

env:
  APP_ENV: production
  LOG_LEVEL: info

database:
  enabled: true
  mode: standalone
  auth:
    username: myapp
  persistence:
    size: 20Gi
  backup:
    enabled: true
    cron: "0 3 * * *"
    retention: 14

persistence:
  data:
    enabled: true
    size: 10Gi
    mountPath: /app/data
```

### Example 3: High Availability Setup

```yaml
image:
  repository: myapp/backend
  tag: "2.0.0"

replicaCount: 3

service:
  port: 8080

database:
  enabled: true
  mode: cluster
  cluster:
    instances: 3
    name: myapp-db
  persistence:
    size: 50Gi
  backup:
    enabled: true

persistence:
  data:
    enabled: true
    storageClass: fast-ssd
    size: 20Gi

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi
```

## Support

For issues and questions, please open an issue in the repository.

## License

This chart is provided as-is under the project's license.
