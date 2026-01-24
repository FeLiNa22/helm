# Immich Helm Chart

This Helm chart deploys Immich, a high performance self-hosted photo and video management solution.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- CloudNativePG operator (if using `postgresql.mode: cluster`)
- DragonflyDB operator (if using `dragonfly.mode: cluster`)

## Installation

Add the chart dependencies and install:

```bash
# Update dependencies
helm dependency update ./immich

# Install the chart
helm install immich ./immich
```

## Configuration

See `values.yaml` for configuration options.

### Architecture

This chart deploys the following components:

1. **Immich Server** - The main application server
2. **Machine Learning** - ML service for face recognition and smart search (optional)
3. **PostgreSQL** - Database with pgvector/vectorchord extension (standalone via Bitnami subchart or CloudNativePG cluster)
4. **DragonflyDB** - High-performance Redis-compatible cache and job queue (standalone or cluster via DragonflyDB operator)

### Database Modes

#### PostgreSQL Options

The chart supports three PostgreSQL deployment modes:

1. **Standalone** (default): Uses Bitnami PostgreSQL subchart with pgvecto-rs extension
2. **Cluster**: Uses CloudNativePG operator for high-availability PostgreSQL cluster (requires operator installed)
3. **External**: Connect to an existing PostgreSQL instance

```yaml
# Standalone mode (default) - uses Bitnami subchart
postgresql:
  mode: standalone
  standalone:
    enabled: true
    auth:
      database: immich
      username: immich
      password: "your-password"

# Cluster mode - uses CloudNativePG operator
postgresql:
  mode: cluster
  standalone:
    enabled: false
  cluster:
    enabled: true
    instances: 2
    database: immich
    owner: immich
    storage:
      size: 20Gi

# External mode - connect to existing PostgreSQL
postgresql:
  mode: external
  standalone:
    enabled: false
  external:
    host: "your-postgresql-host"
    port: 5432
    database: "immich"
    username: "immich"
    existingSecret: "your-postgresql-secret"
    secretKey: "password"
```

#### DragonflyDB Options

The chart supports three DragonflyDB deployment modes:

1. **Standalone** (default): Simple single-instance DragonflyDB deployment
2. **Cluster**: Uses DragonflyDB operator for clustered deployment (requires operator installed)
3. **Disabled**: Connect to an external Redis/DragonflyDB instance

```yaml
# Standalone mode (default)
dragonfly:
  mode: standalone
  standalone:
    enabled: true
    persistence:
      enabled: true
      size: 5Gi

# Cluster mode - uses DragonflyDB operator
dragonfly:
  mode: cluster
  cluster:
    enabled: true
    replicas: 2
    persistence:
      enabled: true
      size: 5Gi

# Disabled mode - use external Redis/DragonflyDB
dragonfly:
  mode: disabled
  external:
    host: "your-redis-host"
    port: 6379
    existingSecret: "your-redis-secret"  # optional
    passwordKey: "password"
```

### Storage

Configure persistent storage for Immich's media library:

```yaml
persistence:
  library:
    enabled: true
    storageClass: "your-storage-class"  # Optional
    size: 100Gi
    existingClaim: ""  # Use existing PVC if desired
```

### Ingress

Enable ingress to expose Immich externally:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  hosts:
    - host: immich.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: immich-tls
      hosts:
        - immich.example.com
