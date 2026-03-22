# Nextcloud Helm Chart

This Helm chart deploys [Nextcloud](https://nextcloud.com/) on Kubernetes using the official [nextcloud/helm](https://github.com/nextcloud/helm) chart as its core, combined with the local `postgres` and `dragonfly` subcharts for database and caching.

## Architecture

This chart bundles:

1. **[nextcloud/nextcloud](https://github.com/nextcloud/helm)** (v9.0.3) — The upstream Nextcloud Helm chart handling the Deployment, Service, Ingress, PVC, CronJob and all Nextcloud application configuration.
2. **postgres** — Local CloudNativePG/standalone PostgreSQL subchart (enabled by default, cluster mode).
3. **dragonfly** — Local DragonflyDB subchart for Redis-compatible caching (disabled by default).

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- CloudNativePG operator (if using `postgres.mode: cluster`)
- DragonflyDB operator (if using `dragonfly.mode: cluster`)

## Installation

> ⚠️ **Important**: The default `nextcloud.externalDatabase.host` and secret names are set to
> `nextcloud-*`, which matches the naming convention when the Helm release name is `nextcloud`.
> If you use a different release name (e.g. `helm install my-cloud .`), update these values
> in your values file:
>
> ```yaml
> nextcloud:
>   externalDatabase:
>     host: "my-cloud-postgres-cluster-rw"   # {release-name}-postgres-cluster-rw
>     existingSecret:
>       secretName: "my-cloud-postgres-secret"  # {release-name}-postgres-secret
>   externalRedis:
>     host: "my-cloud-dragonfly"              # {release-name}-dragonfly
>     existingSecret:
>       secretName: "my-cloud-dragonfly-secret"  # {release-name}-dragonfly-secret
> ```

```bash
# Update dependencies
helm dependency update ./nextcloud

# Install the chart (replace 'nextcloud' with your desired release name)
helm install nextcloud ./nextcloud \
  --set postgres.password.value=your-db-password \
  --set nextcloud.nextcloud.host=nextcloud.example.com \
  --set nextcloud.nextcloud.password=your-admin-password
```

## Configuration

All Nextcloud application settings are configured under the `nextcloud:` key, which is passed
directly to the upstream chart. For the full list of upstream values, see the
[upstream chart documentation](https://github.com/nextcloud/helm/blob/main/charts/nextcloud/values.yaml).

### Nextcloud application settings

```yaml
nextcloud:
  nextcloud:
    host: nextcloud.example.com
    username: admin
    password: changeme

  image:
    registry: docker.io
    repository: library/nextcloud
    tag: "33.0.0"

  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: 4G
    path: /
    pathType: Prefix
    tls:
      - secretName: nextcloud-tls
        hosts:
          - nextcloud.example.com

  persistence:
    enabled: true
    storageClass: "your-storage-class"
    size: 20Gi
```

### Database Modes

#### PostgreSQL Options

The `postgres` subchart supports three deployment modes:

1. **Cluster** (default): CloudNativePG high-availability cluster
2. **Standalone**: Single-instance PostgreSQL StatefulSet
3. **External**: Connect to an existing PostgreSQL instance

```yaml
# Cluster mode (default) — requires CloudNativePG operator
postgres:
  enabled: true
  mode: cluster
  username: nextcloud
  database: nextcloud
  password:
    value: "your-secure-password"
  cluster:
    instances: 2
    persistence:
      size: 10Gi
      storageClass: "your-storage-class"

# Standalone mode
postgres:
  mode: standalone
  password:
    value: "your-secure-password"
  standalone:
    persistence:
      size: 10Gi
      storageClass: "your-storage-class"

# External mode
postgres:
  mode: external
  password:
    secretName: "existing-postgres-secret"
  external:
    host: "your-postgresql-host"
    port: 5432
# Also update the upstream nextcloud chart's externalDatabase.host:
nextcloud:
  externalDatabase:
    host: "your-postgresql-host:5432"
    existingSecret:
      secretName: "existing-postgres-secret"
```

### DragonflyDB (Redis-compatible caching)

Enable optional Redis-compatible caching via the `dragonfly` subchart.
When enabling, also set `nextcloud.externalRedis.enabled: true`.

```yaml
# Standalone DragonflyDB
dragonfly:
  enabled: true
  mode: standalone
  password:
    value: "your-redis-password"
  standalone:
    persistence:
      size: 1Gi

nextcloud:
  externalRedis:
    enabled: true
    host: "nextcloud-dragonfly"  # {release-name}-dragonfly
    existingSecret:
      secretName: "nextcloud-dragonfly-secret"  # {release-name}-dragonfly-secret

# External Redis/DragonflyDB
dragonfly:
  enabled: false
  mode: external
  password:
    secretName: "existing-redis-secret"
  external:
    host: "your-redis-host"
    port: 6379

nextcloud:
  externalRedis:
    enabled: true
    host: "your-redis-host"
    existingSecret:
      enabled: true
      secretName: "existing-redis-secret"
      passwordKey: password
```

## Parameters

### Upstream Nextcloud chart parameters

All values under `nextcloud:` are passed to the upstream `nextcloud/nextcloud` chart.
Key parameters:

| Name | Description | Value |
| ---- | ----------- | ----- |
| `nextcloud.nextcloud.host` | Nextcloud hostname | `nextcloud.example.com` |
| `nextcloud.nextcloud.username` | Admin username | `admin` |
| `nextcloud.nextcloud.password` | Admin password | `changeme` |
| `nextcloud.image.registry` | Docker registry | `docker.io` |
| `nextcloud.image.repository` | Docker image repository | `library/nextcloud` |
| `nextcloud.image.tag` | Nextcloud image tag | `33.0.0` |
| `nextcloud.ingress.enabled` | Enable Ingress | `false` |
| `nextcloud.persistence.enabled` | Enable PVC for Nextcloud data | `true` |
| `nextcloud.persistence.size` | PVC size | `8Gi` |
| `nextcloud.externalDatabase.enabled` | Enable external PostgreSQL | `true` |
| `nextcloud.externalDatabase.host` | PostgreSQL host | `nextcloud-postgres-cluster-rw` |
| `nextcloud.externalDatabase.existingSecret.secretName` | PostgreSQL credentials secret | `nextcloud-postgres-secret` |
| `nextcloud.externalRedis.enabled` | Enable external Redis/DragonflyDB | `false` |
| `nextcloud.externalRedis.host` | Redis/DragonflyDB host | `nextcloud-dragonfly` |
| `nextcloud.externalRedis.existingSecret.secretName` | Redis credentials secret | `nextcloud-dragonfly-secret` |
| `nextcloud.postgresql.enabled` | Bitnami PostgreSQL (disabled; use postgres subchart) | `false` |
| `nextcloud.mariadb.enabled` | Bitnami MariaDB (disabled) | `false` |
| `nextcloud.redis.enabled` | Bitnami Redis (disabled; use dragonfly subchart) | `false` |

### DragonflyDB parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `dragonfly.enabled` | Enable the dragonfly subchart | `false` |
| `dragonfly.mode` | Deployment mode: `standalone`, `cluster`, `external`, or `disabled` | `disabled` |
| `dragonfly.password.secretName` | Existing secret for DragonflyDB password | `""` |
| `dragonfly.password.value` | DragonflyDB password | `""` |
| `dragonfly.standalone.persistence.size` | PVC size for standalone | `512Mi` |
| `dragonfly.cluster.replicas` | Replicas in cluster mode | `2` |
| `dragonfly.external.host` | External Redis/DragonflyDB hostname | `""` |
| `dragonfly.external.port` | External Redis/DragonflyDB port | `6379` |

### PostgreSQL parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `postgres.enabled` | Enable the postgres subchart | `true` |
| `postgres.mode` | Deployment mode: `standalone`, `cluster`, or `external` | `cluster` |
| `postgres.username` | PostgreSQL username | `nextcloud` |
| `postgres.database` | PostgreSQL database name | `nextcloud` |
| `postgres.password.secretName` | Existing secret for database password | `""` |
| `postgres.password.value` | Database password (required) | `""` |
| `postgres.standalone.persistence.size` | PVC size for standalone | `512Mi` |
| `postgres.cluster.instances` | Number of CNPG cluster instances | `2` |
| `postgres.cluster.persistence.size` | PVC size per CNPG instance | `512Mi` |
| `postgres.external.host` | External PostgreSQL hostname | `""` |
| `postgres.external.port` | External PostgreSQL port | `5432` |

### Velero Backup Schedule parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `velero.enabled` | Enable Velero backup schedule | `false` |
| `velero.namespace` | Velero namespace | `velero` |
| `velero.schedule` | Cron schedule for backups | `0 2 * * *` |
| `velero.ttl` | Backup retention period | `168h` |
| `velero.snapshotVolumes` | Enable volume snapshots | `true` |

### Image autoupdate parameters (ArgoCD Image Updater)

| Name | Description | Value |
| ---- | ----------- | ----- |
| `image.autoupdate.enabled` | Enable ArgoCD Image Updater | `false` |
| `image.autoupdate.strategy` | Update strategy | `""` |
| `image.autoupdate.allowTags` | Allowed tag pattern | `""` |

### ArgoCD Image Updater parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `imageUpdater.namespace` | Namespace for ImageUpdater CRD | `argocd` |
| `imageUpdater.argocdNamespace` | ArgoCD namespace | `argocd` |
| `imageUpdater.applicationName` | ArgoCD Application name | `""` |

## Upgrading

### To 2.0.0

This is a major breaking change. The chart no longer deploys its own Deployment, Service,
Ingress, PVC, HPA, ServiceAccount, and CronJob templates. Instead, these are now provided
by the upstream `nextcloud/nextcloud` chart (v9.0.3, app v33.0.0).

**Breaking Changes:**

- The top-level `enabled`, `replicaCount`, `image`, `service`, `ingress`, `persistence`,
  `resources`, `autoscaling`, `nodeSelector`, `tolerations`, `affinity`, `env`,
  `nextcloudHost`, `cronjob`, `livenessProbe`, `readinessProbe`, `startupProbe`,
  `podAnnotations`, `podSecurityContext`, `securityContext`, `initContainers`,
  `serviceAccount`, and `deployment` keys have been removed.
- All Nextcloud application configuration is now under the `nextcloud:` key which maps
  to the upstream chart's values. See the [upstream values reference](https://github.com/nextcloud/helm/blob/main/charts/nextcloud/values.yaml).
- `velero` no longer checks `persistence.enabled`; the schedule is created whenever `velero.enabled: true`.
- The image autoupdate manifest targets now use `nextcloud.image.repository` and `nextcloud.image.tag`.

**Migration steps:**

1. Back up your Nextcloud data.
2. Map your old values to the new structure:
   - `image.*` → `nextcloud.image.*`
   - `service.*` → `nextcloud.service.*`
   - `ingress.*` → `nextcloud.ingress.*`
   - `persistence.*` → `nextcloud.persistence.*`
   - `env.NEXTCLOUD_ADMIN_USER` → `nextcloud.nextcloud.username`
   - `env.NEXTCLOUD_ADMIN_PASSWORD` → `nextcloud.nextcloud.password`
   - `env.NEXTCLOUD_TRUSTED_DOMAINS` → `nextcloud.nextcloud.trustedDomains`
   - `nextcloudHost` → `nextcloud.nextcloud.host`
   - `resources` → `nextcloud.nextcloud.resources`
   - `nodeSelector` → `nextcloud.nodeSelector`
   - `tolerations` → `nextcloud.tolerations`
   - `affinity` → `nextcloud.affinity`
3. Run `helm dependency update` to fetch the upstream chart.
4. Install or upgrade: `helm upgrade nextcloud ./nextcloud -f your-values.yaml`
