# Frigate NVR Helm Chart

This Helm chart deploys Frigate NVR on Kubernetes.

## Installation

```bash
helm install frigate ./frigate
```

## Configuration

See `values.yaml` for configuration options.

## Parameters

### Frigate parameters

| Name                                            | Description                                                                                                                         | Value                               |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `enabled`                                       | Whether to enable Frigate.                                                                                                          | `true`                              |
| `replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                                 |
| `image.repository`                              | The Docker repository to pull the image from.                                                                                       | `ghcr.io/blakeblackshear/frigate`   |
| `image.tag`                                     | The image tag to use.                                                                                                               | `0.14.1`                            |
| `image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                      |
| `image.autoupdate.enabled`                      | Enable automatic image updates via ArgoCD Image Updater.                                                                            | `false`                             |
| `image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                                |
| `image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                                |
| `image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                                |
| `image.autoupdate.pullSecret`                   | Reference to secret for private registry authentication.                                                                            | `""`                                |
| `image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                                |
| `imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                                |
| `deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                          |
| `serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                              |
| `serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                                |
| `serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                                |
| `podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                                |
| `podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                                |
| `securityContext.privileged`                    | Whether to run the container in privileged mode.                                                                                    | `true`                              |
| `initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                                |
| `service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`                      |
| `service.port`                                  | The port on which the service will run.                                                                                             | `5000`                              |
| `service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                                |
| `ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `true`                              |
| `ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                                |
| `ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                                |
| `ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`               |
| `ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                                 |
| `ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`            |
| `ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                                |
| `resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                                |
| `autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                             |
| `autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                                 |
| `autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                               |
| `autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                                |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                                |
| `nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                                |
| `tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                                |
| `affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                                |
| `env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`                     |
| `postgres.enabled`                              | Whether to enable PostgreSQL database for Frigate events (default: true).                                                           | `true`                              |
| `postgres.mode`                                 | The mode of PostgreSQL deployment (only 'cluster' is supported for Frigate).                                                        | `cluster`                           |
| `postgres.initSQL`                              | Array of SQL commands to run on database initialization.                                                                            | `[]`                                |
| `postgres.username`                             | Username for the database.                                                                                                          | `frigate`                           |
| `postgres.database`                             | Database name for PostgreSQL.                                                                                                       | `frigate`                           |
| `postgres.password.secretName`                  | Existing secret name for database password (mutually exclusive with value).                                                         | `""`                                |
| `postgres.password.secretKey`                   | Key in the secret containing the password (default: password).                                                                      | `password`                          |
| `postgres.password.value`                       | Direct password value to create a secret (mutually exclusive with secretName).                                                      | `""`                                |
| `postgres.cluster.instances`                    | Number of PostgreSQL instances (replicas).                                                                                          | `1`                                 |
| `postgres.cluster.persistence.enabled`          | Enable persistence for cluster PostgreSQL.                                                                                          | `true`                              |
| `postgres.cluster.persistence.size`             | Size of the persistence volume.                                                                                                     | `512Mi`                             |
| `postgres.cluster.persistence.storageClass`     | Storage class for persistence.                                                                                                      | `""`                                |
| `postgres.cluster.image.repository`             | PostgreSQL container image repository.                                                                                              | `ghcr.io/cloudnative-pg/postgresql` |
| `postgres.cluster.persistence.enabled`          | Enable persistence for cluster PostgreSQL.                                                                                          | `true`                              |
| `postgres.cluster.persistence.size`             | Size of the persistence volume.                                                                                                     | `512Mi`                             |
| `postgres.cluster.persistence.storageClass`     | Storage class for persistence.                                                                                                      | `""`                                |
| `postgres.cluster.image.tag`                    | PostgreSQL container image tag.                                                                                                     | `16.6`                              |
| `tmpfs.enabled`                                 | Whether to enable tmpfs cache for Frigate.                                                                                          | `true`                              |
| `tmpfs.size`                                    | The size of the tmpfs cache for Frigate.                                                                                            | `1Gi`                               |
| `persistence.config.enabled`                    | Whether to enable persistence for the config.                                                                                       | `true`                              |
| `persistence.config.storageClass`               | The storage class to use for the config.                                                                                            | `ceph-rbd`                          |
| `persistence.config.existingClaim`              | The name of an existing claim to use for the config.                                                                                | `""`                                |
| `persistence.config.accessMode`                 | The access mode to use for the config.                                                                                              | `ReadWriteOnce`                     |
| `persistence.config.size`                       | The size to use for the config.                                                                                                     | `512Mi`                             |
| `persistence.media.enabled`                     | Whether to enable persistence for the media.                                                                                        | `true`                              |
| `persistence.media.storageClass`                | The storage class to use for the media.                                                                                             | `ceph-rbd`                          |
| `persistence.media.existingClaim`               | The name of an existing claim to use for the media.                                                                                 | `""`                                |
| `persistence.media.accessMode`                  | The access mode to use for the media.                                                                                               | `ReadWriteOnce`                     |
| `persistence.media.size`                        | The size to use for the media.                                                                                                      | `512Mi`                             |
| `persistence.backup.enabled`                    | Whether to enable backup persistence.                                                                                               | `true`                              |
| `persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                    | `cephfs`                            |
| `persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                        | `""`                                |
| `persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                      | `ReadWriteMany`                     |
| `persistence.backup.size`                       | The size to use for backup persistence.                                                                                             | `512Mi`                             |
| `persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                                |
| `persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                                |

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

