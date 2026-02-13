# Custom Helm Chart

This Helm chart deploys a generic Docker image with an optional PostgreSQL database. It's designed to be flexible and customizable for deploying various containerized applications.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- CloudNativePG operator (if using `database.mode: cluster`)

## Installation

Install the chart:

```bash
# Install the chart
helm install myapp ./custom

# Install with custom values
helm install myapp ./custom -f custom-values.yaml

# Install with specific image
helm install myapp ./custom --set image.repository=nginx --set image.tag=1.21
```

## Configuration

See `values.yaml` for all configuration options.

### Quick Start Examples

#### Deploy a simple application with persistent storage

```yaml
image:
  repository: myapp/myimage
  tag: "1.0.0"

service:
  port: 8080

persistence:
  data:
    enabled: true
    size: 5Gi
    mountPath: /app/data

database:
  enabled: false
```

#### Deploy with PostgreSQL database

```yaml
image:
  repository: myapp/myimage
  tag: "1.0.0"

database:
  enabled: true
  mode: standalone
  auth:
    username: myapp
    password: "mysecurepassword"
  persistence:
    size: 10Gi
```

## Architecture

This chart can deploy the following components:

1. **Application** - The main application container (configurable Docker image)
2. **PostgreSQL** - Optional database (standalone using StatefulSet or CloudNativePG cluster)
3. **Persistence** - Optional persistent volumes for application data
4. **Ingress** - Optional ingress for external access

### Database Modes

The chart supports PostgreSQL in three deployment modes, or can be disabled entirely:

#### 1. Database Disabled

By default, the database is enabled. To disable it:

```yaml
database:
  enabled: false
```

#### 2. Standalone Mode (default when enabled)

Deploys PostgreSQL using StatefulSet. This is the simplest option and suitable for development and single-instance deployments.

```yaml
database:
  enabled: true
  mode: standalone
  auth:
    username: myapp
    password: "your-password"  # Leave empty to auto-generate
  persistence:
    enabled: true
    size: 10Gi
```

#### 3. Cluster Mode

Uses CloudNativePG operator for high-availability PostgreSQL cluster. Requires the CloudNativePG operator to be installed in your cluster.

```yaml
database:
  enabled: true
  mode: cluster
  cluster:
    instances: 2
    name: myapp-db
  auth:
    username: myapp
  persistence:
    size: 20Gi
```

#### 4. External Mode

Connect to an existing external PostgreSQL instance:

```yaml
database:
  enabled: true
  mode: external
  external:
    host: "postgresql.example.com"
    port: 5432
    database: "myapp"
    username: "myapp"
  secret:
    name: "myapp-db-secret"  # Secret containing the password
    passwordKey: "password"
```

### Persistence Configuration

The chart supports persistent storage for the application:

```yaml
persistence:
  data:
    enabled: true
    storageClass: "fast-ssd"
    size: 10Gi
    mountPath: /data  # Where to mount in the container
    accessMode: ReadWriteOnce
```

You can also add additional volumes:

```yaml
persistence:
  additionalVolumes:
    - name: config
      configMap:
        name: my-config
  additionalMounts:
    - name: config
      mountPath: /etc/config
      readOnly: true
```

### Database Initialization

You can run SQL commands during database initialization:

```yaml
database:
  enabled: true
  initSQL:
    - "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    - "CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name VARCHAR(100));"
```

### Database Backups

Schedule automated backups using pg_dump:

```yaml
database:
  enabled: true
  backup:
    enabled: true
    cron: "0 2 * * *"  # Daily at 2am
    retention: 30  # Keep 30 backups
    persistence:
      enabled: true
      size: 10Gi
```

### Velero Backups

Enable Velero backup schedules for the application:

```yaml
velero:
  enabled: true
  namespace: "velero"
  schedule: "0 2 * * *"  # Daily at 2am
  ttl: "168h"  # 7 days retention
  snapshotVolumes: true

persistence:
  data:
    enabled: true  # Required for Velero backups
    size: 10Gi
```

