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

### Database Backups

Enable scheduled database backups using pg_dump (works for all database modes: standalone, cluster, and external):

```yaml
database:
  backup:
    enabled: true
    cron: "0 2 * * *"  # Daily at 2am
    retention: 30       # Keep last 30 backups
    path: /backups
    image:
      repository: ""    # Optional: custom image (defaults to standalone image or postgres:16-alpine for external/cluster)
      tag: ""
    persistence:
      enabled: true
      size: 512Mi
      storageClass: "fast-storage"
      accessMode: ReadWriteOnce
      existingClaim: ""  # Use existing PVC if desired
```

The backup CronJob creates compressed SQL dumps of the PostgreSQL database. Backups are stored with timestamps and old backups are automatically removed based on the retention policy.

### Cluster Mode PITR Backups

For `cluster` mode (CNPG), you can additionally enable Point-in-Time Recovery (PITR) backups to S3-compatible object storage:

```yaml
database:
  mode: cluster
  cluster:
    pitrBackup:
      enabled: true
      retentionPolicy: "30d"
      objectStorage:
        destinationPath: "s3://my-bucket/immich-backups"
        endpointURL: "https://s3.amazonaws.com"  # Optional for AWS, required for other S3-compatible storage
        secretName: "s3-credentials"  # Secret with ACCESS_KEY_ID and ACCESS_SECRET_KEY keys
        region: "us-east-1"  # Optional
```

The S3 credentials secret should contain:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: s3-credentials
type: Opaque
stringData:
  ACCESS_KEY_ID: "your-access-key"
  ACCESS_SECRET_KEY: "your-secret-key"
