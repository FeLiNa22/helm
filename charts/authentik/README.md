# Authentik Helm Chart

This Helm chart deploys [authentik](https://goauthentik.io/), an open-source Identity Provider focused on flexibility and versatility. It supports SAML, OAuth, OIDC, LDAP, and more.

## Features

- **Server and Worker Deployments**: Separate server and worker components for optimal performance
- **Multiple Database Modes**:
  - **Standalone**: Single PostgreSQL instance using StatefulSet
  - **Cluster**: High-availability PostgreSQL using CloudNativePG operator
  - **External**: Connect to an existing external database
- **Automated Backups**: pg_dump-based database backups with configurable retention
- **Velero Integration**: Full application backup schedules
- **ArgoCD Image Updater**: Automated image updates via GitOps
- **Horizontal Pod Autoscaling**: Scale server and worker pods based on resource utilization
- **Persistent Storage**: Configurable PVCs for media files and databases

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistent storage)

### Optional:
- **CloudNativePG Operator** (for cluster database mode)
- **Velero** (for backup schedules)
- **ArgoCD** (for automated image updates)

## RBAC Permissions

This chart creates RBAC (Role-Based Access Control) resources to enable authentik to deploy and manage Kubernetes outposts. 

### Namespace-scoped permissions (Role)
The service account is granted permissions to manage the following resources within the namespace:

- **Secrets**: For outpost configuration and credentials
- **Services**: For outpost service exposure
- **ConfigMaps**: For outpost configuration
- **Deployments**: For outpost pod management
- **ReplicaSets**: For deployment management
- **Pods**: For outpost status monitoring

### Cluster-scoped permissions (ClusterRole)
The service account is granted read-only permissions for the following cluster-scoped resources:

- **CustomResourceDefinitions**: To check if ServiceMonitor CRDs exist for monitoring integration

RBAC can be disabled if you don't plan to use Kubernetes outposts:

```yaml
rbac:
  create: false
```

**Note**: If you disable RBAC, authentik will not be able to deploy Kubernetes outposts and will return 403 Forbidden errors when attempting to do so.

## Installation

### Basic Installation (Standalone Mode)

```bash
helm install authentik ./authentik
```

This deploys authentik with:
- Standalone PostgreSQL database
- EmptyDir storage for media files (ephemeral)
- Default configuration

### Custom Installation

```bash
helm install authentik ./authentik \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=authentik.example.com \
  --set postgres.mode=cluster \
  --set postgres.cluster.instances=3
```

## Configuration

### Database Modes

#### Standalone Mode (Default)
Deploys a single PostgreSQL instance using a StatefulSet:

```yaml
postgres:
  mode: standalone
  database: authentik
  username: authentik
  # SQL commands to initialize database (optional)
  initSQL:
    - "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    - "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
  # Password configuration - provide EITHER value OR secretName
  password:
    value: ""  # Direct password value (leave empty to be prompted)
    secretName: ""  # OR use existing secret
  standalone:
    image:
      repository: postgres
      tag: "16-alpine"
    resources: {}
    persistence:
      enabled: true
      size: 5Gi
      storageClass: ""
      existingClaim: ""
```

#### Cluster Mode (High Availability)
Requires CloudNativePG operator. Deploys a PostgreSQL cluster:

```yaml
postgres:
  mode: cluster
  database: authentik
  username: authentik
  # SQL commands to initialize database (optional)
  initSQL:
    - "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
  # For cluster mode, existing secrets MUST contain both 'username' and 'password' keys
  # and use type: kubernetes.io/basic-auth (or Opaque)
  password:
    value: ""  # Direct password value (creates kubernetes.io/basic-auth secret)
    secretName: ""  # OR use existing secret
  cluster:
    instances: 3  # Number of replicas
    # Enable read replicas for load distribution (default: true)
    # When enabled, authentik will use the CNPG read-only service endpoint for read operations
    readReplicas:
      enabled: true
    image:
      repository: ghcr.io/cloudnative-pg/postgresql
      tag: "16"
    persistence:
      enabled: true
      size: 5Gi
      storageClass: ""
    pitrBackup:
      enabled: true
      retentionPolicy: "30d"
      objectStorage:
        destinationPath: "s3://my-bucket/authentik-backups"
        endpointURL: "https://s3.amazonaws.com"
        secretName: "s3-credentials"  # Must contain ACCESS_KEY_ID and ACCESS_SECRET_KEY
        region: "us-east-1"
```