**Note:** Velero backups require persistence to be enabled. The backup will include the data volume.

### Environment Variables

Environment variables are passed to the application container using a map format:

```yaml
env:
  TZ: "Europe/London"
  LOG_LEVEL: "info"
  APP_ENV: "production"
```

When the database is enabled, these environment variables are automatically set:
- `DB_HOST` - Database hostname
- `DB_PORT` - Database port
- `DB_DATABASE` - Database name
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password (from secret)

### Image Auto-update

The chart supports automatic image updates via ArgoCD Image Updater:

```yaml
image:
  repository: myapp/myimage
  tag: "1.0.0"
  autoupdate:
    enabled: true
    strategy: semver  # or 'latest', 'digest', etc.
    allowTags: "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$"  # Optional: filter tags
```

The auto-update feature will:
- Automatically detect and update to newer versions based on the strategy
- Support semver, digest, and other update strategies
- Allow filtering tags with regex patterns
- Support private registries with pull secrets

### Ingress

Enable ingress for external access:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com
```

### Resource Limits

Configure resource requests and limits:

```yaml
resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi
```

### Init Containers

Add init containers for setup tasks:

```yaml
initContainers:
  - name: wait-for-db
    image: busybox
    command: ['sh', '-c', 'until nc -z myapp-postgresql 5432; do sleep 1; done']
