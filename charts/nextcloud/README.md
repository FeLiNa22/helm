# Nextcloud Helm Chart

This Helm chart deploys Nextcloud on Kubernetes.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- CloudNativePG operator (if using `database.mode: cluster`)
- DragonflyDB operator (if using `dragonfly.mode: cluster`)

## Installation

```bash
# Update dependencies (if using standalone PostgreSQL)
helm dependency update ./nextcloud

# Install the chart
helm install nextcloud ./nextcloud
```

## Configuration

See `values.yaml` for configuration options.

### Architecture

This chart deploys the following components:

1. **Nextcloud** - The main application server
2. **PostgreSQL** - Database (CloudNativePG cluster or standalone via Bitnami subchart)
3. **DragonflyDB** - Optional Redis-compatible cache (standalone or cluster via DragonflyDB operator)

### Database Modes

#### PostgreSQL Options

The chart supports three PostgreSQL deployment modes:

1. **Cluster** (default): Uses CloudNativePG operator for high-availability PostgreSQL cluster
2. **Standalone**: Uses Bitnami PostgreSQL subchart for simple deployments
3. **External**: Connect to an existing PostgreSQL instance

```yaml
# Cluster mode (default) - uses CloudNativePG operator
database:
  mode: cluster
  cluster:
    enabled: true
    instances: 2
    database: nextcloud
    owner: nextcloud
    storage:
      size: 20Gi
      storageClass: "your-storage-class"

# Standalone mode - uses Bitnami subchart
database:
  mode: standalone
  standalone:
    enabled: true
    auth:
      database: nextcloud
      username: nextcloud
      password: "your-password"
  cluster:
    enabled: false

# External mode - connect to existing PostgreSQL
database:
  mode: external
  external:
    host: "your-postgresql-host"
    port: 5432
    database: "nextcloud"
    username: "nextcloud"
    existingSecret: "your-postgresql-secret"
    secretKey: "password"
```

### DragonflyDB Options (Optional Caching)

The chart supports four DragonflyDB deployment modes for Redis-compatible caching:

1. **Disabled** (default): No cache deployed
2. **Standalone**: Simple single-instance DragonflyDB deployment
3. **Cluster**: Uses DragonflyDB operator for clustered deployment
4. **External**: Connect to an external Redis/DragonflyDB instance

```yaml
# Disabled mode (default) - no cache
dragonfly:
  mode: disabled

# Standalone mode
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
```

### Storage

Configure persistent storage for Nextcloud's data:

```yaml
persistence:
  enabled: true
  storageClass: "your-storage-class"
  size: 10Gi
```

### Ingress

Enable ingress to expose Nextcloud externally:

```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: nextcloud.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: nextcloud-tls
      hosts:
        - nextcloud.example.com
```

## Parameters

### Nextcloud parameters

| Name | Description | Value |
|------|-------------|-------|
| `enabled` | Enable Nextcloud deployment | `true` |
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Nextcloud image repository | `docker.io/library/nextcloud` |
| `image.tag` | Nextcloud image tag | `32.0.3` |
| `service.type` | Service type | `LoadBalancer` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `true` |
| `env` | Environment variables (map format) | See values.yaml |

### Database parameters

| Name | Description | Value |
|------|-------------|-------|
| `database.mode` | Deployment mode: `cluster`, `standalone`, or `external` | `cluster` |
| `database.cluster.enabled` | Deploy CloudNativePG cluster | `true` |
| `database.cluster.instances` | Number of PostgreSQL instances | `1` |
| `database.cluster.database` | Database name | `nextcloud` |
| `database.cluster.storage.size` | Storage size per instance | `10Gi` |
| `database.standalone.enabled` | Deploy Bitnami PostgreSQL | `false` |
| `database.standalone.auth.database` | Database name | `nextcloud` |
| `database.standalone.auth.username` | Database username | `nextcloud` |
| `database.external.host` | External PostgreSQL host | `""` |
| `database.external.port` | External PostgreSQL port | `5432` |
| `database.external.database` | External database name | `nextcloud` |
| `database.external.username` | External database username | `nextcloud` |

### DragonflyDB parameters

| Name | Description | Value |
|------|-------------|-------|
| `dragonfly.mode` | Deployment mode: `disabled`, `standalone`, `cluster`, or `external` | `disabled` |
| `dragonfly.standalone.enabled` | Deploy standalone DragonflyDB | `false` |
| `dragonfly.standalone.image.repository` | DragonflyDB image | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `dragonfly.standalone.image.tag` | DragonflyDB image tag | `v1.25.2` |
| `dragonfly.standalone.persistence.enabled` | Enable persistence | `true` |
| `dragonfly.standalone.persistence.size` | Persistence volume size | `5Gi` |
| `dragonfly.cluster.enabled` | Deploy DragonflyDB cluster | `false` |
| `dragonfly.cluster.replicas` | Number of cluster replicas | `2` |
| `dragonfly.external.host` | External Redis/DragonflyDB host | `""` |
| `dragonfly.external.port` | External Redis/DragonflyDB port | `6379` |

### Persistence parameters

| Name | Description | Value |
|------|-------------|-------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class | `ceph-rbd` |
| `persistence.size` | Volume size | `10Gi` |

## Upgrading

### To 1.2.0

This version adds support for:

- Optional DragonflyDB for Redis-compatible caching (standalone and cluster modes)
- Bitnami PostgreSQL subchart as an alternative to CloudNativePG
- Database mode selection via `database.mode`
- External PostgreSQL and Redis/DragonflyDB support

**Breaking Changes:**
- `database.enabled` has been replaced with `database.mode` and nested configuration
- Original database settings moved to `database.cluster.*`
- PostgreSQL subchart alias is `postgresql-standalone`

To migrate from version 1.1.x:
1. Backup your data
2. Update your values to use the new configuration structure
3. Install the new version
