# postgres

Reusable PostgreSQL dependency chart. Supports standalone (StatefulSet), cluster (CloudNativePG CRD), and external modes. Includes optional backup (CNPG ScheduledBackup in cluster mode, pg_dump CronJob otherwise) and restore Job.

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
| `backup.enabled`                                   | Enable backup. When mode=cluster, configures barmanObjectStore on the Cluster CRD and creates a CNPG ScheduledBackup CRD. When mode=standalone or mode=external, creates a pg_dump CronJob. | `false`                             |
| `backup.cron`                                      | Cron schedule for backup (default: weekly on Sunday at midnight UTC). Drives CNPG ScheduledBackup in cluster mode, pg_dump CronJob otherwise. | `0 0 * * 0`                         |
| `backup.retentionPolicy`                           | Retention policy for CNPG base backups (cluster mode only, e.g. "30d").                                 | `30d`                               |
| `backup.objectStorage.destinationPath`             | Destination path in the object storage bucket (cluster mode only).                                       | `""`                                |
| `backup.objectStorage.endpointURL`                 | Endpoint URL for the object storage provider (cluster mode only).                                        | `""`                                |
| `backup.objectStorage.secretName`                  | Name of the secret containing object storage credentials (cluster mode only).                            | `""`                                |
| `backup.objectStorage.region`                      | Region of the object storage bucket (cluster mode only).                                                 | `""`                                |
| `backup.retention`                                 | Number of days to retain pg_dump backups (standalone/external mode only).                                | `30`                                |
| `backup.timeout`                                   | Maximum seconds allowed for pg_dump to complete (standalone/external mode only).                         | `300`                               |
| `backup.image.repository`                          | Docker image repository for the pg_dump backup job (standalone/external mode only, defaults to standalone image). | `""`                                |
| `backup.image.tag`                                 | Docker image tag for the pg_dump backup job.                                                             | `""`                                |
| `backup.persistence.enabled`                       | Enable persistent storage for pg_dump backup files (standalone/external mode only).                      | `true`                              |
| `backup.persistence.size`                          | Size of the persistent volume for pg_dump backups.                                                       | `512Mi`                             |
| `backup.persistence.storageClass`                  | Storage class for the pg_dump backup persistent volume.                                                  | `""`                                |
| `backup.persistence.accessMode`                    | Access mode for the pg_dump backup persistent volume.                                                    | `ReadWriteOnce`                     |
| `backup.persistence.existingClaim`                 | Name of an existing PVC for pg_dump backups.                                                             | `""`                                |
| `restore.enabled`                                  | Enable restore. In cluster mode, configures CNPG recovery bootstrap. Otherwise runs a pg_dump restore Job (Helm pre-install/pre-upgrade hook). | `false`                             |
| `restore.name`                                     | Backup to restore. In cluster mode, the name of the CNPG Backup resource (required). In standalone/external mode, a backup filename; empty means latest. | `""`                                |
| `nodeSelector`                                     | Node selector for standalone StatefulSet, backup CronJob, and restore Job pods.                          | `{}`                                |
| `tolerations`                                      | Tolerations for standalone StatefulSet, backup CronJob, and restore Job pods.                            | `[]`                                |
| `affinity`                                         | Affinity rules for standalone StatefulSet, backup CronJob, and restore Job pods.                         | `{}`                                |