```

**Note:** PITR backups are in addition to the pg_dump backups. You can enable both for comprehensive backup coverage.

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

| Name                                            | Description                                                                            | Value                              |
| ----------------------------------------------- | -------------------------------------------------------------------------------------- | ---------------------------------- |
| `replicaCount`                                  | The number of replicas to deploy for the server.                                       | `1`                                |
| `image.repository`                              | The Docker repository to pull the image from.                                          | `ghcr.io/immich-app/immich-server` |
| `image.pullPolicy`                              | The logic of image pulling.                                                            | `IfNotPresent`                     |
| `image.tag`                                     | The image tag to use.                                                                  | `v2.4.1`                           |
| `image.autoupdate.enabled`                      | Enable automatic image updates via ArgoCD Image Updater.                               | `false`                            |
| `image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest). | `""`                               |
| `image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").  | `""`                               |
| `image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                         | `[]`                               |
| `image.autoupdate.pullSecret`                   | Reference to secret for private registry authentication.                               | `""`                               |
| `image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                       | `[]`                               |
| `imagePullSecrets`                              | The image pull secrets to use.                                                         | `[]`                               |
| `deployment.strategy.type`                      | The deployment strategy to use.                                                        | `Recreate`                         |
| `serviceAccount.create`                         | Whether to create a service account.                                                   | `true`                             |
| `serviceAccount.annotations`                    | Additional annotations to add to the service account.                                  | `{}`                               |
| `serviceAccount.name`                           | The name of the service account to use.                                                | `""`                               |
| `podAnnotations`                                | Additional annotations to add to the pod.                                              | `{}`                               |
| `podSecurityContext`                            | The security context to use for the pod.                                               | `{}`                               |
| `securityContext`                               | The security context to use for the container.                                         | `{}`                               |
| `initContainers`                                | Additional init containers to add to the pod.                                          | `[]`                               |
| `service.type`                                  | The type of service to create.                                                         | `ClusterIP`                        |
| `service.port`                                  | The port on which the service will run.                                                | `2283`                             |
| `service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.            | `""`                               |
| `ingress.enabled`                               | Whether to create an ingress for the service.                                          | `false`                            |
| `ingress.className`                             | The ingress class name to use.                                                         | `""`                               |
| `ingress.annotations`                           | Additional annotations to add to the ingress.                                          | `{}`                               |
| `ingress.hosts[0].host`                         | The host to use for the ingress.                                                       | `immich.local`                     |
| `ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                       | `/`                                |
| `ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                  | `Prefix`                           |
| `ingress.tls`                                   | The TLS configuration for the ingress.                                                 | `[]`                               |
| `resources`                                     | The resources to use for the pod.                                                      | `{}`                               |
| `autoscaling.enabled`                           | Whether to enable autoscaling.                                                         | `false`                            |
| `autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                            | `1`                                |
| `autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                            | `10`                               |
| `autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                          | `80`                               |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                       | `80`                               |
| `nodeSelector`                                  | The node selector to use for the pod.                                                  | `{}`                               |
| `tolerations`                                   | The tolerations to use for the pod.                                                    | `[]`                               |
| `affinity`                                      | The affinity to use for the pod.                                                       | `{}`                               |
| `env.TZ`                                        | Timezone for the Immich server.                                                        | `Europe/London`                    |

### Machine Learning parameters

| Name                                                  | Description                                       | Value                                        |
| ----------------------------------------------------- | ------------------------------------------------- | -------------------------------------------- |
| `machineLearning.enabled`                             | Whether to enable the machine learning component. | `true`                                       |
| `machineLearning.replicaCount`                        | The number of replicas for machine learning.      | `1`                                          |
| `machineLearning.image.repository`                    | The Docker repository for machine learning image. | `ghcr.io/immich-app/immich-machine-learning` |
| `machineLearning.image.pullPolicy`                    | The logic of image pulling.                       | `IfNotPresent`                               |
| `machineLearning.image.tag`                           | The image tag to use for machine learning.        | `v2.4.1`                                     |
| `machineLearning.env.MACHINE_LEARNING_WORKERS`        | Number of ML workers to run.                      | `1`                                          |
| `machineLearning.env.MACHINE_LEARNING_WORKER_TIMEOUT` | ML worker timeout in seconds.                     | `120`                                        |
| `machineLearning.resources`                           | The resources to use for machine learning pod.    | `{}`                                         |
| `machineLearning.persistence.enabled`                 | Whether to enable persistence for ML cache.       | `true`                                       |
| `machineLearning.persistence.storageClass`            | The storage class for ML cache.                   | `""`                                         |
| `machineLearning.persistence.size`                    | The size of the ML cache volume.                  | `512Mi`                                      |
| `machineLearning.persistence.accessMode`              | The access mode for the ML cache volume.          | `ReadWriteOnce`                              |

### Persistence parameters

| Name                                | Description                                           | Value           |
| ----------------------------------- | ----------------------------------------------------- | --------------- |
| `persistence.library.enabled`       | Whether to enable persistence for the library.        | `true`          |
| `persistence.library.storageClass`  | The storage class to use for the library.             | `""`            |
| `persistence.library.existingClaim` | The name of an existing claim to use for the library. | `""`            |
| `persistence.library.accessMode`    | The access mode to use for the library.               | `ReadWriteOnce` |
| `persistence.library.size`          | The size to use for the library.                      | `512Mi`         |
| `persistence.additionalVolumes`     | Additional volumes to add to the pod.                 | `[]`            |
| `persistence.additionalMounts`      | Additional volume mounts to add to the pod.           | `[]`            |

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

### DragonflyDB parameters

| Name                                            | Description                                                                 | Value                                         |
| ----------------------------------------------- | --------------------------------------------------------------------------- | --------------------------------------------- |
| `dragonfly.mode`                                | The mode of DragonflyDB deployment: 'standalone', 'cluster', or 'external'. | `standalone`                                  |
| `dragonfly.standalone.image.repository`         | The Docker repository for Dragonfly image.                                  | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `dragonfly.standalone.image.tag`                | The image tag for Dragonfly.                                                | `v1.36.0`                                     |
| `dragonfly.standalone.resources`                | Resource limits and requests for standalone Dragonfly.                      | `{}`                                          |
| `dragonfly.standalone.persistence.enabled`      | Whether to enable persistence for standalone Dragonfly.                     | `true`                                        |
| `dragonfly.standalone.persistence.size`         | Size of the persistence volume for standalone Dragonfly.                    | `512Mi`                                       |
| `dragonfly.standalone.persistence.storageClass` | Storage class for standalone Dragonfly persistence.                         | `""`                                          |
| `dragonfly.standalone.persistence.accessMode`   | Access mode for standalone Dragonfly persistence volume.                    | `ReadWriteOnce`                               |
| `dragonfly.cluster.replicas`                    | Number of Dragonfly replicas in the cluster.                                | `2`                                           |
| `dragonfly.cluster.image.repository`            | The Docker repository for Dragonfly cluster image.                          | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `dragonfly.cluster.image.tag`                   | The image tag for Dragonfly cluster.                                        | `v1.36.0`                                     |
| `dragonfly.cluster.resources`                   | Resource limits and requests for Dragonfly cluster.                         | `{}`                                          |
| `dragonfly.cluster.persistence.enabled`         | Whether to enable persistence for Dragonfly cluster.                        | `true`                                        |
| `dragonfly.cluster.persistence.size`            | Size of the persistence volume for Dragonfly cluster.                       | `512Mi`                                       |
| `dragonfly.cluster.persistence.storageClass`    | Storage class for Dragonfly cluster persistence.                            | `""`                                          |
| `dragonfly.cluster.persistence.accessMode`      | Access mode for Dragonfly cluster persistence volume.                       | `ReadWriteOnce`                               |
| `dragonfly.cluster.snapshot.cron`               | Cron schedule for Dragonfly cluster snapshots.                              | `*/5 * * * *`                                 |
| `dragonfly.external.host`                       | Hostname of external DragonflyDB/Redis (when mode is 'external').           | `""`                                          |
| `dragonfly.external.port`                       | Port of external DragonflyDB/Redis.                                         | `6379`                                        |
| `dragonfly.external.existingSecret`             | Secret name for external DragonflyDB/Redis password.                        | `""`                                          |
| `dragonfly.external.secretKey`                  | Key in the secret for the password.                                         | `password`                                    |

### Database parameters

| Name                                                        | Description                                                                    | Value                                                                                                        |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| `postgres.mode`                                             | The mode of PostgreSQL deployment: 'standalone', 'cluster', or 'external'.     | `standalone`                                                                                                 |
| `postgres.initSQL`                                          | Array of SQL commands to run on database initialization.                       | `["CREATE EXTENSION IF NOT EXISTS vchord CASCADE;","CREATE EXTENSION IF NOT EXISTS earthdistance CASCADE;"]` |
| `postgres.username`                                         | Username for the database.                                                     | `immich`                                                                                                     |
| `postgres.database`                                         | Database name for PostgreSQL.                                                  | `immich`                                                                                                     |
| `postgres.password.secretName`                              | Existing secret name for database password (mutually exclusive with value).    | `""`                                                                                                         |
| `postgres.password.value`                                   | Direct password value to create a secret (mutually exclusive with secretName). | `""`                                                                                                         |
| `postgres.standalone.persistence.enabled`                   | Enable persistence for standalone PostgreSQL.                                  | `true`                                                                                                       |
| `postgres.standalone.persistence.size`                      | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.standalone.persistence.storageClass`              | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.standalone.persistence.existingClaim`             | Use an existing PVC.                                                           | `""`                                                                                                         |
| `postgres.standalone.image.repository`                      | PostgreSQL image repository (with vectorchord extension).                      | `tensorchord/vchord-postgres`                                                                                |
| `postgres.standalone.persistence.enabled`                   | Enable persistence for standalone PostgreSQL.                                  | `true`                                                                                                       |
| `postgres.standalone.persistence.size`                      | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.standalone.persistence.storageClass`              | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.standalone.image.tag`                             | PostgreSQL image tag.                                                          | `pg16-v0.3.0`                                                                                                |
| `postgres.standalone.persistence.enabled`                   | Enable persistence for standalone PostgreSQL.                                  | `true`                                                                                                       |
| `postgres.standalone.persistence.size`                      | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.standalone.persistence.storageClass`              | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.standalone.image.autoupdate.enabled`              | Enable automatic image updates for standalone database (default: false).       | `false`                                                                                                      |
| `postgres.standalone.persistence.enabled`                   | Enable persistence for standalone PostgreSQL.                                  | `true`                                                                                                       |
| `postgres.standalone.persistence.size`                      | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.standalone.persistence.storageClass`              | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.standalone.image.autoupdate.updateStrategy`       | Strategy for image updates (e.g., semver, latest).                             | `""`                                                                                                         |
| `postgres.standalone.resources`                             | Resource limits and requests for standalone PostgreSQL.                        | `{}`                                                                                                         |
| `postgres.cluster.instances`                                | Number of PostgreSQL instances (replicas).                                     | `2`                                                                                                          |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                     | `true`                                                                                                       |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.cluster.image.repository`                         | PostgreSQL container image repository (with vectorchord extension).            | `tensorchord/cloudnative-vectorchord`                                                                        |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                     | `true`                                                                                                       |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.cluster.image.tag`                                | PostgreSQL container image tag.                                                | `16-0.3.0`                                                                                                   |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                     | `true`                                                                                                       |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.cluster.pitrBackup.enabled`                       | Enable PITR backups for CNPG cluster (default: false).                         | `false`                                                                                                      |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                     | `true`                                                                                                       |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.cluster.pitrBackup.retentionPolicy`               | Retention policy for PITR backups (default: "30d").                            | `30d`                                                                                                        |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                     | `true`                                                                                                       |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.cluster.pitrBackup.objectStorage.destinationPath` | S3 destination path (e.g., s3://bucket/path).                                  | `""`                                                                                                         |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                     | `true`                                                                                                       |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.cluster.pitrBackup.objectStorage.endpointURL`     | S3 endpoint URL for non-AWS storage.                                           | `""`                                                                                                         |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                     | `true`                                                                                                       |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.cluster.pitrBackup.objectStorage.secretName`      | Secret name containing ACCESS_KEY_ID and ACCESS_SECRET_KEY.                    | `""`                                                                                                         |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                     | `true`                                                                                                       |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                                | `512Mi`                                                                                                      |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                                 | `""`                                                                                                         |
| `postgres.cluster.pitrBackup.objectStorage.region`          | S3 region (optional).                                                          | `""`                                                                                                         |
| `postgres.external.host`                                    | Hostname of external PostgreSQL (when mode is 'external').                     | `""`                                                                                                         |
| `postgres.external.port`                                    | Port of external PostgreSQL.                                                   | `5432`                                                                                                       |
| `postgres.backup.enabled`                                   | Enable scheduled pg_dump backups for all database modes (default: false).      | `false`                                                                                                      |
| `postgres.backup.cron`                                      | Cron schedule for backups (default: "0 2 * * *" for 2am daily).                | `0 2 * * *`                                                                                                  |
| `postgres.backup.retention`                                 | Number of backups to retain (default: 30).                                     | `30`                                                                                                         |
| `postgres.backup.image.repository`                          | Custom image repository for backup job (optional).                             | `""`                                                                                                         |
| `postgres.backup.image.tag`                                 | Custom image tag for backup job (optional).                                    | `""`                                                                                                         |
| `postgres.backup.persistence.enabled`                       | Enable persistence for backups (default: true).                                | `true`                                                                                                       |
| `postgres.backup.persistence.size`                          | Backup volume size (default: 512Mi).                                           | `512Mi`                                                                                                      |
| `postgres.backup.persistence.storageClass`                  | Storage class for backup volume.                                               | `""`                                                                                                         |
| `postgres.backup.persistence.accessMode`                    | Access mode for backup volume (default: ReadWriteOnce).                        | `ReadWriteOnce`                                                                                              |
| `postgres.backup.persistence.existingClaim`                 | Use existing PVC for backups.                                                  | `""`                                                                                                         |

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

### To 1.6.1

This version extends database backup support:
- pg_dump backups (`database.backup.enabled`) now work in ALL database modes (standalone, cluster, external)
- Added `database.backup.image` configuration for custom backup images
- Renamed `database.cluster.backup.*` to `database.cluster.pitrBackup.*` for CNPG PITR backups
- Changed `database.cluster.backup.s3.*` to `database.cluster.pitrBackup.objectStorage.*`
- Removed `database.cluster.backup.schedule` (PITR uses continuous WAL archiving)

### To 1.6.0

This version adds:
- Database backup CronJob support for scheduled PostgreSQL backups
- New `database.secret.name` and `database.secret.passwordKey` values for flexible secret management
- Auto-generation of random passwords when not provided

**Changes:**
- `database.auth.existingSecret` is now `database.secret.name`
- Added `database.secret.passwordKey` to customize the secret key
- If `database.auth.password` is not provided and the secret doesn't exist, a random 32-character password is automatically generated
- New `database.backup.*` configuration section for scheduled database backups

To migrate from version 1.5.x:
1. Update your values.yaml to use the new secret configuration:
   ```yaml
   # Old (v1.5.x)
   database:
     auth:
       username: immich
       password: "your-password"
       existingSecret: ""
   
   # New (v1.6.0)
   database:
     auth:
       username: immich
       password: "your-password"  # Or leave empty to auto-generate
     secret:
       name: ""  # Or reference an existing secret
       passwordKey: "password"
   ```

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
