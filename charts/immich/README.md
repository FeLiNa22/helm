# Immich Helm Chart

This Helm chart deploys Immich, a high performance self-hosted photo and video management solution.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- **CloudNative-PG Operator** must be installed in the cluster for database HA (install from https://cloudnative-pg.io)

## Installation

First, install the CloudNative-PG operator:

```bash
# Add the CloudNative-PG Helm repository
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update

# Install the operator
helm install cnpg cnpg/cloudnative-pg --create-namespace --namespace cnpg-system
```

Then install Immich:

```bash
# Install the chart
helm install immich ./charts/immich
```

## Configuration

See `values.yaml` for configuration options.

### Architecture

This chart deploys the following components:

1. **Immich Server** - The main application server
2. **Machine Learning** - ML service for face recognition and smart search (optional)
3. **CloudNative-PG PostgreSQL Cluster** - Highly available database with pgvector extension (3 instances by default)
4. **Valkey** - Highly available Redis-compatible cache and job queue (3 replicas by default)

### High Availability

This chart is designed for high availability with:

- **CloudNative-PG PostgreSQL**: Provides automatic failover, point-in-time recovery, and streaming replication. Default configuration runs 3 instances.
- **Valkey StatefulSet**: Runs multiple Valkey replicas for redundancy. Default configuration runs 3 replicas.

Both components support horizontal scaling and automatic failover when a node goes down.

### Using External Services

If you want to use external PostgreSQL or Redis/Valkey instances, you can disable the built-in services:

```yaml
# values.yaml
database:
  enabled: false

postgresql:
  external:
    host: "your-postgresql-host"
    port: 5432
    database: "immich"
    username: "immich"
    existingSecret: "your-postgresql-secret"
    secretKey: "password"

valkey:
  enabled: false

redis:
  external:
    host: "your-redis-host"
    port: 6379
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

### Valkey parameters

| Name | Description | Value |
|------|-------------|-------|
| `valkey.enabled` | Deploy Valkey for high availability | `true` |
| `valkey.replicas` | Number of Valkey replicas | `3` |
| `valkey.image.repository` | Valkey image repository | `valkey/valkey` |
| `valkey.image.tag` | Valkey image tag | `8.0` |
| `valkey.auth.enabled` | Enable Valkey authentication | `false` |
| `valkey.persistence.enabled` | Enable Valkey persistence | `true` |
| `valkey.persistence.size` | Valkey volume size | `1Gi` |
| `valkey.maxmemory` | Maximum memory for Valkey | `256mb` |

### Redis parameters (DEPRECATED)

| Name | Description | Value |
|------|-------------|-------|
| `redis.enabled` | Deploy Redis subchart (use valkey instead) | `false` |
| `redis.architecture` | Redis architecture | `standalone` |
| `redis.auth.enabled` | Enable Redis authentication | `false` |

### Database parameters

| Name | Description | Value |
|------|-------------|-------|
| `database.enabled` | Deploy CloudNative-PG PostgreSQL | `true` |
| `database.instances` | Number of PostgreSQL instances | `3` |
| `database.image.repository` | PostgreSQL image with pgvector | `ghcr.io/tensorchord/cloudnative-pgvecto.rs` |
| `database.image.tag` | PostgreSQL image tag | `16.6-v0.4.0` |
| `database.database` | Database name | `immich` |
| `database.owner` | Database owner | `immich` |
| `database.storage.size` | PostgreSQL volume size | `10Gi` |
| `database.monitoring.enablePodMonitor` | Enable Prometheus monitoring | `false` |

### PostgreSQL parameters (DEPRECATED)

| Name | Description | Value |
|------|-------------|-------|
| `postgresql.enabled` | Deploy PostgreSQL subchart (use database instead) | `false` |
| `postgresql.architecture` | PostgreSQL architecture | `standalone` |
| `postgresql.auth.database` | Database name | `immich` |
| `postgresql.auth.username` | Database username | `immich` |
| `postgresql.auth.password` | Database password | `""` (auto-generated) |
| `postgresql.image.repository` | PostgreSQL image with pgvector | `tensorchord/pgvecto-rs` |
| `postgresql.image.tag` | PostgreSQL image tag | `pg16-v0.4.0` |
| `postgresql.primary.persistence.enabled` | Enable PostgreSQL persistence | `true` |
| `postgresql.primary.persistence.size` | PostgreSQL volume size | `10Gi` |

## Upgrading

### To 1.3.0

This version introduces high availability support by switching from Bitnami subcharts to CloudNative-PG and Valkey:

- **Database**: Replaces Bitnami PostgreSQL subchart with CloudNative-PG cluster (3 instances by default)
- **Cache/Queue**: Replaces Bitnami Redis subchart with Valkey StatefulSet (3 replicas by default)
- **High Availability**: Both components now support automatic failover and horizontal scaling
- **Prerequisite**: CloudNative-PG operator must be installed before upgrading

**Breaking Changes:**
- Database and Redis configuration has changed significantly
- Chart dependencies removed (no longer uses Helm subcharts)
- Service names have changed:
  - PostgreSQL: `<release>-postgresql` → `<release>-immich-db-rw` (read-write) and `<release>-immich-db-r` (read-only)
  - Redis: `<release>-redis-master` → `<release>-immich-valkey`

To migrate from version 1.2.x:
1. Install CloudNative-PG operator (see Installation section above)
2. Backup your data using Immich's backup tools
3. Note your current PostgreSQL credentials
4. Uninstall the old release: `helm uninstall <release>`
5. Install the new version with appropriate configuration
6. Restore your data if necessary

For backwards compatibility, the old `postgresql` and `redis` configuration sections are still supported but deprecated. Set `database.enabled=false` and `postgresql.enabled=true` to use the old Bitnami PostgreSQL, or `valkey.enabled=false` and `redis.enabled=true` to use the old Bitnami Redis.

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
