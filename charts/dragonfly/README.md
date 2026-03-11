# dragonfly

Reusable DragonflyDB dependency chart. Supports standalone (Deployment + optional PVC), cluster (DragonflyDB operator CRD), and external modes.

## Parameters

### DragonflyDB parameters

| Name                                  | Description                                              | Value                                         |
| ------------------------------------- | -------------------------------------------------------- | --------------------------------------------- |
| `mode`                                | Deployment mode: 'standalone', 'cluster', or 'external'. | `standalone`                                  |
| `username`                            | Username for DragonflyDB authentication.                 | `default`                                     |
| `password.secretName`                 | Name of an existing secret containing the password.      | `""`                                          |
| `password.secretKey`                  | Key in the secret that holds the password.               | `password`                                    |
| `password.value`                      | Plain-text password. Creates a Secret when set.          | `""`                                          |
| `standalone.image.repository`         | Docker image repository for standalone DragonflyDB.      | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `standalone.image.tag`                | Docker image tag for standalone DragonflyDB.             | `v1.36.0`                                     |
| `standalone.resources.limits.memory`  | Memory limit for standalone DragonflyDB.                 | `512Mi`                                       |
| `standalone.persistence.enabled`      | Enable persistent storage for standalone DragonflyDB.    | `true`                                        |
| `standalone.persistence.size`         | Size of the persistent volume.                           | `512Mi`                                       |
| `standalone.persistence.storageClass` | Storage class for the persistent volume.                 | `""`                                          |
| `standalone.persistence.accessMode`   | Access mode for the persistent volume.                   | `ReadWriteOnce`                               |
| `cluster.replicas`                    | Number of replicas in the DragonflyDB cluster.           | `2`                                           |
| `cluster.image.repository`            | Docker image repository for DragonflyDB cluster.         | `docker.dragonflydb.io/dragonflydb/dragonfly` |
| `cluster.image.tag`                   | Docker image tag for DragonflyDB cluster.                | `v1.36.0`                                     |
| `cluster.resources.limits.memory`     | Memory limit for cluster DragonflyDB instances.          | `512Mi`                                       |
| `cluster.persistence.enabled`         | Enable persistent storage for cluster DragonflyDB.       | `true`                                        |
| `cluster.persistence.size`            | Size of the persistent volume for each cluster replica.  | `512Mi`                                       |
| `cluster.persistence.storageClass`    | Storage class for the persistent volume.                 | `""`                                          |
| `cluster.persistence.accessMode`      | Access mode for the persistent volume.                   | `ReadWriteOnce`                               |
| `cluster.snapshot.cron`               | Cron schedule for DragonflyDB cluster snapshots.         | `*/5 * * * *`                                 |
| `external.host`                       | Hostname of the external DragonflyDB/Redis instance.     | `""`                                          |
| `external.port`                       | Port of the external DragonflyDB/Redis instance.         | `6379`                                        |
| `nodeSelector`                        | Node selector for DragonflyDB pods.                      | `{}`                                          |
| `tolerations`                         | Tolerations for DragonflyDB pods.                        | `[]`                                          |
| `affinity`                            | Affinity rules for DragonflyDB pods.                     | `{}`                                          |
