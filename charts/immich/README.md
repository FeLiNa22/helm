# Immich Helm Chart

This Helm chart deploys Immich, a high performance self-hosted photo and video management solution.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)

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
3. **PostgreSQL** - Database with pgvector extension (via Bitnami subchart)
4. **Redis** - Cache and job queue (via Bitnami subchart)

### Using External Services

If you want to use external PostgreSQL or Redis instances, you can disable the subcharts:

```yaml
# values.yaml
postgresql:
  enabled: false
  external:
    host: "your-postgresql-host"
    port: 5432
    database: "immich"
    username: "immich"
    existingSecret: "your-postgresql-secret"
    secretKey: "password"

redis:
  enabled: false
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

### Redis parameters

| Name | Description | Value |
|------|-------------|-------|
| `redis.enabled` | Deploy Redis subchart | `true` |
| `redis.architecture` | Redis architecture | `standalone` |
| `redis.auth.enabled` | Enable Redis authentication | `false` |

### PostgreSQL parameters

| Name | Description | Value |
|------|-------------|-------|
| `postgresql.enabled` | Deploy PostgreSQL subchart | `true` |
| `postgresql.architecture` | PostgreSQL architecture | `standalone` |
| `postgresql.auth.database` | Database name | `immich` |
| `postgresql.auth.username` | Database username | `immich` |
| `postgresql.auth.password` | Database password | `""` (auto-generated) |
| `postgresql.image.repository` | PostgreSQL image with pgvector | `tensorchord/pgvecto-rs` |
| `postgresql.image.tag` | PostgreSQL image tag | `pg16-v0.4.0` |
| `postgresql.primary.persistence.enabled` | Enable PostgreSQL persistence | `true` |
| `postgresql.primary.persistence.size` | PostgreSQL volume size | `10Gi` |

## Upgrading

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
