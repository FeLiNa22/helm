# postgres

Reusable PostgreSQL dependency chart. Supports standalone (StatefulSet), cluster (CloudNativePG CRD), and external modes. Includes optional pg_dump backup CronJob and restore Job.

## Parameters

### PostgreSQL parameters

| Name                                               | Description                                                                                              | Value                               |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `mode`                                             | Deployment mode: 'standalone', 'cluster', or 'external'.                                                 | `standalone`                        |
| `username`                                         | PostgreSQL username.                                                                                     | `postgres`                          |
| `database`                                         | PostgreSQL database name.                                                                                | `postgres`                          |
| `initSQL`                                          | Array of SQL statements to execute after database creation (e.g. CREATE EXTENSION).                      | `[]`                                |
| `password.secretName`                              | Name of an existing secret containing the password (mutually exclusive with value).                      | `""`                                |
| `password.value`                                   | Plain-text password. Creates a Secret when set (mutually exclusive with secretName).                     | `""`                                |
| `standalone.image.repository`                      | Docker image repository for standalone PostgreSQL.                                                       | `postgres`                          |
| `standalone.image.tag`                             | Docker image tag for standalone PostgreSQL.                                                              | `16-alpine`                         |
| `standalone.resources`                             | Resource requests/limits for standalone PostgreSQL.                                                      | `{}`                                |
| `standalone.persistence.enabled`                   | Enable persistent storage for standalone PostgreSQL.                                                     | `true`                              |
| `standalone.persistence.size`                      | Size of the persistent volume.                                                                           | `512Mi`                             |
| `standalone.persistence.storageClass`              | Storage class for the persistent volume.                                                                 | `""`                                |
| `standalone.persistence.existingClaim`             | Name of an existing PVC to use for standalone PostgreSQL.                                                | `""`                                |
| `cluster.instances`                                | Number of PostgreSQL instances in the CloudNativePG cluster.                                             | `2`                                 |
| `cluster.image.repository`                         | Docker image repository for CloudNativePG cluster.                                                       | `ghcr.io/cloudnative-pg/postgresql` |
| `cluster.image.tag`                                | Docker image tag for CloudNativePG cluster.                                                              | `16`                                |
| `cluster.persistence.size`                         | Size of the persistent volume for each cluster instance.                                                 | `512Mi`                             |
| `cluster.persistence.storageClass`                 | Storage class for the persistent volume.                                                                 | `""`                                |
| `cluster.persistence.existingClaim`                | Name of an existing PVC to use (not applicable for CNPG clusters).                                       | `""`                                |
| `cluster.postgresql.parameters`                    | Map of PostgreSQL configuration parameters (merged into the CNPG Cluster postgresql.parameters section). | `{}`                                |
| `cluster.pitrBackup.enabled`                       | Enable Point-in-Time Recovery backups for the CNPG cluster.                                              | `false`                             |
| `cluster.pitrBackup.retentionPolicy`               | Retention policy for PITR backups (e.g. "30d").                                                          | `30d`                               |
| `cluster.pitrBackup.objectStorage.destinationPath` | Destination path in the object storage bucket.                                                           | `""`                                |
| `cluster.pitrBackup.objectStorage.endpointURL`     | Endpoint URL for the object storage provider.                                                            | `""`                                |
| `cluster.pitrBackup.objectStorage.secretName`      | Name of the secret containing object storage credentials.                                                | `""`                                |
| `cluster.pitrBackup.objectStorage.region`          | Region of the object storage bucket.                                                                     | `""`                                |
| `external.host`                                    | Hostname of the external PostgreSQL instance.                                                            | `""`                                |
| `external.port`                                    | Port of the external PostgreSQL instance.                                                                | `5432`                              |
| `backup.enabled`                                   | Enable pg_dump CronJob backup.                                                                           | `false`                             |
| `backup.cron`                                      | Cron schedule for pg_dump backup (default: daily at 2am).                                                | `0 2 * * *`                         |
| `backup.retention`                                 | Number of days to retain backups.                                                                        | `30`                                |
| `backup.timeout`                                   | Maximum seconds allowed for pg_dump to complete.                                                         | `300`                               |
| `backup.image.repository`                          | Docker image repository for the backup job (defaults to standalone image).                               | `""`                                |
| `backup.image.tag`                                 | Docker image tag for the backup job.                                                                     | `""`                                |
| `backup.persistence.enabled`                       | Enable persistent storage for backup files.                                                              | `true`                              |
| `backup.persistence.size`                          | Size of the persistent volume for backups.                                                               | `512Mi`                             |
| `backup.persistence.storageClass`                  | Storage class for the backup persistent volume.                                                          | `""`                                |
| `backup.persistence.accessMode`                    | Access mode for the backup persistent volume.                                                            | `ReadWriteOnce`                     |
| `backup.persistence.existingClaim`                 | Name of an existing PVC for backups.                                                                     | `""`                                |
| `restore.enabled`                                  | Enable one-shot restore Job (Helm pre-install/pre-upgrade hook).                                         | `false`                             |
| `restore.name`                                     | Specific backup filename to restore. When empty, uses the latest valid backup.                           | `""`                                |
| `nodeSelector`                                     | Node selector for standalone StatefulSet, backup CronJob, and restore Job pods.                          | `{}`                                |
| `tolerations`                                      | Tolerations for standalone StatefulSet, backup CronJob, and restore Job pods.                            | `[]`                                |
| `affinity`                                         | Affinity rules for standalone StatefulSet, backup CronJob, and restore Job pods.                         | `{}`                                |
