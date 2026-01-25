# Immich Helm Chart

This Helm chart deploys Immich, a high performance self-hosted photo and video management solution.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- CloudNativePG operator (if using `database.mode: cluster`)
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
database:
  mode: standalone
  standalone:
    enabled: true

postgresql:
  auth:
    database: immich
    username: immich
    password: "your-password"

# Cluster mode - uses CloudNativePG operator
database:
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
database:
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

The chart supports four DragonflyDB deployment modes:

1. **Standalone** (default): Simple single-instance DragonflyDB deployment
2. **Cluster**: Uses DragonflyDB operator for clustered deployment (requires operator installed)
3. **External**: Connect to an external Redis/DragonflyDB instance
4. **Disabled**: No Redis/DragonflyDB connection (not recommended for Immich)

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

# External mode - use external Redis/DragonflyDB
dragonfly:
  mode: external
  external:
    host: "your-redis-host"
    port: 6379
    existingSecret: "your-redis-secret"  # optional
    passwordKey: "password"

# Disabled mode - no Redis connection
dragonfly:
  mode: disabled
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
| `dragonfly.mode` | Deployment mode: `standalone`, `cluster`, `external`, or `disabled` | `standalone` |
| `dragonfly.standalone.enabled` | Deploy standalone DragonflyDB | `true` |
| `dragonfly.standalone.image.repository` | DragonflyDB image repository | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `dragonfly.standalone.image.tag` | DragonflyDB image tag | `v1.25.2` |
| `dragonfly.standalone.persistence.enabled` | Enable persistence | `true` |
| `dragonfly.standalone.persistence.size` | Persistence volume size | `5Gi` |
| `dragonfly.cluster.enabled` | Deploy DragonflyDB cluster (requires operator) | `false` |
| `dragonfly.cluster.replicas` | Number of cluster replicas | `2` |
| `dragonfly.external.host` | External Redis/DragonflyDB host | `""` |
| `dragonfly.external.port` | External Redis/DragonflyDB port | `6379` |

### Database parameters

| Name | Description | Value |
|------|-------------|-------|
| `database.mode` | Deployment mode: `standalone`, `cluster`, or `external` | `standalone` |
| `database.standalone.enabled` | Deploy standalone PostgreSQL (Bitnami) | `true` |
| `database.cluster.enabled` | Deploy CloudNativePG cluster (requires operator) | `false` |
| `database.cluster.instances` | Number of PostgreSQL instances | `2` |
| `database.cluster.image.repository` | PostgreSQL image with vectorchord | `ghcr.io/tensorchord/cloudnative-pgvecto.rs` |
| `database.cluster.image.tag` | PostgreSQL image tag | `16-v0.4.0` |
| `database.cluster.storage.size` | Storage size per instance | `10Gi` |
| `database.external.host` | External PostgreSQL host | `""` |
| `database.external.port` | External PostgreSQL port | `5432` |
| `database.external.database` | External database name | `immich` |
| `database.external.username` | External database username | `immich` |

### PostgreSQL Subchart parameters (Bitnami)

| Name | Description | Value |
|------|-------------|-------|
| `postgresql.auth.database` | Database name (for Bitnami subchart) | `immich` |
| `postgresql.auth.username` | Database username (for Bitnami subchart) | `immich` |
| `postgresql.auth.password` | Database password (for Bitnami subchart) | `""` (auto-generated) |
| `postgresql.image.repository` | PostgreSQL image with pgvecto-rs | `tensorchord/pgvecto-rs` |
| `postgresql.image.tag` | PostgreSQL image tag | `pg16-v0.4.0` |
| `postgresql.primary.persistence.enabled` | Enable PostgreSQL persistence | `true` |
| `postgresql.primary.persistence.size` | PostgreSQL volume size | `10Gi` |

## Upgrading

### To 1.5.0

This version standardizes the database configuration structure to match other charts in this repository.

**Breaking Changes:**
- `postgresql.*` database mode and configuration has been moved to `database.*`
- Bitnami PostgreSQL subchart configuration remains under `postgresql.*` (separate from database mode config)
- `postgresql.mode` → `database.mode`
- `postgresql.standalone.enabled` → `database.standalone.enabled`
- `postgresql.cluster.*` → `database.cluster.*`
- `postgresql.external.*` → `database.external.*`

To migrate from version 1.4.x:
1. Update your values.yaml to use the new structure:
   ```yaml
   # Old (1.4.x)
   postgresql:
     mode: standalone
     standalone:
       enabled: true
     auth:
       database: immich
   
   # New (1.5.0)
   database:
     mode: standalone
     standalone:
       enabled: true
   postgresql:
     auth:
       database: immich
   ```
2. The migration is non-destructive; existing deployments will continue to work once values are updated

### To 1.4.0

This version adds support for:

- CloudNativePG operator for PostgreSQL cluster deployments
- DragonflyDB for Redis-compatible caching (standalone and cluster modes)
- Removed Bitnami Redis subchart dependency

**Breaking Changes:**
- `redis.*` configuration has been replaced with `dragonfly.*`
- `postgresql.enabled` has been replaced with `postgresql.mode` and nested configuration
- Subchart alias changed from `postgresql` to `postgresql-standalone`

To migrate from version 1.3.x:
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
