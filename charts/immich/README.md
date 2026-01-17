# Immich Helm Chart

This Helm chart deploys Immich, a high performance self-hosted photo and video management solution.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- CloudNativePG operator must be installed in the cluster (for database management)

## Installing the CloudNativePG Operator

If you don't have the CloudNativePG operator installed:

```bash
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
```

## Installation

```bash
helm install immich ./immich
```

## Configuration

See `values.yaml` for configuration options.

### Database Configuration

This chart uses CloudNativePG to deploy a PostgreSQL database with the vectorchord extension required by Immich. The database is automatically configured with the necessary extensions.

Key database configuration options:
- `database.enabled`: Enable/disable the CloudNativePG database (default: true)
- `database.instances`: Number of PostgreSQL replicas (default: 1)
- `database.storage.size`: Storage size for the database (default: 10Gi)
- `database.image.repository`: PostgreSQL image with vectorchord extension

If you want to use an external database, set `database.enabled: false` and configure the database connection via the `env` section.

### Storage

You need to configure persistent storage for Immich's library:
- `persistence.library.enabled`: Enable persistent storage (default: true)
- `persistence.library.size`: Storage size (default: 10Gi)
- `persistence.library.existingClaim`: Use an existing PVC (optional)

## Parameters

### Immich parameters

| Name                                            | Description                                                                                                                         | Value                                         |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `enabled`                                       | Whether to enable Immich.                                                                                                           | `true`                                        |
| `replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                                           |
| `image.repository`                              | The Docker repository to pull the image from.                                                                                       | `ghcr.io/immich-app/immich-server`            |
| `image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                                |
| `image.tag`                                     | The image tag to use.                                                                                                               | `v2.4.1`                                      |
| `imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                                          |
| `deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                                    |
| `serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                                        |
| `serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                                          |
| `serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                                          |
| `podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                                          |
| `podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                                          |
| `securityContext`                               | The security context to use for the container.                                                                                      | `{}`                                          |
| `initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                                          |
| `service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`                                |
| `service.port`                                  | The port on which the service will run.                                                                                             | `2283`                                        |
| `service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                                          |
| `ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `true`                                        |
| `ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                                          |
| `ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                                          |
| `ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`                         |
| `ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                                           |
| `ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`                      |
| `ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                                          |
| `resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                                          |
| `autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                                       |
| `autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                                           |
| `autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                                         |
| `autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                                          |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                                          |
| `nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                                          |
| `tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                                          |
| `affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                                          |
| `env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`                               |
| `env.REDIS_HOSTNAME`                            | The Redis hostname to connect to.                                                                                                   | `immich-redis`                                |
| `database.enabled`                              | Whether to enable PostgreSQL database for Immich.                                                                                   | `true`                                        |
| `database.name`                                 | Name of the database cluster (will be suffixed with release name).                                                                  | `immich-db`                                   |
| `database.instances`                            | Number of PostgreSQL instances (replicas).                                                                                          | `1`                                           |
| `database.image.repository`                     | PostgreSQL container image repository with vectorchord extension.                                                                   | `ghcr.io/tensorchord/cloudnative-vectorchord` |
| `database.image.tag`                            | PostgreSQL container image tag.                                                                                                     | `16.9-0.4.3`                                  |
| `database.database`                             | Name of the database to create.                                                                                                     | `immich`                                      |
| `database.owner`                                | Owner of the database.                                                                                                              | `immich`                                      |
| `database.storage.size`                         | Size of the storage for each instance.                                                                                              | `10Gi`                                        |
| `database.storage.storageClass`                 | Storage class name for persistent volumes.                                                                                          | `ceph-rbd`                                    |
| `database.secret.name`                          | Name of the secret containing database credentials.                                                                                 | `""`                                          |
| `database.secret.create`                        | Whether to create the database secret.                                                                                              | `true`                                        |
| `database.secret.username`                      | Database user username.                                                                                                             | `immich`                                      |
| `database.secret.password`                      | Database user password (leave empty to auto-generate).                                                                              | `""`                                          |
| `database.superuserSecret.name`                 | Name of the secret containing the superuser credentials.                                                                            | `""`                                          |
| `database.superuserSecret.create`               | Whether to create the superuser secret.                                                                                             | `true`                                        |
| `database.superuserSecret.username`             | Superuser username.                                                                                                                 | `postgres`                                    |
| `database.superuserSecret.password`             | Superuser password (leave empty to auto-generate).                                                                                  | `""`                                          |
| `persistence.library.enabled`                   | Whether to enable persistence for the library.                                                                                      | `true`                                        |
| `persistence.library.storageClass`              | The storage class to use for the library.                                                                                           | `ceph-rbd`                                    |
| `persistence.library.existingClaim`             | The name of an existing claim to use for the library.                                                                               | `""`                                          |
| `persistence.library.accessMode`                | The access mode to use for the library.                                                                                             | `ReadWriteOnce`                               |
| `persistence.library.size`                      | The size to use for the library.                                                                                                    | `10Gi`                                        |
| `persistence.backup.enabled`                    | Whether to enable backup persistence.                                                                                               | `false`                                       |
| `persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                    | `cephfs`                                      |
| `persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                        | `""`                                          |
| `persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                      | `ReadWriteMany`                               |
| `persistence.backup.size`                       | The size to use for backup persistence.                                                                                             | `10Gi`                                        |
| `persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                                          |
| `persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                                          |