```

## Parameters

### Application parameters

| Name                                 | Description                                                                            | Value           |
| ------------------------------------ | -------------------------------------------------------------------------------------- | --------------- |
| `replicaCount`                       | The number of replicas to deploy for the application.                                  | `1`             |
| `image.repository`                   | The Docker repository to pull the image from.                                          | `nginx`         |
| `image.pullPolicy`                   | The logic of image pulling.                                                            | `IfNotPresent`  |
| `image.tag`                          | The image tag to use.                                                                  | `""`            |
| `image.autoupdate.enabled`           | Enable automatic image updates via ArgoCD Image Updater.                               | `false`         |
| `image.autoupdate.strategy`          | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest). | `""`            |
| `image.autoupdate.allowTags`         | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").  | `""`            |
| `image.autoupdate.ignoreTags`        | List of glob patterns to ignore specific tags.                                         | `[]`            |
| `image.autoupdate.pullSecret`        | Reference to secret for private registry authentication.                               | `""`            |
| `image.autoupdate.platforms`         | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                       | `[]`            |
| `imagePullSecrets`                   | The image pull secrets to use.                                                         | `[]`            |
| `deployment.strategy.type`           | The deployment strategy to use.                                                        | `Recreate`      |
| `serviceAccount.create`              | Whether to create a service account.                                                   | `true`          |
| `serviceAccount.annotations`         | Additional annotations to add to the service account.                                  | `{}`            |
| `serviceAccount.name`                | The name of the service account to use.                                                | `""`            |
| `podAnnotations`                     | Additional annotations to add to the pod.                                              | `{}`            |
| `podSecurityContext`                 | The security context to use for the pod.                                               | `{}`            |
| `securityContext`                    | The security context to use for the container.                                         | `{}`            |
| `initContainers`                     | Additional init containers to add to the pod.                                          | `[]`            |
| `service.type`                       | The type of service to create.                                                         | `ClusterIP`     |
| `service.port`                       | The port on which the service will run.                                                | `80`            |
| `service.nodePort`                   | The nodePort to use for the service. Only used if service.type is NodePort.            | `""`            |
| `ingress.enabled`                    | Whether to create an ingress for the service.                                          | `false`         |
| `ingress.className`                  | The ingress class name to use.                                                         | `""`            |
| `ingress.annotations`                | Additional annotations to add to the ingress.                                          | `{}`            |
| `ingress.hosts[0].host`              | The host to use for the ingress.                                                       | `custom.local`  |
| `ingress.hosts[0].paths[0].path`     | The path to use for the ingress.                                                       | `/`             |
| `ingress.hosts[0].paths[0].pathType` | The path type to use for the ingress.                                                  | `Prefix`        |
| `ingress.tls`                        | The TLS configuration for the ingress.                                                 | `[]`            |
| `resources`                          | The resources to use for the pod.                                                      | `{}`            |
| `nodeSelector`                       | The node selector to use for the pod.                                                  | `{}`            |
| `tolerations`                        | The tolerations to use for the pod.                                                    | `[]`            |
| `affinity`                           | The affinity to use for the pod.                                                       | `{}`            |
| `env.TZ`                             | The timezone to use for the pod.                                                       | `Europe/London` |

### Persistence parameters

| Name                             | Description                                        | Value           |
| -------------------------------- | -------------------------------------------------- | --------------- |
| `persistence.data.enabled`       | Whether to enable persistence for the data.        | `false`         |
| `persistence.data.storageClass`  | The storage class to use for the data.             | `""`            |
| `persistence.data.existingClaim` | The name of an existing claim to use for the data. | `""`            |
| `persistence.data.accessMode`    | The access mode to use for the data.               | `ReadWriteOnce` |
| `persistence.data.size`          | The size to use for the data.                      | `1Gi`           |
| `persistence.data.mountPath`     | The mount path for the data volume.                | `/data`         |
| `persistence.additionalVolumes`  | Additional volumes to add to the pod.              | `[]`            |
| `persistence.additionalMounts`   | Additional volume mounts to add to the pod.        | `[]`            |

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

### Database parameters

| Name                                                        | Description                                                                | Value                               |
| ----------------------------------------------------------- | -------------------------------------------------------------------------- | ----------------------------------- |
| `postgres.enabled`                                          | Whether to enable PostgreSQL database.                                     | `false`                             |
| `postgres.mode`                                             | The mode of PostgreSQL deployment: 'standalone', 'cluster', or 'external'. | `standalone`                        |
| `postgres.initSQL`                                          | Array of SQL commands to run on database initialization.                   | `[]`                                |
| `postgres.username`                                         | Username for the database.                                                 | `custom`                            |
| `postgres.database`                                         | Database name for PostgreSQL.                                              | `custom`                            |
| `postgres.password.secretName`                              | Existing secret name for database password (leave empty to auto-create).   | `""`                                |
| `postgres.password.secretKey`                               | Key in the secret containing the password (default: password).             | `password`                          |
| `postgres.standalone.persistence.enabled`                   | Enable persistence for standalone PostgreSQL.                              | `true`                              |
| `postgres.standalone.persistence.size`                      | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.standalone.persistence.storageClass`              | Storage class for persistence.                                             | `""`                                |
| `postgres.standalone.image.repository`                      | PostgreSQL image repository.                                               | `postgres`                          |
| `postgres.standalone.persistence.enabled`                   | Enable persistence for standalone PostgreSQL.                              | `true`                              |
| `postgres.standalone.persistence.size`                      | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.standalone.persistence.storageClass`              | Storage class for persistence.                                             | `""`                                |
| `postgres.standalone.image.tag`                             | PostgreSQL image tag.                                                      | `16-alpine`                         |
| `postgres.standalone.resources`                             | Resource limits and requests for standalone PostgreSQL.                    | `{}`                                |
| `postgres.cluster.instances`                                | Number of PostgreSQL instances (replicas).                                 | `2`                                 |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                 | `true`                              |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                             | `""`                                |
| `postgres.cluster.image.repository`                         | PostgreSQL container image repository.                                     | `ghcr.io/cloudnative-pg/postgresql` |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                 | `true`                              |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                             | `""`                                |
| `postgres.cluster.image.tag`                                | PostgreSQL container image tag.                                            | `16`                                |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                 | `true`                              |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                             | `""`                                |
| `postgres.cluster.pitrBackup.enabled`                       | Enable PITR backups for CNPG cluster (default: false).                     | `false`                             |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                 | `true`                              |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                             | `""`                                |
| `postgres.cluster.pitrBackup.retentionPolicy`               | Retention policy for PITR backups (default: "30d").                        | `30d`                               |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                 | `true`                              |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                             | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.destinationPath` | S3 destination path (e.g., s3://bucket/path).                              | `""`                                |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                 | `true`                              |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                             | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.endpointURL`     | S3 endpoint URL for non-AWS storage.                                       | `""`                                |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                 | `true`                              |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                             | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.secretName`      | Secret name containing ACCESS_KEY_ID and ACCESS_SECRET_KEY.                | `""`                                |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster PostgreSQL.                                 | `true`                              |
| `postgres.cluster.persistence.size`                         | Size of the persistence volume.                                            | `1Gi`                               |
| `postgres.cluster.persistence.storageClass`                 | Storage class for persistence.                                             | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.region`          | S3 region (optional).                                                      | `""`                                |
| `postgres.external.host`                                    | Hostname of external PostgreSQL (when mode is 'external').                 | `""`                                |
| `postgres.external.port`                                    | Port of external PostgreSQL.                                               | `5432`                              |
| `postgres.backup.enabled`                                   | Enable scheduled pg_dump backups for all database modes (default: false).  | `false`                             |
| `postgres.backup.cron`                                      | Cron schedule for backups (default: "0 2 * * *" for 2am daily).            | `0 2 * * *`                         |
| `postgres.backup.retention`                                 | Number of backups to retain (default: 30).                                 | `30`                                |
| `postgres.backup.image.repository`                          | Custom image repository for backup job (optional).                         | `""`                                |
| `postgres.backup.image.tag`                                 | Custom image tag for backup job (optional).                                | `""`                                |
| `postgres.backup.persistence.enabled`                       | Enable persistence for backups (default: true).                            | `true`                              |
| `postgres.backup.persistence.size`                          | Backup volume size (default: 512Mi).                                       | `512Mi`                             |
| `postgres.backup.persistence.storageClass`                  | Storage class for backup volume.                                           | `""`                                |
| `postgres.backup.persistence.accessMode`                    | Access mode for backup volume (default: ReadWriteOnce).                    | `ReadWriteOnce`                     |
| `postgres.backup.persistence.existingClaim`                 | Use existing PVC for backups.                                              | `""`                                |

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

### To upgrade the chart

```bash
helm upgrade myapp ./custom -f custom-values.yaml
```

### Important Notes

- Database passwords are auto-generated and stored in secrets if not provided
- Secrets persist across upgrades via Kubernetes secret lookup
- Always backup your data before upgrading
- Review the changelog for breaking changes

## Uninstalling

```bash
helm uninstall myapp
```

**Note:** This will delete the application but persistent volumes and their data may be retained depending on your cluster's reclaim policy.

## Examples

### Example 1: Simple Web Server

```yaml
image:
  repository: nginx
  tag: "1.21"

service:
  port: 80

ingress:
  enabled: true
  hosts:
    - host: web.example.com
      paths:
        - path: /
          pathType: Prefix

persistence:
  data:
    enabled: true
    size: 1Gi
    mountPath: /usr/share/nginx/html

database:
  enabled: false
```

### Example 2: Application with Database

```yaml
image:
  repository: myapp/backend
  tag: "2.0.0"

service:
  port: 8080

env:
  APP_ENV: production
  LOG_LEVEL: info

database:
  enabled: true
  mode: standalone
  auth:
    username: myapp
  persistence:
    size: 20Gi
  backup:
    enabled: true
    cron: "0 3 * * *"
    retention: 14

persistence:
  data:
    enabled: true
    size: 10Gi
    mountPath: /app/data
```

### Example 3: High Availability Setup

```yaml
image:
  repository: myapp/backend
  tag: "2.0.0"

replicaCount: 3

service:
  port: 8080

database:
  enabled: true
  mode: cluster
  cluster:
    instances: 3
    name: myapp-db
  persistence:
    size: 50Gi
  backup:
    enabled: true

persistence:
  data:
    enabled: true
    storageClass: fast-ssd
    size: 20Gi

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi
```

## Support

For issues and questions, please open an issue in the repository.

## License

This chart is provided as-is under the project's license.