```

## Parameters

### Immich Server parameters

| Name | Description | Value |
|------|-------------|-------|
| `replicaCount` | Number of replicas for the server | `1` |
| `image.repository` | Server image repository | `ghcr.io/immich-app/immich-server` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Server image tag | `v2.4.1` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `2283` |
| `ingress.enabled` | Enable ingress | `false` |
| `resources` | Resource limits and requests | `{}` |
| `env` | Additional environment variables (map format) | `{ TZ: "Europe/London" }` |

### Machine Learning parameters

| Name | Description | Value |
|------|-------------|-------|
| `machineLearning.enabled` | Enable machine learning component | `true` |
| `machineLearning.replicaCount` | Number of ML replicas | `1` |
| `machineLearning.image.repository` | ML image repository | `ghcr.io/immich-app/immich-machine-learning` |
| `machineLearning.image.tag` | ML image tag | `v2.4.1` |
| `machineLearning.persistence.enabled` | Enable ML cache persistence | `true` |
| `machineLearning.persistence.size` | ML cache volume size | `10Gi` |

### Persistence parameters

| Name | Description | Value |
|------|-------------|-------|
| `persistence.library.enabled` | Enable library persistence | `true` |
| `persistence.library.storageClass` | Storage class | `""` |
| `persistence.library.existingClaim` | Use existing PVC | `""` |
| `persistence.library.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.library.size` | Volume size | `100Gi` |

### DragonflyDB parameters

| Name | Description | Value |
|------|-------------|-------|
| `dragonfly.mode` | Deployment mode: `standalone`, `cluster`, or `disabled` | `standalone` |
| `dragonfly.standalone.enabled` | Deploy standalone DragonflyDB | `true` |
| `dragonfly.standalone.image.repository` | DragonflyDB image repository | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `dragonfly.standalone.image.tag` | DragonflyDB image tag | `v1.25.2` |
| `dragonfly.standalone.persistence.enabled` | Enable persistence | `true` |
| `dragonfly.standalone.persistence.size` | Persistence volume size | `5Gi` |
| `dragonfly.cluster.enabled` | Deploy DragonflyDB cluster (requires operator) | `false` |
| `dragonfly.cluster.replicas` | Number of cluster replicas | `2` |
| `dragonfly.external.host` | External Redis/DragonflyDB host | `""` |
| `dragonfly.external.port` | External Redis/DragonflyDB port | `6379` |

### PostgreSQL parameters

| Name | Description | Value |
|------|-------------|-------|
| `postgresql.mode` | Deployment mode: `standalone`, `cluster`, or `external` | `standalone` |
| `postgresql.standalone.enabled` | Deploy standalone PostgreSQL (Bitnami) | `true` |
| `postgresql.standalone.auth.database` | Database name | `immich` |
| `postgresql.standalone.auth.username` | Database username | `immich` |
| `postgresql.standalone.auth.password` | Database password | `""` (auto-generated) |
| `postgresql.standalone.image.repository` | PostgreSQL image with pgvecto-rs | `tensorchord/pgvecto-rs` |
| `postgresql.standalone.image.tag` | PostgreSQL image tag | `pg16-v0.4.0` |
| `postgresql.standalone.primary.persistence.enabled` | Enable PostgreSQL persistence | `true` |
| `postgresql.standalone.primary.persistence.size` | PostgreSQL volume size | `10Gi` |
| `postgresql.cluster.enabled` | Deploy CloudNativePG cluster (requires operator) | `false` |
| `postgresql.cluster.instances` | Number of PostgreSQL instances | `2` |
| `postgresql.cluster.image.repository` | PostgreSQL image with vectorchord | `ghcr.io/tensorchord/cloudnative-pgvecto.rs` |
| `postgresql.cluster.image.tag` | PostgreSQL image tag | `16-v0.4.0` |
| `postgresql.cluster.storage.size` | Storage size per instance | `10Gi` |
| `postgresql.external.host` | External PostgreSQL host | `""` |
| `postgresql.external.port` | External PostgreSQL port | `5432` |
| `postgresql.external.database` | External database name | `immich` |
| `postgresql.external.username` | External database username | `immich` |

## Upgrading

### To 1.3.0

This version adds support for:

- CloudNativePG operator for PostgreSQL cluster deployments
- DragonflyDB for Redis-compatible caching (standalone and cluster modes)
- Removed Bitnami Redis subchart dependency

**Breaking Changes:**
- `redis.*` configuration has been replaced with `dragonfly.*`
- `postgresql.enabled` has been replaced with `postgresql.mode` and nested configuration
- Subchart alias changed from `postgresql` to `postgresqlStandalone`

To migrate from version 1.2.x:
1. Backup your data
2. Note your current PostgreSQL credentials
3. Update your values to use the new configuration structure
4. Install the new version

### To 2.0.0

This is a complete rewrite of the chart that:

- Replaces CloudNativePG with Bitnami PostgreSQL subchart
- Adds Bitnami Redis subchart (previously required external Redis)
- Adds Machine Learning deployment support
- Uses standard Helm chart patterns and helpers
- Fixes all naming consistency issues

**Breaking Changes:**
- Database configuration has changed significantly
- Redis is now deployed as part of the chart
- PVC naming has changed

To migrate from version 1.x:
1. Backup your data
2. Note your current PostgreSQL credentials
3. Uninstall the old release
4. Install the new version with appropriate configuration
5. Restore your data if necessary