**Read Replicas in Cluster Mode:**

When using cluster mode with `postgres.cluster.readReplicas.enabled: true` (default), authentik is configured to use CloudNativePG's read-only service endpoint (`<cluster-name>-ro`) for read operations. This distributes read queries across replica instances, improving performance and reducing load on the primary database.

The chart automatically configures the following environment variables:
- `AUTHENTIK_POSTGRESQL__READ_REPLICAS__0__HOST`: Points to the CNPG read-only service
- `AUTHENTIK_POSTGRESQL__READ_REPLICAS__0__PORT`: Database port (5432)
- `AUTHENTIK_POSTGRESQL__READ_REPLICAS__0__NAME`: Database name
- `AUTHENTIK_POSTGRESQL__READ_REPLICAS__0__USER`: Database username
- `AUTHENTIK_POSTGRESQL__READ_REPLICAS__0__PASSWORD`: Database password (from secret)

To disable read replicas (all queries go to primary):
```yaml
postgres:
  mode: cluster
  cluster:
    readReplicas:
      enabled: false
```

#### External Mode
Connect to an existing database:

```yaml
postgres:
  mode: external
  database: authentik
  username: authentik
  password:
    value: "your-password"  # Direct password value
    secretName: ""  # OR use existing secret
  external:
    host: "postgres.example.com"
    port: 5432
```

### Database Backups

The chart supports scheduled pg_dump backups for all database modes:

```yaml
postgres:
  backup:
    enabled: true
    cron: "0 2 * * *"  # Daily at 2am
    retention: 30  # Number of backups to retain
    image:
      repository: ""  # Optional: custom backup image
      tag: ""
    persistence:
      enabled: true
      size: 512Mi
      storageClass: ""
      accessMode: ReadWriteOnce
      existingClaim: ""
```

### Ingress Configuration

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: authentik.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: authentik-tls
      hosts:
        - authentik.example.com
```

### Authentik Configuration

#### Secret Key (Required)

The `authentik.secretKey` is a required parameter used for cookie signing and unique user IDs. It must be provided and should never be left empty.

**Important**: This secret key should be:
- Generated once and stored securely
- Never changed after initial deployment (will invalidate user sessions)
- At least 50 characters long for security
- Kept secret and not committed to version control

Example generation using OpenSSL:
```bash
openssl rand -base64 60
```

Configuration:
```yaml
authentik:
  secretKey: "your-generated-secret-key-here"  # REQUIRED - must be provided
```

### Email Configuration

```yaml
authentik:
  email:
    host: "smtp.gmail.com"
    port: 587
    username: "your-email@gmail.com"
    password: "your-app-password"
    useTLS: true
    useSSL: false
    from: "authentik@example.com"
```

### Automated Backups

#### Database Backups (pg_dump)
```yaml
postgres:
  backup:
    enabled: true
    cron: "0 2 * * *"  # Daily at 2 AM
    retention: 30  # Keep last 30 backups
    persistence:
      enabled: true
      size: 512Mi
```

#### Velero Backup Schedules
```yaml
velero:
  enabled: true
  namespace: "velero"
  schedule: "0 3 * * *"  # Daily at 3 AM
  ttl: "168h"  # 7 days retention
  snapshotVolumes: true
```

### High Availability

```yaml
# Server autoscaling
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

# Worker autoscaling
worker:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5
    targetCPUUtilizationPercentage: 80

# Database cluster
postgres:
  mode: cluster
  cluster:
    instances: 3
```

### Resource Limits

```yaml
resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi

worker:
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 250m
      memory: 512Mi
