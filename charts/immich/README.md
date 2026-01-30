# Immich Helm Chart

This Helm chart deploys Immich, a high performance self-hosted photo and video management solution.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- CloudNativePG operator (if using `database.mode: cluster`)
- DragonflyDB operator (if using `dragonfly.mode: cluster`)

## Installation

Install the chart:

```bash
# Install the chart
helm install immich ./immich
```

## Configuration

See `values.yaml` for configuration options.

### Architecture

This chart deploys the following components:

1. **Immich Server** - The main application server
2. **Machine Learning** - ML service for face recognition and smart search (optional)
3. **PostgreSQL** - Database with vectorchord extension (standalone using StatefulSet or CloudNativePG cluster)
4. **DragonflyDB** - High-performance Redis-compatible cache and job queue (standalone or cluster via DragonflyDB operator)

### Database Modes

#### PostgreSQL Options

The chart supports three PostgreSQL deployment modes:

1. **Standalone** (default): Deploys PostgreSQL using StatefulSet with vectorchord extension
2. **Cluster**: Uses CloudNativePG operator for high-availability PostgreSQL cluster (requires operator installed)
3. **External**: Connect to an existing PostgreSQL instance

```yaml
# Standalone mode (default) - uses StatefulSet
database:
  mode: standalone
  standalone:
    auth:
      database: immich
      username: immich
      password: "your-password"

# Cluster mode - uses CloudNativePG operator
database:
  mode: cluster
  cluster:
    instances: 2
    database: immich
    owner: immich
    storage:
      size: 20Gi

# External mode - connect to existing PostgreSQL
database:
  mode: external
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
3. **External**: Connect to an external Redis/DragonflyDB instance

**Note:** DragonflyDB/Redis is always enabled as it is required for Immich.

```yaml
# Standalone mode (default)
dragonfly:
  mode: standalone
  standalone:
    persistence:
      enabled: true
      size: 5Gi

# Cluster mode - uses DragonflyDB operator
dragonfly:
  mode: cluster
  cluster:
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

# Disabled - no Redis connection (not recommended)
dragonfly:
  enabled: false
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

### Velero Backup Schedule parameters

| Name | Description | Value |
|------|-------------|-------|
| `velero.enabled` | Enable Velero backup schedules | `false` |
| `velero.schedule` | Cron schedule for backups (e.g., "0 2 * * *") | `0 2 * * *` |
| `velero.ttl` | Time to live for backups (e.g., "720h" for 30 days) | `720h` |
| `velero.snapshotVolumes` | Whether to take volume snapshots | `true` |
| `velero.storageLocation` | Storage location for backups | `""` |

**Note**: When `velero.enabled=true`, a Velero Schedule is created to backup all Immich PVCs including library, database, and machine learning cache volumes.

### DragonflyDB parameters

| Name | Description | Value |
|------|-------------|-------|
| `dragonfly.mode` | Deployment mode: `standalone`, `cluster`, or `external` | `standalone` |
| `dragonfly.standalone.image.repository` | DragonflyDB image repository | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `dragonfly.standalone.image.tag` | DragonflyDB image tag | `v1.25.2` |
| `dragonfly.standalone.persistence.enabled` | Enable persistence | `true` |
| `dragonfly.standalone.persistence.size` | Persistence volume size | `5Gi` |
| `dragonfly.cluster.replicas` | Number of cluster replicas | `2` |
| `dragonfly.external.host` | External Redis/DragonflyDB host | `""` |
| `dragonfly.external.port` | External Redis/DragonflyDB port | `6379` |

### Database parameters

| Name | Description | Value |
|------|-------------|-------|
| `database.mode` | Deployment mode: `standalone`, `cluster`, or `external` | `standalone` |
| `database.standalone.image.repository` | PostgreSQL image with vectorchord | `tensorchord/vchord-postgres` |
| `database.standalone.image.tag` | PostgreSQL image tag | `pg16-v0.2.0` |
| `database.standalone.auth.database` | Database name | `immich` |
| `database.standalone.auth.username` | Database username | `immich` |
| `database.standalone.auth.password` | Database password | `""` (auto-generated) |
| `database.standalone.auth.postgresPassword` | Postgres superuser password | `""` (auto-generated) |
| `database.standalone.persistence.enabled` | Enable PostgreSQL persistence | `true` |
| `database.standalone.persistence.size` | PostgreSQL volume size | `10Gi` |
| `database.standalone.persistence.storageClass` | Storage class for PostgreSQL | `""` |
| `database.cluster.instances` | Number of PostgreSQL instances | `2` |
| `database.cluster.image.repository` | PostgreSQL image with vectorchord | `tensorchord/cloudnative-vectorchord` |
| `database.cluster.image.tag` | PostgreSQL image tag | `16.6-v0.2.0` |
| `database.cluster.storage.size` | Storage size per instance | `10Gi` |
| `database.external.host` | External PostgreSQL host | `""` |
| `database.external.port` | External PostgreSQL port | `5432` |
| `database.external.database` | External database name | `immich` |
| `database.external.username` | External database username | `immich` |

## Upgrading

### To 1.5.0

This version removes the Bitnami PostgreSQL subchart dependency and implements native standalone PostgreSQL deployment.

**Breaking Changes:**
- Removed Bitnami PostgreSQL subchart dependency
- Standalone mode now uses StatefulSet instead of Bitnami subchart
- Auth configuration moved from `postgresql.auth.*` to `database.standalone.auth.*`
- No more `postgresql.*` section in values.yaml
- `database.mode` structure standardized across charts

To migrate from version 1.4.x:
1. Backup your data
2. Update your values.yaml:
   ```yaml
   # Old (v1.4.0)
   postgresql:
     mode: standalone
     standalone:
       enabled: true
     auth:
       database: immich
       username: immich
       password: "your-password"
   
   # New (v1.5.0)
   database:
     mode: standalone
     standalone:
       auth:
         database: immich
         username: immich
         password: "your-password"
   ```
3. The migration is non-destructive if using external or cluster modes
4. For standalone mode, you may need to migrate data from the old PVC to the new one

### To 1.4.0
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
