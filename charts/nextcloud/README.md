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

| Name                                            | Description                                                                                                                         | Value                         |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| `enabled`                                       | Whether to enable Nextcloud.                                                                                                        | `true`                        |
| `replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                           |
| `image.repository`                              | The Docker repository to pull the image from.                                                                                       | `docker.io/library/nextcloud` |
| `image.tag`                                     | The image tag to use.                                                                                                               | `32.0.3`                      |
| `image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                |
| `image.autoupdate.enabled`                      | Enable automatic image updates via ArgoCD Image Updater.                                                                            | `false`                       |
| `image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                          |
| `image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                          |
| `image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                          |
| `image.autoupdate.pullSecret`                   | Reference to secret for private registry authentication.                                                                            | `""`                          |
| `image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                          |
| `imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                          |
| `deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                    |
| `serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                        |
| `serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                          |
| `serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                          |
| `podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                          |
| `podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                          |
| `securityContext`                               | The security context to use for the container.                                                                                      | `{}`                          |
| `initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                          |
| `service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`                |
| `service.port`                                  | The port on which the service will run.                                                                                             | `80`                          |
| `service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                          |
| `ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `true`                        |
| `ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                          |
| `ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                          |
| `ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`         |
| `ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                           |
| `ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`      |
| `ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                          |
| `resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                          |
| `autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                       |
| `autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                           |
| `autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                         |
| `autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                          |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                          |
| `nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                          |
| `tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                          |
| `affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                          |
| `env.NEXTCLOUD_ADMIN_USER`                      | The admin username.                                                                                                                 | `admin`                       |
| `env.NEXTCLOUD_ADMIN_PASSWORD`                  | The admin password.                                                                                                                 | `admin`                       |
| `env.NEXTCLOUD_TRUSTED_DOMAINS`                 | Trusted domains for Nextcloud.                                                                                                      | `localhost`                   |
| `persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                        |
| `persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `ceph-rbd`                    |
| `persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                          |
| `persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`               |
| `persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                       |
| `persistence.backup.enabled`                    | Whether to enable backup persistence.                                                                                               | `true`                        |
| `persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                    | `cephfs`                      |
| `persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                        | `""`                          |
| `persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                      | `ReadWriteMany`               |
| `persistence.backup.size`                       | The size to use for backup persistence.                                                                                             | `512Mi`                       |
| `persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                          |
| `persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                          |

### DragonflyDB parameters

| Name                                                  | Description                                                                             | Value                                         |
| ----------------------------------------------------- | --------------------------------------------------------------------------------------- | --------------------------------------------- |
| `dragonfly.mode`                                      | The mode of DragonflyDB deployment: 'standalone', 'cluster', 'external', or 'disabled'. | `disabled`                                    |
| `dragonfly.standalone.image.repository`               | The Docker repository for Dragonfly image.                                              | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `dragonfly.standalone.image.tag`                      | The image tag for Dragonfly.                                                            | `v1.25.2`                                     |
| `dragonfly.standalone.resources`                      | Resource limits and requests for standalone Dragonfly.                                  | `{}`                                          |
| `dragonfly.standalone.persistence.enabled`            | Whether to enable persistence for standalone Dragonfly.                                 | `true`                                        |
| `dragonfly.standalone.persistence.size`               | Size of the persistence volume for standalone Dragonfly.                                | `512Mi`                                       |
| `dragonfly.standalone.persistence.storageClass`       | Storage class for standalone Dragonfly persistence.                                     | `""`                                          |
| `dragonfly.standalone.persistence.accessMode`         | Access mode for standalone Dragonfly persistence volume.                                | `ReadWriteOnce`                               |
| `dragonfly.cluster.replicas`                          | Number of Dragonfly replicas in the cluster.                                            | `2`                                           |
| `dragonfly.cluster.image.repository`                  | The Docker repository for Dragonfly cluster image.                                      | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `dragonfly.cluster.image.tag`                         | The image tag for Dragonfly cluster.                                                    | `v1.25.2`                                     |
| `dragonfly.cluster.resources`                         | Resource limits and requests for Dragonfly cluster.                                     | `{}`                                          |
| `dragonfly.cluster.persistence.enabled`               | Whether to enable persistence for Dragonfly cluster.                                    | `true`                                        |
| `dragonfly.cluster.persistence.size`                  | Size of the persistence volume for Dragonfly cluster.                                   | `512Mi`                                       |
| `dragonfly.cluster.persistence.storageClass`          | Storage class for Dragonfly cluster persistence.                                        | `""`                                          |
| `dragonfly.cluster.persistence.accessMode`            | Access mode for Dragonfly cluster persistence volume.                                   | `ReadWriteOnce`                               |
| `dragonfly.cluster.snapshot.cron`                     | Cron schedule for Dragonfly cluster snapshots.                                          | `*/5 * * * *`                                 |
| `dragonfly.external.host`                             | Hostname of external DragonflyDB/Redis (when mode is 'external').                       | `""`                                          |
| `dragonfly.external.port`                             | Port of external DragonflyDB/Redis.                                                     | `6379`                                        |
| `dragonfly.external.existingSecret`                   | Secret name for external DragonflyDB/Redis password.                                    | `""`                                          |
| `dragonfly.external.secretKey`                        | Key in the secret for the password.                                                     | `password`                                    |
| `postgres.mode`                                       | The mode of PostgreSQL deployment: 'standalone', 'cluster', or 'external'.              | `cluster`                                     |
| `postgres.initSQL`                                    | Array of SQL commands to run on database initialization.                                | `[]`                                          |
| `postgres.username`                                   | Username for the database.                                                              | `nextcloud`                                   |
| `postgres.database`                                   | Database name for PostgreSQL.                                                           | `nextcloud`                                   |
| `postgres.password.secretName`                        | Existing secret name for database password (mutually exclusive with value).             | `""`                                          |
| `postgres.password.value`                             | Direct password value to create a secret (mutually exclusive with secretName).          | `""`                                          |
| `postgres.standalone.persistence.enabled`             | Enable persistence for standalone PostgreSQL.                                           | `true`                                        |
| `postgres.standalone.persistence.size`                | Size of the persistence volume.                                                         | `512Mi`                                       |
| `postgres.standalone.persistence.storageClass`        | Storage class for persistence.                                                          | `ceph-rbd`                                    |
| `postgres.standalone.persistence.existingClaim`       | Use an existing PVC.                                                                    | `""`                                          |
| `postgres.standalone.image.repository`                | PostgreSQL image repository.                                                            | `postgres`                                    |
| `postgres.standalone.persistence.enabled`             | Enable persistence for standalone PostgreSQL.                                           | `true`                                        |
| `postgres.standalone.persistence.size`                | Size of the persistence volume.                                                         | `512Mi`                                       |
| `postgres.standalone.persistence.storageClass`        | Storage class for persistence.                                                          | `ceph-rbd`                                    |
| `postgres.standalone.persistence.existingClaim`       | Use an existing PVC.                                                                    | `""`                                          |
| `postgres.standalone.image.tag`                       | PostgreSQL image tag.                                                                   | `16-alpine`                                   |
| `postgres.standalone.persistence.enabled`             | Enable persistence for standalone PostgreSQL.                                           | `true`                                        |
| `postgres.standalone.persistence.size`                | Size of the persistence volume.                                                         | `512Mi`                                       |
| `postgres.standalone.persistence.storageClass`        | Storage class for persistence.                                                          | `ceph-rbd`                                    |
| `postgres.standalone.persistence.existingClaim`       | Use an existing PVC.                                                                    | `""`                                          |
| `postgres.standalone.image.autoupdate.enabled`        | Enable automatic image updates for standalone database (default: false).                | `false`                                       |
| `postgres.standalone.persistence.enabled`             | Enable persistence for standalone PostgreSQL.                                           | `true`                                        |
| `postgres.standalone.persistence.size`                | Size of the persistence volume.                                                         | `512Mi`                                       |
| `postgres.standalone.persistence.storageClass`        | Storage class for persistence.                                                          | `ceph-rbd`                                    |
| `postgres.standalone.persistence.existingClaim`       | Use an existing PVC.                                                                    | `""`                                          |
| `postgres.standalone.image.autoupdate.updateStrategy` | Strategy for image updates (e.g., semver, latest).                                      | `""`                                          |
| `postgres.standalone.resources`                       | Resource limits and requests for standalone PostgreSQL.                                 | `{}`                                          |
| `postgres.cluster.instances`                          | Number of PostgreSQL instances (replicas).                                              | `2`                                           |
| `postgres.cluster.persistence.enabled`                | Enable persistence for cluster PostgreSQL.                                              | `true`                                        |
| `postgres.cluster.persistence.size`                   | Size of the persistence volume.                                                         | `512Mi`                                       |
| `postgres.cluster.persistence.storageClass`           | Storage class for persistence.                                                          | `ceph-rbd`                                    |
| `postgres.cluster.image.repository`                   | PostgreSQL container image repository.                                                  | `ghcr.io/cloudnative-pg/postgresql`           |
| `postgres.cluster.persistence.enabled`                | Enable persistence for cluster PostgreSQL.                                              | `true`                                        |
| `postgres.cluster.persistence.size`                   | Size of the persistence volume.                                                         | `512Mi`                                       |
| `postgres.cluster.persistence.storageClass`           | Storage class for persistence.                                                          | `ceph-rbd`                                    |
| `postgres.cluster.image.tag`                          | PostgreSQL container image tag.                                                         | `16`                                          |
| `postgres.external.host`                              | Hostname of external PostgreSQL (when mode is 'external').                              | `""`                                          |
| `postgres.external.port`                              | Port of external PostgreSQL.                                                            | `5432`                                        |

### Velero Backup Schedule parameters

| Name                              | Description                                                                               | Value       |
| --------------------------------- | ----------------------------------------------------------------------------------------- | ----------- |
| `velero.enabled`                  | Whether to enable Velero backup schedules                                                 | `false`     |
| `velero.namespace`                | The namespace where Velero is deployed (Schedule CRD must be created in Velero namespace) | `velero`    |
| `velero.schedule`                 | The cron schedule for Velero backups (e.g., "0 2 * * *" for 2am daily)                    | `0 2 * * *` |
| `velero.ttl`                      | Time to live for backups (e.g., "720h" for 30 days)                                       | `168h`      |
| `velero.includeClusterResources`  | Whether to include cluster-scoped resources in backup                                     | `false`     |
| `velero.snapshotVolumes`          | Whether to take volume snapshots                                                          | `true`      |
| `velero.defaultVolumesToFsBackup` | Whether to use file system backup for volumes by default                                  | `false`     |
| `velero.storageLocation`          | The storage location for backups (leave empty for default)                                | `""`        |
| `velero.volumeSnapshotLocations`  | The volume snapshot locations (leave empty for default)                                   | `[]`        |
| `velero.labelSelector`            | Additional label selector to filter resources (optional)                                  | `{}`        |
| `velero.annotations`              | Additional annotations to add to the Velero Schedule resources                            | `{}`        |

### ArgoCD Image Updater parameters

| Name                           | Description                                                                                           | Value    |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- | -------- |
| `imageUpdater.namespace`       | Namespace where the ImageUpdater CRD will be created.                                                 | `argocd` |
| `imageUpdater.argocdNamespace` | Namespace where ArgoCD Applications are located.                                                      | `argocd` |
| `imageUpdater.applicationName` | Name or pattern of the ArgoCD Application to update. Defaults to Release name.                        | `""`     |
| `imageUpdater.imageAlias`      | Alias for the image in the ImageUpdater CRD. Defaults to Release name.                                | `""`     |
| `imageUpdater.forceUpdate`     | Force update even if image is not currently deployed.                                                 | `false`  |
| `imageUpdater.helm`            | Helm-specific configuration for parameter names (e.g., {name: "image.repository", tag: "image.tag"}). | `{}`     |
| `imageUpdater.kustomize`       | Kustomize-specific configuration (e.g., {name: "original/image"}).                                    | `{}`     |
| `imageUpdater.writeBackConfig` | Write-back configuration for GitOps.                                                                  | `{}`     |

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
