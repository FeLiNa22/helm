# Vaultwarden Helm Chart

This Helm chart deploys Vaultwarden on Kubernetes.

## Installation

```bash
helm install vaultwarden ./vaultwarden
```

## Configuration

See `values.yaml` for configuration options.

## Database Configuration

Vaultwarden supports three database modes:

### Standalone Mode (Default)

Uses Vaultwarden's built-in SQLite database. No external database is deployed.

```yaml
postgres:
  mode: standalone
```

### Cluster Mode

Deploys a PostgreSQL cluster using CloudNativePG operator for high availability.

```yaml
postgres:
  mode: cluster
  password:
    value: "your-secure-password"  # Or use secretName for existing secret
  cluster:
    instances: 2
    persistence:
      enabled: true
      size: 512Mi
      storageClass: ""
```

### External Mode

Connects to an existing external PostgreSQL database.

```yaml
postgres:
  mode: external
  external:
    host: "postgres.example.com"
    port: 5432
  password:
    value: "your-secure-password"  # Or use secretName for existing secret
```

### Database Backups

Enable scheduled pg_dump backups for cluster and external modes:

```yaml
postgres:
  backup:
    enabled: true
    cron: "0 2 * * *"  # Daily at 2am
    retention: 30  # Keep last 30 backups
    persistence:
      size: 512Mi
```

## Parameters

### Vaultwarden parameters

| Name                                            | Description                                                                                                                         | Value                    |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `enabled`                                       | Whether to enable Vaultwarden.                                                                                                      | `true`                   |
| `replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                      |
| `image.repository`                              | The Docker repository to pull the image from.                                                                                       | `vaultwarden/server`     |
| `image.tag`                                     | The image tag to use.                                                                                                               | `1.35.1`                 |
| `image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`           |
| `image.autoupdate.enabled`                      | Enable automatic image updates via ArgoCD Image Updater.                                                                            | `false`                  |
| `image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                     |
| `image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                     |
| `image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                     |
| `image.autoupdate.pullSecret`                   | Reference to secret for private registry authentication.                                                                            | `""`                     |
| `image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                     |
| `imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                     |
| `deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`               |
| `serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                   |
| `serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                     |
| `serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                     |
| `podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                     |
| `podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                     |
| `securityContext`                               | The security context to use for the container.                                                                                      | `{}`                     |
| `initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                     |
| `service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`           |
| `service.port`                                  | The port on which the service will run.                                                                                             | `80`                     |
| `service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                     |
| `ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `true`                   |
| `ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                     |
| `ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                     |
| `ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`    |
| `ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                      |
| `ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific` |
| `ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                     |
| `resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                     |
| `autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                  |
| `autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                      |
| `autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                    |
| `autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                     |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                     |
| `nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                     |
| `tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                     |
| `affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                     |
| `env.SIGNUPS_ALLOWED`                           | Whether to allow signups.                                                                                                           | `true`                   |
| `persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                   |
| `persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `ceph-rbd`               |
| `persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                     |
| `persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`          |
| `persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                  |
| `persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                     |
| `persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                     |

### Database parameters

| Name                                                        | Description                                                                                                                      | Value                               |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `postgres.enabled`                                          | Enable the postgres subchart.                                                                                                    | `false`                             |
| `postgres.mode`                                             | The mode of database deployment: 'standalone' (internal SQLite), 'cluster' (CloudNativePG), or 'external' (existing PostgreSQL). | `standalone`                        |
| `postgres.initSQL`                                          | Array of SQL commands to run on database initialization (for cluster mode).                                                      | `[]`                                |
| `postgres.username`                                         | Username for the PostgreSQL database.                                                                                            | `vaultwarden`                       |
| `postgres.database`                                         | Database name for PostgreSQL.                                                                                                    | `vaultwarden`                       |
| `postgres.password.secretName`                              | Existing secret name for database password (mutually exclusive with value).                                                      | `""`                                |
| `postgres.password.value`                                   | Direct password value to create a secret (mutually exclusive with secretName).                                                   | `""`                                |
| `postgres.cluster.instances`                                | Number of PostgreSQL instances (replicas).                                                                                       | `2`                                 |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                                                                       | `true`                              |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                                                                                  | `512Mi`                             |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                                                                                   | `""`                                |
| `postgres.cluster.image.repository`                         | PostgreSQL container image repository.                                                                                           | `ghcr.io/cloudnative-pg/postgresql` |
| `postgres.cluster.image.tag`                                | PostgreSQL container image tag.                                                                                                  | `16`                                |
| `postgres.cluster.pitrBackup.enabled`                       | Enable PITR backups for CNPG cluster (default: false).                                                                           | `false`                             |
| `postgres.cluster.pitrBackup.retentionPolicy`               | Retention policy for PITR backups (default: "30d").                                                                              | `30d`                               |
| `postgres.cluster.pitrBackup.objectStorage.destinationPath` | S3 destination path (e.g., s3://bucket/path).                                                                                    | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.endpointURL`     | S3 endpoint URL for non-AWS storage.                                                                                             | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.secretName`      | Secret name containing ACCESS_KEY_ID and ACCESS_SECRET_KEY.                                                                      | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.region`          | S3 region (optional).                                                                                                            | `""`                                |
| `postgres.external.host`                                    | Hostname of external PostgreSQL (when mode is 'external').                                                                       | `""`                                |
| `postgres.external.port`                                    | Port of external PostgreSQL.                                                                                                     | `5432`                              |
| `postgres.backup.enabled`                                   | Enable scheduled pg_dump backups for cluster and external modes (default: false).                                                | `false`                             |
| `postgres.backup.cron`                                      | Cron schedule for backups (default: "0 2 * * *" for 2am daily).                                                                  | `0 2 * * *`                         |
| `postgres.backup.retention`                                 | Number of backups to retain (default: 30).                                                                                       | `30`                                |
| `postgres.backup.persistence.enabled`                       | Enable persistence for backups (default: true).                                                                                  | `true`                              |
| `postgres.backup.persistence.size`                          | Backup volume size (default: 512Mi).                                                                                             | `512Mi`                             |
| `postgres.backup.persistence.storageClass`                  | Storage class for backup volume.                                                                                                 | `""`                                |
| `postgres.backup.persistence.accessMode`                    | Access mode for backup volume (default: ReadWriteOnce).                                                                          | `ReadWriteOnce`                     |
| `postgres.backup.persistence.existingClaim`                 | Use existing PVC for backups.                                                                                                    | `""`                                |
| `postgres.restore.enabled`                                  | Restore the latest pg_dump backup on pre-install/pre-upgrade (default: false).                                                   | `false`                             |

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