```

## Parameters

### Authentik Server parameters

| Name                                         | Description                                                                            | Value                        |
| -------------------------------------------- | -------------------------------------------------------------------------------------- | ---------------------------- |
| `replicaCount`                               | The number of replicas to deploy for the server.                                       | `1`                          |
| `image.repository`                           | The Docker repository to pull the image from.                                          | `ghcr.io/goauthentik/server` |
| `image.pullPolicy`                           | The logic of image pulling.                                                            | `IfNotPresent`               |
| `image.tag`                                  | The image tag to use.                                                                  | `2025.12.4`                  |
| `image.autoupdate.enabled`                   | Enable automatic image updates via ArgoCD Image Updater.                               | `false`                      |
| `image.autoupdate.strategy`                  | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest). | `""`                         |
| `image.autoupdate.allowTags`                 | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").  | `""`                         |
| `image.autoupdate.ignoreTags`                | List of glob patterns to ignore specific tags.                                         | `[]`                         |
| `image.autoupdate.pullSecret`                | Reference to secret for private registry authentication.                               | `""`                         |
| `image.autoupdate.platforms`                 | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                       | `[]`                         |
| `imagePullSecrets`                           | The image pull secrets to use.                                                         | `[]`                         |
| `deployment.strategy.type`                   | The deployment strategy to use.                                                        | `Recreate`                   |
| `serviceAccount.create`                      | Whether to create a service account.                                                   | `true`                       |
| `serviceAccount.annotations`                 | Additional annotations to add to the service account.                                  | `{}`                         |
| `serviceAccount.name`                        | The name of the service account to use.                                                | `""`                         |
| `podAnnotations`                             | Additional annotations to add to the pod.                                              | `{}`                         |
| `podSecurityContext`                         | The security context to use for the pod.                                               | `{}`                         |
| `securityContext`                            | The security context to use for the container.                                         | `{}`                         |
| `initContainers`                             | Additional init containers to add to the pod.                                          | `[]`                         |
| `service.type`                               | The type of service to create.                                                         | `ClusterIP`                  |
| `service.port`                               | The port on which the service will run.                                                | `9000`                       |
| `service.httpsPort`                          | The HTTPS port on which the service will run.                                          | `9443`                       |
| `service.nodePort`                           | The nodePort to use for the service. Only used if service.type is NodePort.            | `""`                         |
| `ingress.enabled`                            | Whether to create an ingress for the service.                                          | `false`                      |
| `ingress.className`                          | The ingress class name to use.                                                         | `""`                         |
| `ingress.annotations`                        | Additional annotations to add to the ingress.                                          | `{}`                         |
| `ingress.hosts[0].host`                      | The host to use for the ingress.                                                       | `authentik.local`            |
| `ingress.hosts[0].paths[0].path`             | The path to use for the ingress.                                                       | `/`                          |
| `ingress.hosts[0].paths[0].pathType`         | The path type to use for the ingress.                                                  | `Prefix`                     |
| `ingress.tls`                                | The TLS configuration for the ingress.                                                 | `[]`                         |
| `resources`                                  | The resources to use for the pod.                                                      | `{}`                         |
| `autoscaling.enabled`                        | Whether to enable autoscaling.                                                         | `false`                      |
| `autoscaling.minReplicas`                    | The minimum number of replicas to scale to.                                            | `1`                          |
| `autoscaling.maxReplicas`                    | The maximum number of replicas to scale to.                                            | `5`                          |
| `autoscaling.targetCPUUtilizationPercentage` | The target CPU utilization percentage to use for autoscaling.                          | `80`                         |
| `nodeSelector`                               | The node selector to use for the pod.                                                  | `{}`                         |
| `tolerations`                                | The tolerations to use for the pod.                                                    | `[]`                         |
| `affinity`                                   | The affinity to use for the pod.                                                       | `{}`                         |
| `rbac.create`                                | Whether to create RBAC resources for outpost deployment.                               | `true`                       |

### Authentik Worker parameters

| Name                                                | Description                                                   | Value   |
| --------------------------------------------------- | ------------------------------------------------------------- | ------- |
| `worker.enabled`                                    | Enable the worker deployment.                                 | `true`  |
| `worker.replicaCount`                               | The number of replicas to deploy for the worker.              | `1`     |
| `worker.resources`                                  | The resources to use for the worker pod.                      | `{}`    |
| `worker.autoscaling.enabled`                        | Whether to enable autoscaling for the worker.                 | `false` |
| `worker.autoscaling.minReplicas`                    | The minimum number of replicas to scale to.                   | `1`     |
| `worker.autoscaling.maxReplicas`                    | The maximum number of replicas to scale to.                   | `5`     |
| `worker.autoscaling.targetCPUUtilizationPercentage` | The target CPU utilization percentage to use for autoscaling. | `80`    |
| `worker.nodeSelector`                               | The node selector to use for the worker pod.                  | `{}`    |
| `worker.tolerations`                                | The tolerations to use for the worker pod.                    | `[]`    |
| `worker.affinity`                                   | The affinity to use for the worker pod.                       | `{}`    |

### Environment Variables

| Name     | Description                   | Value           |
| -------- | ----------------------------- | --------------- |
| `env.TZ` | Timezone for the application. | `Europe/London` |

### Authentik Configuration

| Name                               | Description                                                                                   | Value   |
| ---------------------------------- | --------------------------------------------------------------------------------------------- | ------- |
| `authentik.secretKey`              | Secret key used for cookie signing and unique user IDs. Must be provided - never leave empty. | `""`    |
| `authentik.errorReporting.enabled` | Enable anonymous error reporting to sentry.                                                   | `false` |
| `authentik.logLevel`               | Log level (debug, info, warning, error, critical).                                            | `info`  |
| `authentik.email.host`             | SMTP server hostname.                                                                         | `""`    |
| `authentik.email.port`             | SMTP server port.                                                                             | `587`   |
| `authentik.email.username`         | SMTP username.                                                                                | `""`    |
| `authentik.email.password`         | SMTP password.                                                                                | `""`    |
| `authentik.email.useTLS`           | Use STARTTLS for SMTP.                                                                        | `false` |
| `authentik.email.useSSL`           | Use SSL for SMTP.                                                                             | `false` |
| `authentik.email.timeout`          | SMTP connection timeout.                                                                      | `30`    |
| `authentik.email.from`             | Email from address.                                                                           | `""`    |

### Persistence Configuration

| Name                            | Description                                  | Value           |
| ------------------------------- | -------------------------------------------- | --------------- |
| `persistence.enabled`           | Enable persistence for data files.           | `false`         |
| `persistence.storageClass`      | Storage class for the PVC.                   | `""`            |
| `persistence.size`              | Size of the PVC.                             | `512Mi`         |
| `persistence.accessMode`        | Access mode for the PVC.                     | `ReadWriteMany` |
| `persistence.existingClaim`     | Use an existing PVC instead of creating one. | `""`            |
| `persistence.additionalVolumes` | Additional volumes to mount.                 | `[]`            |
| `persistence.additionalMounts`  | Additional mount paths for volumes.          | `[]`            |

### PostgreSQL Configuration

| Name                                                        | Description                                                                                                                     | Value                               |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `postgres.enabled`                                          | Enable the postgres subchart.                                                                                                   | `true`                              |
| `postgres.mode`                                             | Database deployment mode: 'standalone', 'cluster', or 'external'.                                                               | `standalone`                        |
| `postgres.initSQL`                                          | Array of SQL commands to run on database initialization.                                                                        | `[]`                                |
| `postgres.database`                                         | Database name.                                                                                                                  | `authentik`                         |
| `postgres.username`                                         | Database username.                                                                                                              | `authentik`                         |
| `postgres.password.secretName`                              | Existing secret name for database password (mutually exclusive with value).                                                     | `""`                                |
| `postgres.password.value`                                   | Direct password value to create a secret (mutually exclusive with secretName).                                                  | `""`                                |
| `postgres.standalone.persistence.enabled`                   | Enable persistence for standalone database.                                                                                     | `true`                              |
| `postgres.standalone.persistence.storageClass`              | Storage class for standalone database PVC.                                                                                      | `""`                                |
| `postgres.standalone.persistence.size`                      | Size of the standalone database PVC.                                                                                            | `512Mi`                             |
| `postgres.standalone.persistence.existingClaim`             | Use an existing PVC for standalone database.                                                                                    | `""`                                |
| `postgres.standalone.image.repository`                      | PostgreSQL image repository for standalone mode.                                                                                | `postgres`                          |
| `postgres.standalone.image.tag`                             | PostgreSQL image tag for standalone mode.                                                                                       | `16-alpine`                         |
| `postgres.standalone.image.autoupdate.enabled`              | Enable automatic image updates for standalone PostgreSQL.                                                                       | `false`                             |
| `postgres.standalone.image.autoupdate.updateStrategy`       | Strategy for image updates for standalone PostgreSQL.                                                                           | `""`                                |
| `postgres.standalone.resources`                             | Resource limits for standalone database.                                                                                        | `{}`                                |
| `postgres.cluster.instances`                                | Number of instances in the cluster.                                                                                             | `2`                                 |
| `postgres.cluster.readReplicas.enabled`                     | Enable read replicas configuration for authentik (uses CNPG read-only service).                                                 | `true`                              |
| `postgres.cluster.persistence.enabled`                      | Enable persistence for cluster database.                                                                                        | `true`                              |
| `postgres.cluster.persistence.storageClass`                 | Storage class for cluster database PVC.                                                                                         | `""`                                |
| `postgres.cluster.persistence.size`                         | Size of the cluster database PVC.                                                                                               | `512Mi`                             |
| `postgres.cluster.image.repository`                         | PostgreSQL image repository for cluster mode.                                                                                   | `ghcr.io/cloudnative-pg/postgresql` |
| `postgres.cluster.image.tag`                                | PostgreSQL image tag for cluster mode.                                                                                          | `16`                                |
| `postgres.cluster.pitrBackup.enabled`                       | Enable point-in-time recovery backups.                                                                                          | `false`                             |
| `postgres.cluster.pitrBackup.retentionPolicy`               | Retention policy for PITR backups.                                                                                              | `30d`                               |
| `postgres.cluster.pitrBackup.objectStorage.destinationPath` | S3 path for backups.                                                                                                            | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.endpointURL`     | S3 endpoint URL.                                                                                                                | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.secretName`      | Secret containing S3 credentials.                                                                                               | `""`                                |
| `postgres.cluster.pitrBackup.objectStorage.region`          | S3 region.                                                                                                                      | `""`                                |
| `postgres.external.host`                                    | External database hostname.                                                                                                     | `""`                                |
| `postgres.external.port`                                    | External database port.                                                                                                         | `5432`                              |
| `postgres.backup.enabled`                                   | Enable scheduled pg_dump backups.                                                                                               | `false`                             |
| `postgres.backup.cron`                                      | Cron schedule for backups.                                                                                                      | `0 2 * * *`                         |
| `postgres.backup.retention`                                 | Number of backups to retain.                                                                                                    | `30`                                |
| `postgres.backup.image.repository`                          | Custom image repository for backup job (optional).                                                                              | `""`                                |
| `postgres.backup.image.tag`                                 | Custom image tag for backup job (optional).                                                                                     | `""`                                |
| `postgres.backup.persistence.enabled`                       | Enable persistence for backups.                                                                                                 | `true`                              |
| `postgres.backup.persistence.size`                          | Size of the backup PVC.                                                                                                         | `512Mi`                             |
| `postgres.backup.persistence.storageClass`                  | Storage class for backup PVC.                                                                                                   | `""`                                |
| `postgres.backup.persistence.accessMode`                    | Access mode for backup PVC.                                                                                                     | `ReadWriteOnce`                     |
| `postgres.backup.persistence.existingClaim`                 | Use an existing PVC for backups.                                                                                                | `""`                                |
| `postgres.restore.enabled`                                  | Restore the latest pg_dump backup on pre-install/pre-upgrade (default: false).                                                  | `false`                             |
| `postgres.restore.name`                                     | Optional backup filename to restore (e.g. authentik_backup_20240101_120000.sql.gz). If empty, restores the latest valid backup. | `""`                                |

### Velero Backup Configuration

| Name                              | Description                                 | Value       |
| --------------------------------- | ------------------------------------------- | ----------- |
| `velero.enabled`                  | Enable Velero backup schedules.             | `false`     |
| `velero.namespace`                | Namespace where Velero is installed.        | `velero`    |
| `velero.schedule`                 | Cron schedule for backups.                  | `0 2 * * *` |
| `velero.ttl`                      | Time to live for backups.                   | `168h`      |
| `velero.includeClusterResources`  | Include cluster-scoped resources.           | `false`     |
| `velero.snapshotVolumes`          | Enable volume snapshots.                    | `true`      |
| `velero.defaultVolumesToFsBackup` | Use filesystem backup instead of snapshots. | `false`     |
| `velero.storageLocation`          | Backup storage location.                    | `""`        |
| `velero.volumeSnapshotLocations`  | Volume snapshot locations.                  | `[]`        |
| `velero.labelSelector`            | Label selector for resources to backup.     | `{}`        |
| `velero.annotations`              | Additional annotations for the schedule.    | `{}`        |

### ArgoCD Image Updater Configuration

| Name                           | Description                          | Value    |
| ------------------------------ | ------------------------------------ | -------- |
| `imageUpdater.namespace`       | Namespace for ArgoCD Image Updater.  | `argocd` |
| `imageUpdater.argocdNamespace` | Namespace where ArgoCD is installed. | `argocd` |
| `imageUpdater.applicationName` | Name of the ArgoCD application.      | `""`     |
| `imageUpdater.imageAlias`      | Alias for the image.                 | `""`     |
| `imageUpdater.forceUpdate`     | Force update the image.              | `false`  |
| `imageUpdater.helm`            | Helm-specific configuration.         | `{}`     |
| `imageUpdater.kustomize`       | Kustomize-specific configuration.    | `{}`     |
| `imageUpdater.writeBackConfig` | Write-back configuration.            | `{}`     |

### Blueprints Configuration

| Name                    | Description                               | Value |
| ----------------------- | ----------------------------------------- | ----- |
| `blueprints.configMaps` | List of ConfigMaps containing blueprints. | `[]`  |
| `blueprints.secrets`    | List of Secrets containing blueprints.    | `[]`  |

## Upgrading

### To upgrade the chart:

```bash
helm upgrade authentik ./authentik
```

### Migration from upstream chart

If migrating from the official authentik Helm chart:

1. Export your current values:
   ```bash
   helm get values authentik > old-values.yaml
   ```

2. Map the values to this chart's structure (main differences):
   - Database configuration is under `postgres.*` instead of `postgresql.*`
   - Environment variables use map format instead of array

3. Backup your database before migrating

4. Install this chart with migrated values

## Uninstalling

```bash
helm uninstall authentik
```

This removes all Kubernetes components associated with the chart, except for PVCs (persistent storage). To delete those:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=authentik
```

## Troubleshooting

### Database connection issues

Check database status:
```bash
# Standalone mode
kubectl get statefulset authentik-postgresql
kubectl logs -l app.kubernetes.io/component=database

# Cluster mode
kubectl get cluster
kubectl cnpg status <release-name>
```

### Worker not processing tasks

Check worker logs:
```bash
kubectl logs -l app.kubernetes.io/component=worker
```

### Check authentik configuration

View the current configuration:
```bash
kubectl exec -it deployment/authentik-server -- ak dump_config
```

## Support

- Documentation: https://goauthentik.io/docs/
- GitHub: https://github.com/goauthentik/authentik
- Community: https://github.com/goauthentik/authentik/discussions
