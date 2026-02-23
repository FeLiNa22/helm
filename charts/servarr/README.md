# Servarr

A Helm chart for deploying the Servarr suite of applications - including Sonarr, Radarr, Lidarr, Prowlarr, and Jellyfin. These applications provide media management, automation, and streaming capabilities for TV shows, movies, music, books, and more. The chart also supports enabling additional services like Bazarr for subtitle management, FlareSolverr for handling anti-bot protections, Seerr for media requests, qBittorrent for downloading, and other complementary applications to create a complete media server stack.

## TL;DR

```console
helm repo add raulpatel https://charts.raulpatel.com
helm install servarr raulpatel/servarr
```

## Introduction

This chart helps you create a media server stack for your home media library, including TV shows, movies, music, books, and more.

## Prerequisites

- Kubernetes 1.12+
- Helm 3.2.0+
- **CloudNativePG Operator** (required only when using `database.mode=cluster`): The CloudNativePG operator must be installed in the cluster before deploying services with `database.mode=cluster`. See [CloudNativePG documentation](https://cloudnative-pg.io/documentation/) for installation instructions.

## Installing the Chart

To install the chart with the release name `servarr`:

```console
helm install servarr raulpatel/servarr
```

The command deploys servarr on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `servarr` deployment:

```console
helm delete servarr
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Media parameters

| Name                    | Description                                                                            | Value           |
| ----------------------- | -------------------------------------------------------------------------------------- | --------------- |
| `media.enabled`         | Whether to enable media storage                                                        | `true`          |
| `media.storageClass`    | The storage class to use for the config.                                               | `""`            |
| `media.existingClaim`   | The name of an existing claim to use for the config.                                   | `""`            |
| `media.accessMode`      | The access mode to use for the config.                                                 | `ReadWriteMany` |
| `media.size`            | The size to use for the config.                                                        | `512Mi`         |
| `media.labels`          | Additional labels to add to the config.                                                | `{}`            |
| `media.annotations`     | Additional annotations to add to the config.                                           | `{}`            |
| `media.paths.tv`        | The subpath for TV shows within the media PVC. Don't use leading or trailing slashes.  | `tv`            |
| `media.paths.movies`    | The subpath for movies within the media PVC. Don't use leading or trailing slashes.    | `movies`        |
| `media.paths.music`     | The subpath for music within the media PVC. Don't use leading or trailing slashes.     | `music`         |
| `media.paths.downloads` | The subpath for downloads within the media PVC. Don't use leading or trailing slashes. | `downloads`     |

### Velero Backup Schedule parameters

| Name                              | Description                                                                               | Value       |
| --------------------------------- | ----------------------------------------------------------------------------------------- | ----------- |
| `velero.enabled`                  | Whether to enable Velero backup schedules for all services                                | `false`     |
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

### Jellyfin parameters

| Name                                              | Description                                                                                                                                                                                                        | Value                          |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------ |
| `jellyfin.enabled`                                | Whether to enable Jellyfin.                                                                                                                                                                                        | `true`                         |
| `jellyfin.replicaCount`                           | The number of replicas to deploy.                                                                                                                                                                                  | `1`                            |
| `jellyfin.image.repository`                       | The Docker repository to pull the image from.                                                                                                                                                                      | `lscr.io/linuxserver/jellyfin` |
| `jellyfin.image.tag`                              | The image tag to use.                                                                                                                                                                                              | `10.11.5`                      |
| `jellyfin.image.pullPolicy`                       | The logic of image pulling.                                                                                                                                                                                        | `IfNotPresent`                 |
| `jellyfin.image.autoupdate.enabled`               | Whether to enable autoupdate for this service's image.                                                                                                                                                             | `false`                        |
| `jellyfin.image.autoupdate.strategy`              | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                                                                                                             | `""`                           |
| `jellyfin.image.autoupdate.allowTags`             | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                                                                                                              | `""`                           |
| `jellyfin.image.autoupdate.ignoreTags`            | List of glob patterns to ignore specific tags.                                                                                                                                                                     | `[]`                           |
| `jellyfin.image.autoupdate.pullSecret`            | Pull secret name for private registries.                                                                                                                                                                           | `""`                           |
| `jellyfin.image.autoupdate.platforms`             | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                                                                                                   | `[]`                           |
| `jellyfin.enableDLNA`                             | Whether to enable DLNA which requires the pod to be attached to the host network in order to be useful - this can break things like ingress to the service https://jellyfin.org/docs/general/networking/dlna.html. | `false`                        |
| `jellyfin.service.type`                           | The type of service to create.                                                                                                                                                                                     | `LoadBalancer`                 |
| `jellyfin.service.port`                           | The port on which the service will run.                                                                                                                                                                            | `8096`                         |
| `jellyfin.service.nodePort`                       | The nodePort to use for the service. Only used if service.type is NodePort.                                                                                                                                        | `""`                           |
| `jellyfin.ingress.enabled`                        | Whether to create an ingress for the service.                                                                                                                                                                      | `false`                        |
| `jellyfin.ingress.labels`                         | Additional labels to add to the ingress.                                                                                                                                                                           | `{}`                           |
| `jellyfin.ingress.annotations`                    | Additional annotations to add to the ingress.                                                                                                                                                                      | `{}`                           |
| `jellyfin.ingress.path`                           | The path to use for the ingress.                                                                                                                                                                                   | `/`                            |
| `jellyfin.ingress.hosts`                          | The hosts to use for the ingress.                                                                                                                                                                                  | `["chart-example.local"]`      |
| `jellyfin.ingress.tls`                            | The TLS configuration for the ingress.                                                                                                                                                                             | `[]`                           |
| `jellyfin.persistence.enabled`                    | Whether to enable persistence for the config.                                                                                                                                                                      | `true`                         |
| `jellyfin.persistence.storageClass`               | The storage class to use for the config.                                                                                                                                                                           | `""`                           |
| `jellyfin.persistence.existingClaim`              | The name of an existing claim to use for the config.                                                                                                                                                               | `""`                           |
| `jellyfin.persistence.accessMode`                 | The access mode to use for the config.                                                                                                                                                                             | `ReadWriteOnce`                |
| `jellyfin.persistence.size`                       | The size to use for the config.                                                                                                                                                                                    | `512Mi`                        |
| `jellyfin.persistence.labels`                     | Additional labels to add to the config.                                                                                                                                                                            | `{}`                           |
| `jellyfin.persistence.annotations`                | Additional annotations to add to the config.                                                                                                                                                                       | `{}`                           |
| `jellyfin.persistence.backup.enabled`             | Whether to enable backup persistence for the config.                                                                                                                                                               | `true`                         |
| `jellyfin.persistence.backup.storageClass`        | The storage class to use for backup persistence.                                                                                                                                                                   | `cephfs`                       |
| `jellyfin.persistence.backup.existingClaim`       | The name of an existing claim to use for backup persistence.                                                                                                                                                       | `""`                           |
| `jellyfin.persistence.backup.accessMode`          | The access mode to use for backup persistence.                                                                                                                                                                     | `ReadWriteMany`                |
| `jellyfin.persistence.backup.size`                | The size to use for backup persistence.                                                                                                                                                                            | `512Mi`                        |
| `jellyfin.persistence.cache.enabled`              | Whether to enable ephemeral cache volume for the service.                                                                                                                                                          | `true`                         |
| `jellyfin.persistence.cache.storageClass`         | The storage class to use for the ephemeral cache volume.                                                                                                                                                           | `""`                           |
| `jellyfin.persistence.cache.accessMode`           | The access mode to use for the ephemeral cache volume.                                                                                                                                                             | `ReadWriteOnce`                |
| `jellyfin.persistence.cache.size`                 | Size for the ephemeral cache volume (default: "1Gi").                                                                                                                                                              | `1Gi`                          |
| `jellyfin.persistence.transcode.enabled`          | Whether to enable emptyDir transcode volume for temporary transcodes.                                                                                                                                              | `true`                         |
| `jellyfin.persistence.transcode.sizeLimit`        | Size limit for the emptyDir transcode volume (e.g., "4Gi", "8Gi").                                                                                                                                                 | `4Gi`                          |
| `jellyfin.persistence.extraExistingClaimMounts`   | Additional existing claim mounts to add to the pod.                                                                                                                                                                | `[]`                           |
| `jellyfin.resources`                              | The resources to use for the pod.                                                                                                                                                                                  | `{}`                           |
| `jellyfin.runtimeClassName`                       | The runtime class to use for the pod.                                                                                                                                                                              | `""`                           |
| `jellyfin.nodeSelector`                           | The node selector to use for the pod.                                                                                                                                                                              | `{}`                           |
| `jellyfin.tolerations`                            | The tolerations to use for the pod.                                                                                                                                                                                | `[]`                           |
| `jellyfin.affinity`                               | The affinity to use for the pod.                                                                                                                                                                                   | `{}`                           |
| `jellyfin.extraVolumes`                           | Additional volumes to add to the pod.                                                                                                                                                                              | `[]`                           |
| `jellyfin.extraVolumeMounts`                      | Additional volume mounts to add to the pod.                                                                                                                                                                        | `[]`                           |
| `jellyfin.extraEnvVars`                           | Additional environment variables to add to the pod.                                                                                                                                                                | `[]`                           |
| `jellyfin.extraInitContainers`                    | Additional init containers to add to the pod.                                                                                                                                                                      | `{}`                           |
| `jellyfin.extraContainers`                        | Additional sidecar containers to add to the pod.                                                                                                                                                                   | `{}`                           |
| `jellyfin.podSecurityContext.fsGroup`             | The group ID to use for the pod.                                                                                                                                                                                   | `1000`                         |
| `jellyfin.podSecurityContext.fsGroupChangePolicy` | Policy for changing ownership and permissions of the volume.                                                                                                                                                       | `OnRootMismatch`               |
| `jellyfin.securityContext`                        | The security context to use for the container.                                                                                                                                                                     | `{}`                           |
| `jellyfin.livenessProbe.enabled`                  | Whether to enable the liveness probe.                                                                                                                                                                              | `false`                        |
| `jellyfin.livenessProbe.failureThreshold`         | The number of times to retry before giving up.                                                                                                                                                                     | `3`                            |
| `jellyfin.livenessProbe.initialDelaySeconds`      | The number of seconds to wait before starting the probe.                                                                                                                                                           | `10`                           |
| `jellyfin.livenessProbe.periodSeconds`            | The number of seconds between probe attempts.                                                                                                                                                                      | `10`                           |
| `jellyfin.livenessProbe.successThreshold`         | The minimum consecutive successes required to consider the probe successful.                                                                                                                                       | `1`                            |
| `jellyfin.livenessProbe.timeoutSeconds`           | The number of seconds after which the probe times out.                                                                                                                                                             | `1`                            |
| `jellyfin.readinessProbe.enabled`                 | Whether to enable the readiness probe.                                                                                                                                                                             | `false`                        |
| `jellyfin.readinessProbe.failureThreshold`        | The number of times to retry before giving up.                                                                                                                                                                     | `3`                            |
| `jellyfin.readinessProbe.initialDelaySeconds`     | The number of seconds to wait before starting the probe.                                                                                                                                                           | `10`                           |
| `jellyfin.readinessProbe.periodSeconds`           | The number of seconds between probe attempts.                                                                                                                                                                      | `10`                           |
| `jellyfin.readinessProbe.successThreshold`        | The minimum consecutive successes required to consider the probe successful.                                                                                                                                       | `1`                            |
| `jellyfin.readinessProbe.timeoutSeconds`          | The number of seconds after which the probe times out.                                                                                                                                                             | `1`                            |

### Sonarr parameters

| Name                                                   | Description                                                                                                                                    | Value                               |
| ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `sonarr.enabled`                                       | Whether to enable Sonarr.                                                                                                                      | `true`                              |
| `sonarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                              | `1`                                 |
| `sonarr.image.repository`                              | The Docker repository to pull the image from.                                                                                                  | `lscr.io/linuxserver/sonarr`        |
| `sonarr.image.tag`                                     | The image tag to use.                                                                                                                          | `4.0.16`                            |
| `sonarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                                    | `IfNotPresent`                      |
| `sonarr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                                         | `false`                             |
| `sonarr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                                         | `""`                                |
| `sonarr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                                          | `""`                                |
| `sonarr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                                 | `[]`                                |
| `sonarr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                                       | `""`                                |
| `sonarr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                               | `[]`                                |
| `sonarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                                 | `[]`                                |
| `sonarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                                | `Recreate`                          |
| `sonarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                           | `true`                              |
| `sonarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                                          | `{}`                                |
| `sonarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name.            | `""`                                |
| `sonarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                                      | `{}`                                |
| `sonarr.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                               | `1000`                              |
| `sonarr.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                                   | `OnRootMismatch`                    |
| `sonarr.securityContext`                               | The security context to use for the container.                                                                                                 | `{}`                                |
| `sonarr.initContainers`                                | Additional init containers to add to the pod.                                                                                                  | `[]`                                |
| `sonarr.service.type`                                  | The type of service to create.                                                                                                                 | `LoadBalancer`                      |
| `sonarr.service.port`                                  | The port on which the service will run.                                                                                                        | `80`                                |
| `sonarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                                    | `""`                                |
| `sonarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                                  | `false`                             |
| `sonarr.ingress.className`                             | The ingress class name to use.                                                                                                                 | `""`                                |
| `sonarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                                  | `{}`                                |
| `sonarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                               | `chart-example.local`               |
| `sonarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                               | `/`                                 |
| `sonarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                                          | `ImplementationSpecific`            |
| `sonarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                                         | `[]`                                |
| `sonarr.resources`                                     | The resources to use for the pod.                                                                                                              | `{}`                                |
| `sonarr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                                          | `""`                                |
| `sonarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                                 | `false`                             |
| `sonarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                                    | `1`                                 |
| `sonarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                                    | `100`                               |
| `sonarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                                  | `80`                                |
| `sonarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                               | `80`                                |
| `sonarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                                          | `{}`                                |
| `sonarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                            | `[]`                                |
| `sonarr.affinity`                                      | The affinity to use for the pod.                                                                                                               | `{}`                                |
| `sonarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                                | `1000`                              |
| `sonarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                               | `1000`                              |
| `sonarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                               | `Europe/London`                     |
| `sonarr.env.UMASK`                                     | The umask to use for the pod.                                                                                                                  | `002`                               |
| `sonarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                                 | `true`                              |
| `sonarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                                  | `""`                                |
| `sonarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                                      | `""`                                |
| `sonarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                                    | `ReadWriteOnce`                     |
| `sonarr.persistence.size`                              | The size to use for the persistence.                                                                                                           | `512Mi`                             |
| `sonarr.persistence.backup.enabled`                    | Whether to enable backup persistence for the config.                                                                                           | `true`                              |
| `sonarr.persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                               | `cephfs`                            |
| `sonarr.persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                                   | `""`                                |
| `sonarr.persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                                 | `ReadWriteMany`                     |
| `sonarr.persistence.backup.size`                       | The size to use for backup persistence.                                                                                                        | `512Mi`                             |
| `sonarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                                          | `[]`                                |
| `sonarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                                    | `[]`                                |
| `sonarr.database.mode`                                 | Database mode: 'standalone' uses SQLite (default), 'external' uses an external PostgreSQL database, 'cluster' creates a CloudNativePG cluster. | `standalone`                        |
| `sonarr.database.persistence.enabled`                  | Whether to enable persistence for the database (default: true).                                                                                | `true`                              |
| `sonarr.database.persistence.size`                     | Size of the persistence volume (default: 100Mi).                                                                                               | `512Mi`                             |
| `sonarr.database.persistence.storageClass`             | Storage class for persistence.                                                                                                                 | `""`                                |
| `sonarr.database.persistence.existingClaim`            | Use an existing PVC instead of creating a new one.                                                                                             | `""`                                |
| `sonarr.database.initSQL`                              | Array of SQL commands to run on database initialization.                                                                                       | `[]`                                |
| `sonarr.database.auth.username`                        | Username for the database.                                                                                                                     | `""`                                |
| `sonarr.database.auth.password`                        | Password for the database user.                                                                                                                | `""`                                |
| `sonarr.database.auth.existingSecret`                  | Reference to an existing Kubernetes secret for auth.                                                                                           | `""`                                |
| `sonarr.database.cluster.name`                         | Name of the database cluster.                                                                                                                  | `sonarr-db`                         |
| `sonarr.database.cluster.instances`                    | Number of PostgreSQL instances in the CloudNativePG cluster (only used when mode is 'cluster').                                                | `2`                                 |
| `sonarr.database.cluster.image.repository`             | PostgreSQL container image repository.                                                                                                         | `ghcr.io/cloudnative-pg/postgresql` |
| `sonarr.database.cluster.image.tag`                    | PostgreSQL container image tag.                                                                                                                | `16`                                |
| `sonarr.database.external.host`                        | Hostname of the external PostgreSQL database (required when mode is 'external').                                                               | `""`                                |
| `sonarr.database.external.port`                        | Port of the PostgreSQL database.                                                                                                               | `5432`                              |
| `sonarr.database.external.mainDatabase`                | Name of the main database for Sonarr.                                                                                                          | `sonarr-main`                       |
| `sonarr.database.external.logDatabase`                 | Name of the log database for Sonarr.                                                                                                           | `sonarr-log`                        |

### qBittorrent parameters

| Name                                                        | Description                                                                                                                         | Value                             |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `qbittorrent.enabled`                                       | Whether to enable qBittorrent.                                                                                                      | `true`                            |
| `qbittorrent.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                               |
| `qbittorrent.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/qbittorrent` |
| `qbittorrent.image.tag`                                     | The image tag to use.                                                                                                               | `latest`                          |
| `qbittorrent.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                    |
| `qbittorrent.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                              | `false`                           |
| `qbittorrent.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                              |
| `qbittorrent.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                              |
| `qbittorrent.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                              |
| `qbittorrent.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                            | `""`                              |
| `qbittorrent.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                              |
| `qbittorrent.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                              |
| `qbittorrent.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                        |
| `qbittorrent.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                            |
| `qbittorrent.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                              |
| `qbittorrent.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                              |
| `qbittorrent.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                              |
| `qbittorrent.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                    | `1000`                            |
| `qbittorrent.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                        | `OnRootMismatch`                  |
| `qbittorrent.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                              |
| `qbittorrent.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                              |
| `qbittorrent.service.type`                                  | The type of service to create (applies to all ports).                                                                               | `LoadBalancer`                    |
| `qbittorrent.service.web.port`                              | The port on which the service will run.                                                                                             | `8080`                            |
| `qbittorrent.service.web.nodePort`                          | The nodePort to use for the web service. Only used if service.type is NodePort.                                                     | `""`                              |
| `qbittorrent.service.bt.port`                               | The port on which the bittorrent service will run.                                                                                  | `6881`                            |
| `qbittorrent.service.bt.nodePort`                           | The nodePort to use for the bittorrent service. Only used if service.type is NodePort.                                              | `""`                              |
| `qbittorrent.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                           |
| `qbittorrent.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                              |
| `qbittorrent.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                              |
| `qbittorrent.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`             |
| `qbittorrent.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                               |
| `qbittorrent.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`          |
| `qbittorrent.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                              |
| `qbittorrent.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                              |
| `qbittorrent.runtimeClassName`                              | The runtime class to use for the pod.                                                                                               | `""`                              |
| `qbittorrent.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                           |
| `qbittorrent.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                               |
| `qbittorrent.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                             |
| `qbittorrent.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                              |
| `qbittorrent.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                              |
| `qbittorrent.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                              |
| `qbittorrent.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                              |
| `qbittorrent.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                              |
| `qbittorrent.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                            |
| `qbittorrent.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                            |
| `qbittorrent.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`                   |
| `qbittorrent.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                            |
| `qbittorrent.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                              |
| `qbittorrent.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                              |
| `qbittorrent.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`                   |
| `qbittorrent.persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                           |
| `qbittorrent.persistence.downloads.enabled`                 | Whether to enable ephemeral volume for downloads at /config/downloads/incomplete.                                                   | `true`                            |
| `qbittorrent.persistence.downloads.storageClass`            | The storage class to use for the ephemeral downloads volume.                                                                        | `""`                              |
| `qbittorrent.persistence.downloads.accessMode`              | The access mode to use for the ephemeral downloads volume.                                                                          | `ReadWriteOnce`                   |
| `qbittorrent.persistence.downloads.size`                    | The size to use for the ephemeral downloads volume.                                                                                 | `100Gi`                           |
| `qbittorrent.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                              |
| `qbittorrent.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                              |
| `qbittorrent.gluetun.enabled`                               | Whether to enable Gluetun VPN sidecar for routing qBittorrent traffic through a VPN.                                                | `false`                           |
| `qbittorrent.gluetun.image.repository`                      | The Docker repository to pull the Gluetun image from.                                                                               | `qmcgaw/gluetun`                  |
| `qbittorrent.gluetun.image.tag`                             | The image tag to use for Gluetun.                                                                                                   | `v3.39.2`                         |
| `qbittorrent.gluetun.image.pullPolicy`                      | The logic of image pulling for Gluetun.                                                                                             | `IfNotPresent`                    |
| `qbittorrent.gluetun.image.autoupdate.enabled`              | Whether to enable autoupdate for the Gluetun image.                                                                                 | `false`                           |
| `qbittorrent.gluetun.image.autoupdate.strategy`             | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                              |
| `qbittorrent.gluetun.image.autoupdate.allowTags`            | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                              |
| `qbittorrent.gluetun.image.autoupdate.ignoreTags`           | List of glob patterns to ignore specific tags.                                                                                      | `[]`                              |
| `qbittorrent.gluetun.image.autoupdate.pullSecret`           | Pull secret name for private registries.                                                                                            | `""`                              |
| `qbittorrent.gluetun.image.autoupdate.platforms`            | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                              |
| `qbittorrent.gluetun.env.VPN_SERVICE_PROVIDER`              | The VPN service provider (e.g., nordvpn, expressvpn, mullvad, etc.).                                                                | `""`                              |
| `qbittorrent.gluetun.env.VPN_TYPE`                          | The type of VPN protocol to use (openvpn or wireguard).                                                                             | `openvpn`                         |
| `qbittorrent.gluetun.env.OPENVPN_USER`                      | Username for OpenVPN authentication (if using OpenVPN).                                                                             | `""`                              |
| `qbittorrent.gluetun.env.OPENVPN_PASSWORD`                  | Password for OpenVPN authentication (if using OpenVPN).                                                                             | `""`                              |
| `qbittorrent.gluetun.env.SERVER_REGIONS`                    | Region for server selection (e.g., for VPN providers that use regions instead of countries).                                        | `""`                              |
| `qbittorrent.gluetun.httpProxy.enabled`                     | Whether to enable HTTP proxy server in Gluetun.                                                                                     | `true`                            |
| `qbittorrent.gluetun.httpProxy.port`                        | The port on which the HTTP proxy server will listen.                                                                                | `8888`                            |
| `qbittorrent.gluetun.shadowsocksProxy.enabled`              | Whether to enable Shadowsocks proxy server in Gluetun.                                                                              | `true`                            |
| `qbittorrent.gluetun.shadowsocksProxy.port`                 | The port on which the Shadowsocks proxy server will listen.                                                                         | `8388`                            |
| `qbittorrent.gluetun.portForwarding.enabled`                | Whether to enable VPN port forwarding and automatic port configuration in qBittorrent via its API.                                  | `false`                           |
| `qbittorrent.gluetun.portForwarding.provider`               | The VPN port forwarding provider (e.g., protonvpn, private internet access). Leave empty to use VPN_SERVICE_PROVIDER.               | `""`                              |
| `qbittorrent.gluetun.resources`                             | Resource limits and requests for the Gluetun container.                                                                             | `{}`                              |

### Prowlarr parameters

| Name                                                     | Description                                                                                                                                    | Value                               |
| -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `prowlarr.enabled`                                       | Whether to enable Prowlarr.                                                                                                                    | `true`                              |
| `prowlarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                              | `1`                                 |
| `prowlarr.image.repository`                              | The Docker repository to pull the image from.                                                                                                  | `lscr.io/linuxserver/prowlarr`      |
| `prowlarr.image.tag`                                     | The image tag to use.                                                                                                                          | `2.3.0`                             |
| `prowlarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                                    | `IfNotPresent`                      |
| `prowlarr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                                         | `false`                             |
| `prowlarr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                                         | `""`                                |
| `prowlarr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                                          | `""`                                |
| `prowlarr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                                 | `[]`                                |
| `prowlarr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                                       | `""`                                |
| `prowlarr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                               | `[]`                                |
| `prowlarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                                 | `[]`                                |
| `prowlarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                                | `Recreate`                          |
| `prowlarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                           | `true`                              |
| `prowlarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                                          | `{}`                                |
| `prowlarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name.            | `""`                                |
| `prowlarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                                      | `{}`                                |
| `prowlarr.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                               | `1000`                              |
| `prowlarr.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                                   | `OnRootMismatch`                    |
| `prowlarr.securityContext`                               | The security context to use for the container.                                                                                                 | `{}`                                |
| `prowlarr.initContainers`                                | Additional init containers to add to the pod.                                                                                                  | `[]`                                |
| `prowlarr.service.type`                                  | The type of service to create.                                                                                                                 | `LoadBalancer`                      |
| `prowlarr.service.port`                                  | The port on which the service will run.                                                                                                        | `9696`                              |
| `prowlarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                                    | `""`                                |
| `prowlarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                                  | `false`                             |
| `prowlarr.ingress.className`                             | The ingress class name to use.                                                                                                                 | `""`                                |
| `prowlarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                                  | `{}`                                |
| `prowlarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                               | `chart-example.local`               |
| `prowlarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                               | `/`                                 |
| `prowlarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                                          | `ImplementationSpecific`            |
| `prowlarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                                         | `[]`                                |
| `prowlarr.resources`                                     | The resources to use for the pod.                                                                                                              | `{}`                                |
| `prowlarr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                                          | `""`                                |
| `prowlarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                                 | `false`                             |
| `prowlarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                                    | `1`                                 |
| `prowlarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                                    | `100`                               |
| `prowlarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                                  | `80`                                |
| `prowlarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                               | `80`                                |
| `prowlarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                                          | `{}`                                |
| `prowlarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                            | `[]`                                |
| `prowlarr.affinity`                                      | The affinity to use for the pod.                                                                                                               | `{}`                                |
| `prowlarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                                | `1000`                              |
| `prowlarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                               | `1000`                              |
| `prowlarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                               | `Europe/London`                     |
| `prowlarr.env.UMASK`                                     | The umask to use for the pod.                                                                                                                  | `002`                               |
| `prowlarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                                 | `true`                              |
| `prowlarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                                  | `""`                                |
| `prowlarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                                      | `""`                                |
| `prowlarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                                    | `ReadWriteOnce`                     |
| `prowlarr.persistence.size`                              | The size to use for the persistence.                                                                                                           | `512Mi`                             |
| `prowlarr.persistence.backup.enabled`                    | Whether to enable backup persistence for the config.                                                                                           | `true`                              |
| `prowlarr.persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                               | `cephfs`                            |
| `prowlarr.persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                                   | `""`                                |
| `prowlarr.persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                                 | `ReadWriteMany`                     |
| `prowlarr.persistence.backup.size`                       | The size to use for backup persistence.                                                                                                        | `512Mi`                             |
| `prowlarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                                          | `[]`                                |
| `prowlarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                                    | `[]`                                |
| `prowlarr.database.mode`                                 | Database mode: 'standalone' uses SQLite (default), 'external' uses an external PostgreSQL database, 'cluster' creates a CloudNativePG cluster. | `standalone`                        |
| `prowlarr.database.persistence.enabled`                  | Whether to enable persistence for the database (default: true).                                                                                | `true`                              |
| `prowlarr.database.persistence.size`                     | Size of the persistence volume (default: 100Mi).                                                                                               | `512Mi`                             |
| `prowlarr.database.persistence.storageClass`             | Storage class for persistence.                                                                                                                 | `""`                                |
| `prowlarr.database.persistence.existingClaim`            | Use an existing PVC instead of creating a new one.                                                                                             | `""`                                |
| `prowlarr.database.initSQL`                              | Array of SQL commands to run on database initialization.                                                                                       | `[]`                                |
| `prowlarr.database.auth.username`                        | Username for the database.                                                                                                                     | `""`                                |
| `prowlarr.database.auth.password`                        | Password for the database user.                                                                                                                | `""`                                |
| `prowlarr.database.auth.existingSecret`                  | Reference to an existing Kubernetes secret for auth.                                                                                           | `""`                                |
| `prowlarr.database.cluster.name`                         | Name of the database cluster.                                                                                                                  | `prowlarr-db`                       |
| `prowlarr.database.cluster.instances`                    | Number of PostgreSQL instances in the CloudNativePG cluster (only used when mode is 'cluster').                                                | `2`                                 |
| `prowlarr.database.cluster.image.repository`             | PostgreSQL container image repository.                                                                                                         | `ghcr.io/cloudnative-pg/postgresql` |
| `prowlarr.database.cluster.image.tag`                    | PostgreSQL container image tag.                                                                                                                | `16`                                |
| `prowlarr.database.external.host`                        | Hostname of the external PostgreSQL database (required when mode is 'external').                                                               | `""`                                |
| `prowlarr.database.external.port`                        | Port of the PostgreSQL database.                                                                                                               | `5432`                              |
| `prowlarr.database.external.mainDatabase`                | Name of the main database for Prowlarr.                                                                                                        | `prowlarr-main`                     |
| `prowlarr.database.external.logDatabase`                 | Name of the log database for Prowlarr.                                                                                                         | `prowlarr-log`                      |

### FlareSolverr parameters

| Name                                                         | Description                                                                                                                         | Value                               |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `flaresolverr.enabled`                                       | Whether to enable FlareSolverr.                                                                                                     | `true`                              |
| `flaresolverr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                                 |
| `flaresolverr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `ghcr.io/flaresolverr/flaresolverr` |
| `flaresolverr.image.tag`                                     | The image tag to use.                                                                                                               | `v3.3.21`                           |
| `flaresolverr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                      |
| `flaresolverr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                              | `false`                             |
| `flaresolverr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                                |
| `flaresolverr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                                |
| `flaresolverr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                                |
| `flaresolverr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                            | `""`                                |
| `flaresolverr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                                |
| `flaresolverr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                                |
| `flaresolverr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                          |
| `flaresolverr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                              |
| `flaresolverr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                                |
| `flaresolverr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                                |
| `flaresolverr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                                |
| `flaresolverr.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                                |
| `flaresolverr.securityContext.allowPrivilegeEscalation`      | Whether to allow privilege escalation.                                                                                              | `false`                             |
| `flaresolverr.securityContext.capabilities.drop`             | The capabilities to drop.                                                                                                           | `["ALL"]`                           |
| `flaresolverr.securityContext.readOnlyRootFilesystem`        | Whether to use a read-only root filesystem.                                                                                         | `false`                             |
| `flaresolverr.securityContext.runAsNonRoot`                  | Whether to run as a non-root user.                                                                                                  | `true`                              |
| `flaresolverr.securityContext.privileged`                    | Whether to run in privileged mode.                                                                                                  | `false`                             |
| `flaresolverr.securityContext.runAsUser`                     | The user ID to use for the container.                                                                                               | `1000`                              |
| `flaresolverr.securityContext.runAsGroup`                    | The group ID to use for the container.                                                                                              | `1000`                              |
| `flaresolverr.securityContext.seccompProfile.type`           | The type of seccomp profile to use.                                                                                                 | `RuntimeDefault`                    |
| `flaresolverr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                                |
| `flaresolverr.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`                      |
| `flaresolverr.service.port`                                  | The port on which the service will run.                                                                                             | `8191`                              |
| `flaresolverr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                                |
| `flaresolverr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                             |
| `flaresolverr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                                |
| `flaresolverr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                                |
| `flaresolverr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`               |
| `flaresolverr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                                 |
| `flaresolverr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`            |
| `flaresolverr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                                |
| `flaresolverr.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                                |
| `flaresolverr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                               | `""`                                |
| `flaresolverr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                             |
| `flaresolverr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                                 |
| `flaresolverr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                               |
| `flaresolverr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                                |
| `flaresolverr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                                |
| `flaresolverr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                                |
| `flaresolverr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                                |
| `flaresolverr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                                |
| `flaresolverr.env`                                           | Additional environment variables to add to the pod.                                                                                 | `{}`                                |

### Seerr parameters

| Name                                                  | Description                                                                                                                                    | Value                               |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `seerr.enabled`                                       | Whether to enable Seerr.                                                                                                                       | `true`                              |
| `seerr.replicaCount`                                  | The number of replicas to deploy.                                                                                                              | `1`                                 |
| `seerr.image.repository`                              | The Docker repository to pull the image from.                                                                                                  | `ghcr.io/seerr-team/seerr`          |
| `seerr.image.tag`                                     | The image tag to use.                                                                                                                          | `3.0.0`                             |
| `seerr.image.pullPolicy`                              | The logic of image pulling.                                                                                                                    | `IfNotPresent`                      |
| `seerr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                                         | `false`                             |
| `seerr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                                         | `""`                                |
| `seerr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                                          | `""`                                |
| `seerr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                                 | `[]`                                |
| `seerr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                                       | `""`                                |
| `seerr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                               | `[]`                                |
| `seerr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                                 | `[]`                                |
| `seerr.serviceAccount.create`                         | Whether to create a service account.                                                                                                           | `true`                              |
| `seerr.serviceAccount.automount`                      | Automatically mount a ServiceAccount's API credentials.                                                                                        | `true`                              |
| `seerr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                                          | `{}`                                |
| `seerr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name.            | `""`                                |
| `seerr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                                      | `{}`                                |
| `seerr.podLabels`                                     | Additional labels to add to the pod.                                                                                                           | `{}`                                |
| `seerr.podSecurityContext`                            | The security context to use for the pod.                                                                                                       | `{}`                                |
| `seerr.securityContext.allowPrivilegeEscalation`      | Whether to allow privilege escalation.                                                                                                         | `false`                             |
| `seerr.securityContext.capabilities.drop`             | List of capabilities to drop.                                                                                                                  | `["ALL"]`                           |
| `seerr.securityContext.readOnlyRootFilesystem`        | Whether the root filesystem should be read-only.                                                                                               | `false`                             |
| `seerr.securityContext.runAsNonRoot`                  | Whether the container must run as a non-root user.                                                                                             | `true`                              |
| `seerr.securityContext.privileged`                    | Whether the container runs in privileged mode.                                                                                                 | `false`                             |
| `seerr.securityContext.runAsUser`                     | The user ID to run the container as.                                                                                                           | `1000`                              |
| `seerr.securityContext.runAsGroup`                    | The group ID to run the container as.                                                                                                          | `1000`                              |
| `seerr.securityContext.seccompProfile.type`           | The seccomp profile type.                                                                                                                      | `RuntimeDefault`                    |
| `seerr.initContainers`                                | Additional init containers to add to the pod.                                                                                                  | `[]`                                |
| `seerr.service.type`                                  | The type of service to create.                                                                                                                 | `LoadBalancer`                      |
| `seerr.service.port`                                  | The port on which the service will run.                                                                                                        | `5055`                              |
| `seerr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                                    | `""`                                |
| `seerr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                                  | `false`                             |
| `seerr.ingress.className`                             | The ingress class name to use.                                                                                                                 | `""`                                |
| `seerr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                                  | `{}`                                |
| `seerr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                               | `chart-example.local`               |
| `seerr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                               | `/`                                 |
| `seerr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                                          | `ImplementationSpecific`            |
| `seerr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                                         | `[]`                                |
| `seerr.resources`                                     | The resources to use for the pod.                                                                                                              | `{}`                                |
| `seerr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                                          | `""`                                |
| `seerr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                                 | `false`                             |
| `seerr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                                    | `1`                                 |
| `seerr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                                    | `100`                               |
| `seerr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                                  | `80`                                |
| `seerr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                               | `80`                                |
| `seerr.nodeSelector`                                  | The node selector to use for the pod.                                                                                                          | `{}`                                |
| `seerr.tolerations`                                   | The tolerations to use for the pod.                                                                                                            | `[]`                                |
| `seerr.affinity`                                      | The affinity to use for the pod.                                                                                                               | `{}`                                |
| `seerr.persistence.enabled`                           | Whether to enable persistence.                                                                                                                 | `true`                              |
| `seerr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                                  | `""`                                |
| `seerr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                                      | `""`                                |
| `seerr.persistence.accessModes`                       | Access modes of persistent disk.                                                                                                               | `["ReadWriteOnce"]`                 |
| `seerr.persistence.volumeName`                        | Name of the permanent volume to reference in the claim. Can be used to bind to existing volumes.                                               | `""`                                |
| `seerr.persistence.size`                              | The size to use for the persistence.                                                                                                           | `512Mi`                             |
| `seerr.persistence.annotations`                       | Annotations for PVCs.                                                                                                                          | `{}`                                |
| `seerr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                                          | `[]`                                |
| `seerr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                                    | `[]`                                |
| `seerr.probes.livenessProbe.enabled`                  | Whether to enable the liveness probe.                                                                                                          | `false`                             |
| `seerr.probes.livenessProbe.initialDelaySeconds`      | The number of seconds to wait before starting the liveness probe.                                                                              | `60`                                |
| `seerr.probes.livenessProbe.periodSeconds`            | The number of seconds between liveness probe attempts.                                                                                         | `30`                                |
| `seerr.probes.livenessProbe.timeoutSeconds`           | The number of seconds after which the liveness probe times out.                                                                                | `5`                                 |
| `seerr.probes.livenessProbe.successThreshold`         | The minimum consecutive successes required to consider the liveness probe successful.                                                          | `1`                                 |
| `seerr.probes.livenessProbe.failureThreshold`         | The number of times to retry the liveness probe before giving up.                                                                              | `5`                                 |
| `seerr.probes.readinessProbe.enabled`                 | Whether to enable the readiness probe.                                                                                                         | `false`                             |
| `seerr.probes.readinessProbe.initialDelaySeconds`     | The number of seconds to wait before starting the readiness probe.                                                                             | `60`                                |
| `seerr.probes.readinessProbe.periodSeconds`           | The number of seconds between readiness probe attempts.                                                                                        | `30`                                |
| `seerr.probes.readinessProbe.timeoutSeconds`          | The number of seconds after which the readiness probe times out.                                                                               | `5`                                 |
| `seerr.probes.readinessProbe.successThreshold`        | The minimum consecutive successes required to consider the readiness probe successful.                                                         | `1`                                 |
| `seerr.probes.readinessProbe.failureThreshold`        | The number of times to retry the readiness probe before giving up.                                                                             | `5`                                 |
| `seerr.probes.startupProbe`                           | Configure startup probe.                                                                                                                       | `nil`                               |
| `seerr.extraEnv`                                      | Additional environment variables to add to the seerr pods.                                                                                     | `[]`                                |
| `seerr.extraEnvFrom`                                  | Additional environment variables from secrets or configmaps to add to the seerr pods.                                                          | `[]`                                |
| `seerr.database.mode`                                 | Database mode: 'standalone' uses SQLite (default), 'external' uses an external PostgreSQL database, 'cluster' creates a CloudNativePG cluster. | `standalone`                        |
| `seerr.database.persistence.enabled`                  | Whether to enable persistence for the database (default: true).                                                                                | `true`                              |
| `seerr.database.persistence.size`                     | Size of the persistence volume (default: 100Mi).                                                                                               | `512Mi`                             |
| `seerr.database.persistence.storageClass`             | Storage class for persistence.                                                                                                                 | `""`                                |
| `seerr.database.persistence.existingClaim`            | Use an existing PVC instead of creating a new one.                                                                                             | `""`                                |
| `seerr.database.initSQL`                              | Array of SQL commands to run on database initialization.                                                                                       | `[]`                                |
| `seerr.database.auth.username`                        | Username for the database.                                                                                                                     | `""`                                |
| `seerr.database.auth.password`                        | Password for the database user.                                                                                                                | `""`                                |
| `seerr.database.auth.existingSecret`                  | Reference to an existing Kubernetes secret for auth.                                                                                           | `""`                                |
| `seerr.database.cluster.name`                         | Name of the database cluster.                                                                                                                  | `seerr-db`                          |
| `seerr.database.cluster.instances`                    | Number of PostgreSQL instances in the CloudNativePG cluster (only used when mode is 'cluster').                                                | `2`                                 |
| `seerr.database.cluster.image.repository`             | PostgreSQL container image repository.                                                                                                         | `ghcr.io/cloudnative-pg/postgresql` |
| `seerr.database.cluster.image.tag`                    | PostgreSQL container image tag.                                                                                                                | `16`                                |
| `seerr.database.external.host`                        | Hostname of the external PostgreSQL database (required when mode is 'external').                                                               | `""`                                |
| `seerr.database.external.port`                        | Port of the PostgreSQL database.                                                                                                               | `5432`                              |
| `seerr.database.external.mainDatabase`                | Name of the main database for Seerr.                                                                                                           | `jellyseerr`                        |
| `seerr.database.external.logDatabase`                 | Name of the log database for Seerr.                                                                                                            | `jellyseerr-log`                    |

### Bazarr parameters

| Name                                                   | Description                                                                                                                         | Value                        |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `bazarr.enabled`                                       | Whether to enable Bazarr.                                                                                                           | `true`                       |
| `bazarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                          |
| `bazarr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/bazarr` |
| `bazarr.image.tag`                                     | The image tag to use.                                                                                                               | `1.5.3`                      |
| `bazarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`               |
| `bazarr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                              | `false`                      |
| `bazarr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                         |
| `bazarr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                         |
| `bazarr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                         |
| `bazarr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                            | `""`                         |
| `bazarr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                         |
| `bazarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                         |
| `bazarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                   |
| `bazarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                       |
| `bazarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                         |
| `bazarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                         |
| `bazarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                         |
| `bazarr.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                    | `1000`                       |
| `bazarr.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                        | `OnRootMismatch`             |
| `bazarr.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                         |
| `bazarr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                         |
| `bazarr.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`               |
| `bazarr.service.port`                                  | The port on which the service will run.                                                                                             | `6767`                       |
| `bazarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                         |
| `bazarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                      |
| `bazarr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                         |
| `bazarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                         |
| `bazarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`        |
| `bazarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                          |
| `bazarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`     |
| `bazarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                         |
| `bazarr.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                         |
| `bazarr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                               | `""`                         |
| `bazarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                      |
| `bazarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                          |
| `bazarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                        |
| `bazarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                         |
| `bazarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                         |
| `bazarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                         |
| `bazarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                         |
| `bazarr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                         |
| `bazarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                       |
| `bazarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                       |
| `bazarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`              |
| `bazarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                       |
| `bazarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                         |
| `bazarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                         |
| `bazarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`              |
| `bazarr.persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                      |
| `bazarr.persistence.backup.enabled`                    | Whether to enable backup persistence for the config.                                                                                | `true`                       |
| `bazarr.persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                    | `cephfs`                     |
| `bazarr.persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                        | `""`                         |
| `bazarr.persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                      | `ReadWriteMany`              |
| `bazarr.persistence.backup.size`                       | The size to use for backup persistence.                                                                                             | `512Mi`                      |
| `bazarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                         |
| `bazarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                         |

### Radarr parameters

| Name                                                   | Description                                                                                                                                    | Value                               |
| ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `radarr.enabled`                                       | Whether to enable Radarr.                                                                                                                      | `true`                              |
| `radarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                              | `1`                                 |
| `radarr.image.repository`                              | The Docker repository to pull the image from.                                                                                                  | `lscr.io/linuxserver/radarr`        |
| `radarr.image.tag`                                     | The image tag to use.                                                                                                                          | `6.0.4`                             |
| `radarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                                    | `IfNotPresent`                      |
| `radarr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                                         | `false`                             |
| `radarr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                                         | `""`                                |
| `radarr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                                          | `""`                                |
| `radarr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                                 | `[]`                                |
| `radarr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                                       | `""`                                |
| `radarr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                               | `[]`                                |
| `radarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                                 | `[]`                                |
| `radarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                                | `Recreate`                          |
| `radarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                           | `true`                              |
| `radarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                                          | `{}`                                |
| `radarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name.            | `""`                                |
| `radarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                                      | `{}`                                |
| `radarr.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                               | `1000`                              |
| `radarr.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                                   | `OnRootMismatch`                    |
| `radarr.securityContext`                               | The security context to use for the container.                                                                                                 | `{}`                                |
| `radarr.initContainers`                                | Additional init containers to add to the pod.                                                                                                  | `[]`                                |
| `radarr.service.type`                                  | The type of service to create.                                                                                                                 | `LoadBalancer`                      |
| `radarr.service.port`                                  | The port on which the service will run.                                                                                                        | `7878`                              |
| `radarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                                    | `""`                                |
| `radarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                                  | `false`                             |
| `radarr.ingress.className`                             | The ingress class name to use.                                                                                                                 | `""`                                |
| `radarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                                  | `{}`                                |
| `radarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                               | `chart-example.local`               |
| `radarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                               | `/`                                 |
| `radarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                                          | `ImplementationSpecific`            |
| `radarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                                         | `[]`                                |
| `radarr.resources`                                     | The resources to use for the pod.                                                                                                              | `{}`                                |
| `radarr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                                          | `""`                                |
| `radarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                                 | `false`                             |
| `radarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                                    | `1`                                 |
| `radarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                                    | `100`                               |
| `radarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                                  | `80`                                |
| `radarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                               | `80`                                |
| `radarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                                          | `{}`                                |
| `radarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                            | `[]`                                |
| `radarr.affinity`                                      | The affinity to use for the pod.                                                                                                               | `{}`                                |
| `radarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                                | `1000`                              |
| `radarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                               | `1000`                              |
| `radarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                               | `Europe/London`                     |
| `radarr.env.UMASK`                                     | The umask to use for the pod.                                                                                                                  | `002`                               |
| `radarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                                 | `true`                              |
| `radarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                                  | `""`                                |
| `radarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                                      | `""`                                |
| `radarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                                    | `ReadWriteOnce`                     |
| `radarr.persistence.size`                              | The size to use for the persistence.                                                                                                           | `512Mi`                             |
| `radarr.persistence.backup.enabled`                    | Whether to enable backup persistence for the config.                                                                                           | `true`                              |
| `radarr.persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                               | `cephfs`                            |
| `radarr.persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                                   | `""`                                |
| `radarr.persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                                 | `ReadWriteMany`                     |
| `radarr.persistence.backup.size`                       | The size to use for backup persistence.                                                                                                        | `512Mi`                             |
| `radarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                                          | `[]`                                |
| `radarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                                    | `[]`                                |
| `radarr.database.mode`                                 | Database mode: 'standalone' uses SQLite (default), 'external' uses an external PostgreSQL database, 'cluster' creates a CloudNativePG cluster. | `standalone`                        |
| `radarr.database.persistence.enabled`                  | Whether to enable persistence for the database (default: true).                                                                                | `true`                              |
| `radarr.database.persistence.size`                     | Size of the persistence volume (default: 100Mi).                                                                                               | `512Mi`                             |
| `radarr.database.persistence.storageClass`             | Storage class for persistence.                                                                                                                 | `""`                                |
| `radarr.database.persistence.existingClaim`            | Use an existing PVC instead of creating a new one.                                                                                             | `""`                                |
| `radarr.database.initSQL`                              | Array of SQL commands to run on database initialization.                                                                                       | `[]`                                |
| `radarr.database.auth.username`                        | Username for the database.                                                                                                                     | `""`                                |
| `radarr.database.auth.password`                        | Password for the database user.                                                                                                                | `""`                                |
| `radarr.database.auth.existingSecret`                  | Reference to an existing Kubernetes secret for auth.                                                                                           | `""`                                |
| `radarr.database.cluster.name`                         | Name of the database cluster.                                                                                                                  | `radarr-db`                         |
| `radarr.database.cluster.instances`                    | Number of PostgreSQL instances in the CloudNativePG cluster (only used when mode is 'cluster').                                                | `2`                                 |
| `radarr.database.cluster.image.repository`             | PostgreSQL container image repository.                                                                                                         | `ghcr.io/cloudnative-pg/postgresql` |
| `radarr.database.cluster.image.tag`                    | PostgreSQL container image tag.                                                                                                                | `16`                                |
| `radarr.database.external.host`                        | Hostname of the external PostgreSQL database (required when mode is 'external').                                                               | `""`                                |
| `radarr.database.external.port`                        | Port of the PostgreSQL database.                                                                                                               | `5432`                              |
| `radarr.database.external.mainDatabase`                | Name of the main database for Radarr.                                                                                                          | `radarr-main`                       |
| `radarr.database.external.logDatabase`                 | Name of the log database for Radarr.                                                                                                           | `radarr-log`                        |

### Lidarr parameters

| Name                                                   | Description                                                                                                                                    | Value                               |
| ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `lidarr.enabled`                                       | Whether to enable Lidarr.                                                                                                                      | `true`                              |
| `lidarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                              | `1`                                 |
| `lidarr.image.repository`                              | The Docker repository to pull the image from.                                                                                                  | `lscr.io/linuxserver/lidarr`        |
| `lidarr.image.tag`                                     | The image tag to use.                                                                                                                          | `3.1.0`                             |
| `lidarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                                    | `IfNotPresent`                      |
| `lidarr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                                         | `false`                             |
| `lidarr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                                         | `""`                                |
| `lidarr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                                          | `""`                                |
| `lidarr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                                 | `[]`                                |
| `lidarr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                                       | `""`                                |
| `lidarr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                               | `[]`                                |
| `lidarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                                 | `[]`                                |
| `lidarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                                | `Recreate`                          |
| `lidarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                           | `true`                              |
| `lidarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                                          | `{}`                                |
| `lidarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name.            | `""`                                |
| `lidarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                                      | `{}`                                |
| `lidarr.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                               | `1000`                              |
| `lidarr.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                                   | `OnRootMismatch`                    |
| `lidarr.securityContext`                               | The security context to use for the container.                                                                                                 | `{}`                                |
| `lidarr.initContainers`                                | Additional init containers to add to the pod.                                                                                                  | `[]`                                |
| `lidarr.service.type`                                  | The type of service to create.                                                                                                                 | `LoadBalancer`                      |
| `lidarr.service.port`                                  | The port on which the service will run.                                                                                                        | `8686`                              |
| `lidarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                                    | `""`                                |
| `lidarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                                  | `false`                             |
| `lidarr.ingress.className`                             | The ingress class name to use.                                                                                                                 | `""`                                |
| `lidarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                                  | `{}`                                |
| `lidarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                               | `chart-example.local`               |
| `lidarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                               | `/`                                 |
| `lidarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                                          | `ImplementationSpecific`            |
| `lidarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                                         | `[]`                                |
| `lidarr.resources`                                     | The resources to use for the pod.                                                                                                              | `{}`                                |
| `lidarr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                                          | `""`                                |
| `lidarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                                 | `false`                             |
| `lidarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                                    | `1`                                 |
| `lidarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                                    | `100`                               |
| `lidarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                                  | `80`                                |
| `lidarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                               | `80`                                |
| `lidarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                                          | `{}`                                |
| `lidarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                            | `[]`                                |
| `lidarr.affinity`                                      | The affinity to use for the pod.                                                                                                               | `{}`                                |
| `lidarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                                | `1000`                              |
| `lidarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                               | `1000`                              |
| `lidarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                               | `Europe/London`                     |
| `lidarr.env.UMASK`                                     | The umask to use for the pod.                                                                                                                  | `002`                               |
| `lidarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                                 | `true`                              |
| `lidarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                                  | `""`                                |
| `lidarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                                      | `""`                                |
| `lidarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                                    | `ReadWriteOnce`                     |
| `lidarr.persistence.size`                              | The size to use for the persistence.                                                                                                           | `512Mi`                             |
| `lidarr.persistence.backup.enabled`                    | Whether to enable backup persistence for the config.                                                                                           | `true`                              |
| `lidarr.persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                               | `cephfs`                            |
| `lidarr.persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                                   | `""`                                |
| `lidarr.persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                                 | `ReadWriteMany`                     |
| `lidarr.persistence.backup.size`                       | The size to use for backup persistence.                                                                                                        | `512Mi`                             |
| `lidarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                                          | `[]`                                |
| `lidarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                                    | `[]`                                |
| `lidarr.database.mode`                                 | Database mode: 'standalone' uses SQLite (default), 'external' uses an external PostgreSQL database, 'cluster' creates a CloudNativePG cluster. | `standalone`                        |
| `lidarr.database.persistence.enabled`                  | Whether to enable persistence for the database (default: true).                                                                                | `true`                              |
| `lidarr.database.persistence.size`                     | Size of the persistence volume (default: 100Mi).                                                                                               | `512Mi`                             |
| `lidarr.database.persistence.storageClass`             | Storage class for persistence.                                                                                                                 | `""`                                |
| `lidarr.database.persistence.existingClaim`            | Use an existing PVC instead of creating a new one.                                                                                             | `""`                                |
| `lidarr.database.initSQL`                              | Array of SQL commands to run on database initialization.                                                                                       | `[]`                                |
| `lidarr.database.auth.username`                        | Username for the database.                                                                                                                     | `""`                                |
| `lidarr.database.auth.password`                        | Password for the database user.                                                                                                                | `""`                                |
| `lidarr.database.auth.existingSecret`                  | Reference to an existing Kubernetes secret for auth.                                                                                           | `""`                                |
| `lidarr.database.cluster.name`                         | Name of the database cluster.                                                                                                                  | `lidarr-db`                         |
| `lidarr.database.cluster.instances`                    | Number of PostgreSQL instances in the CloudNativePG cluster (only used when mode is 'cluster').                                                | `2`                                 |
| `lidarr.database.cluster.image.repository`             | PostgreSQL container image repository.                                                                                                         | `ghcr.io/cloudnative-pg/postgresql` |
| `lidarr.database.cluster.image.tag`                    | PostgreSQL container image tag.                                                                                                                | `16`                                |
| `lidarr.database.external.host`                        | Hostname of the external PostgreSQL database (required when mode is 'external').                                                               | `""`                                |
| `lidarr.database.external.port`                        | Port of the PostgreSQL database.                                                                                                               | `5432`                              |
| `lidarr.database.external.mainDatabase`                | Name of the main database for Lidarr.                                                                                                          | `lidarr-main`                       |
| `lidarr.database.external.logDatabase`                 | Name of the log database for Lidarr.                                                                                                           | `lidarr-log`                        |

### Cleanuparr parameters

| Name                                                       | Description                                                                                                                         | Value                           |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `cleanuparr.enabled`                                       | Whether to enable Cleanuparr.                                                                                                       | `false`                         |
| `cleanuparr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                             |
| `cleanuparr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `ghcr.io/cleanuparr/cleanuparr` |
| `cleanuparr.image.tag`                                     | The image tag to use.                                                                                                               | `latest`                        |
| `cleanuparr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                  |
| `cleanuparr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                              | `false`                         |
| `cleanuparr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                            |
| `cleanuparr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                            |
| `cleanuparr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                            |
| `cleanuparr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                            | `""`                            |
| `cleanuparr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                            |
| `cleanuparr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                            |
| `cleanuparr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                      |
| `cleanuparr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                          |
| `cleanuparr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                            |
| `cleanuparr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                            |
| `cleanuparr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                            |
| `cleanuparr.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                    | `1000`                          |
| `cleanuparr.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                        | `OnRootMismatch`                |
| `cleanuparr.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                            |
| `cleanuparr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                            |
| `cleanuparr.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`                  |
| `cleanuparr.service.port`                                  | The port on which the service will run.                                                                                             | `11011`                         |
| `cleanuparr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                            |
| `cleanuparr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                         |
| `cleanuparr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                            |
| `cleanuparr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                            |
| `cleanuparr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`           |
| `cleanuparr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                             |
| `cleanuparr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`        |
| `cleanuparr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                            |
| `cleanuparr.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                            |
| `cleanuparr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                               | `""`                            |
| `cleanuparr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                         |
| `cleanuparr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                             |
| `cleanuparr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                           |
| `cleanuparr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                            |
| `cleanuparr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                            |
| `cleanuparr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                            |
| `cleanuparr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                            |
| `cleanuparr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                            |
| `cleanuparr.env.BASE_PATH`                                 | The base path to use for the service.                                                                                               | `""`                            |
| `cleanuparr.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                          |
| `cleanuparr.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                          |
| `cleanuparr.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`                 |
| `cleanuparr.env.UMASK`                                     | The umask to use for the pod.                                                                                                       | `002`                           |
| `cleanuparr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `false`                         |
| `cleanuparr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                            |
| `cleanuparr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                            |
| `cleanuparr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`                 |
| `cleanuparr.persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                         |
| `cleanuparr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                            |
| `cleanuparr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                            |

### Huntarr parameters

| Name                                                    | Description                                                                                                                         | Value                       |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `huntarr.enabled`                                       | Whether to enable Huntarr.                                                                                                          | `false`                     |
| `huntarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                         |
| `huntarr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `ghcr.io/plexguide/huntarr` |
| `huntarr.image.tag`                                     | The image tag to use.                                                                                                               | `latest`                    |
| `huntarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`              |
| `huntarr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                              | `false`                     |
| `huntarr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                        |
| `huntarr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                        |
| `huntarr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                        |
| `huntarr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                            | `""`                        |
| `huntarr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                        |
| `huntarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                        |
| `huntarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                  |
| `huntarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                      |
| `huntarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                        |
| `huntarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                        |
| `huntarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                        |
| `huntarr.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                    | `1000`                      |
| `huntarr.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                        | `OnRootMismatch`            |
| `huntarr.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                        |
| `huntarr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                        |
| `huntarr.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`              |
| `huntarr.service.port`                                  | The port on which the service will run.                                                                                             | `9705`                      |
| `huntarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                        |
| `huntarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                     |
| `huntarr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                        |
| `huntarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                        |
| `huntarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`       |
| `huntarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                         |
| `huntarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`    |
| `huntarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                        |
| `huntarr.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                        |
| `huntarr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                               | `""`                        |
| `huntarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                     |
| `huntarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                         |
| `huntarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                       |
| `huntarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                        |
| `huntarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                        |
| `huntarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                        |
| `huntarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                        |
| `huntarr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                        |
| `huntarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                      |
| `huntarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                      |
| `huntarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`             |
| `huntarr.env.UMASK`                                     | The umask to use for the pod.                                                                                                       | `002`                       |
| `huntarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `false`                     |
| `huntarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                        |
| `huntarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                        |
| `huntarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`             |
| `huntarr.persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                     |
| `huntarr.persistence.backup.enabled`                    | Whether to enable backup persistence for the config.                                                                                | `true`                      |
| `huntarr.persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                    | `cephfs`                    |
| `huntarr.persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                        | `""`                        |
| `huntarr.persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                      | `ReadWriteMany`             |
| `huntarr.persistence.backup.size`                       | The size to use for backup persistence.                                                                                             | `512Mi`                     |
| `huntarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                        |
| `huntarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                        |

### SABnzbd parameters

| Name                                                    | Description                                                                                                                         | Value                         |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| `sabnzbd.enabled`                                       | Whether to enable SABnzbd.                                                                                                          | `false`                       |
| `sabnzbd.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                           |
| `sabnzbd.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/sabnzbd` |
| `sabnzbd.image.tag`                                     | The image tag to use.                                                                                                               | `4.5.5`                       |
| `sabnzbd.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                |
| `sabnzbd.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                              | `false`                       |
| `sabnzbd.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                          |
| `sabnzbd.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                          |
| `sabnzbd.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                          |
| `sabnzbd.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                            | `""`                          |
| `sabnzbd.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                          |
| `sabnzbd.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                          |
| `sabnzbd.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                    |
| `sabnzbd.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                        |
| `sabnzbd.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                          |
| `sabnzbd.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                          |
| `sabnzbd.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                          |
| `sabnzbd.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                    | `1000`                        |
| `sabnzbd.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                        | `OnRootMismatch`              |
| `sabnzbd.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                          |
| `sabnzbd.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                          |
| `sabnzbd.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`                |
| `sabnzbd.service.port`                                  | The port on which the service will run.                                                                                             | `8080`                        |
| `sabnzbd.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                          |
| `sabnzbd.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                       |
| `sabnzbd.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                          |
| `sabnzbd.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                          |
| `sabnzbd.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`         |
| `sabnzbd.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                           |
| `sabnzbd.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`      |
| `sabnzbd.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                          |
| `sabnzbd.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                          |
| `sabnzbd.runtimeClassName`                              | The runtime class to use for the pod.                                                                                               | `""`                          |
| `sabnzbd.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                       |
| `sabnzbd.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                           |
| `sabnzbd.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                         |
| `sabnzbd.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                          |
| `sabnzbd.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                          |
| `sabnzbd.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                          |
| `sabnzbd.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                          |
| `sabnzbd.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                          |
| `sabnzbd.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                        |
| `sabnzbd.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                        |
| `sabnzbd.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`               |
| `sabnzbd.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                        |
| `sabnzbd.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                          |
| `sabnzbd.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                          |
| `sabnzbd.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`               |
| `sabnzbd.persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                       |
| `sabnzbd.persistence.backup.enabled`                    | Whether to enable backup persistence for the config.                                                                                | `true`                        |
| `sabnzbd.persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                    | `cephfs`                      |
| `sabnzbd.persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                        | `""`                          |
| `sabnzbd.persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                      | `ReadWriteMany`               |
| `sabnzbd.persistence.backup.size`                       | The size to use for backup persistence.                                                                                             | `512Mi`                       |
| `sabnzbd.persistence.downloads.enabled`                 | Whether to enable ephemeral volume for downloads at /config/downloads/incomplete.                                                   | `true`                        |
| `sabnzbd.persistence.downloads.storageClass`            | The storage class to use for the ephemeral downloads volume.                                                                        | `""`                          |
| `sabnzbd.persistence.downloads.accessMode`              | The access mode to use for the ephemeral downloads volume.                                                                          | `ReadWriteOnce`               |
| `sabnzbd.persistence.downloads.size`                    | The size to use for the ephemeral downloads volume.                                                                                 | `100Gi`                       |
| `sabnzbd.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                          |
| `sabnzbd.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                          |

### Plex parameters

| Name                                                 | Description                                                                                                                         | Value                      |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `plex.enabled`                                       | Whether to enable Plex.                                                                                                             | `false`                    |
| `plex.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                        |
| `plex.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/plex` |
| `plex.image.tag`                                     | The image tag to use.                                                                                                               | `1.42.2`                   |
| `plex.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`             |
| `plex.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                              | `false`                    |
| `plex.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                       |
| `plex.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                       |
| `plex.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                       |
| `plex.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                            | `""`                       |
| `plex.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                       |
| `plex.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                       |
| `plex.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                 |
| `plex.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                     |
| `plex.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                       |
| `plex.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                       |
| `plex.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                       |
| `plex.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                    | `1000`                     |
| `plex.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                        | `OnRootMismatch`           |
| `plex.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                       |
| `plex.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                       |
| `plex.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`             |
| `plex.service.port`                                  | The port on which the service will run.                                                                                             | `32400`                    |
| `plex.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                       |
| `plex.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                    |
| `plex.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                       |
| `plex.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                       |
| `plex.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`      |
| `plex.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                        |
| `plex.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`   |
| `plex.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                       |
| `plex.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                       |
| `plex.runtimeClassName`                              | The runtime class to use for the pod.                                                                                               | `""`                       |
| `plex.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                    |
| `plex.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                        |
| `plex.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                      |
| `plex.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                       |
| `plex.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                       |
| `plex.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                       |
| `plex.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                       |
| `plex.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                       |
| `plex.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                     |
| `plex.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                     |
| `plex.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`            |
| `plex.env.VERSION`                                   | Docker image version to use. Valid options are docker, latest, public, or a specific version.                                       | `docker`                   |
| `plex.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                     |
| `plex.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                       |
| `plex.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                       |
| `plex.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`            |
| `plex.persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                    |
| `plex.persistence.backup.enabled`                    | Whether to enable backup persistence for the config.                                                                                | `true`                     |
| `plex.persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                    | `cephfs`                   |
| `plex.persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                        | `""`                       |
| `plex.persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                      | `ReadWriteMany`            |
| `plex.persistence.backup.size`                       | The size to use for backup persistence.                                                                                             | `512Mi`                    |
| `plex.persistence.cache.enabled`                     | Whether to enable ephemeral cache volume for the service.                                                                           | `true`                     |
| `plex.persistence.cache.storageClass`                | The storage class to use for the ephemeral cache volume.                                                                            | `""`                       |
| `plex.persistence.cache.accessMode`                  | The access mode to use for the ephemeral cache volume.                                                                              | `ReadWriteOnce`            |
| `plex.persistence.cache.size`                        | Size for the ephemeral cache volume (default: "1Gi").                                                                               | `1Gi`                      |
| `plex.persistence.transcode.enabled`                 | Whether to enable emptyDir transcode volume for temporary transcodes.                                                               | `true`                     |
| `plex.persistence.transcode.sizeLimit`               | Size limit for the emptyDir transcode volume (e.g., "4Gi", "8Gi").                                                                  | `4Gi`                      |
| `plex.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                       |
| `plex.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                       |

### Emby parameters

> **Note**: As of chart version 1.7.3, the transcode volume configuration has been restructured. Use `emby.persistence.transcode.type` to select between `memory` (default, RAM disk) or `disk` (ephemeral volume).

| Name                                                 | Description                                                                                                                         | Value                      |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `emby.enabled`                                       | Whether to enable Emby.                                                                                                             | `false`                    |
| `emby.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                        |
| `emby.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/emby` |
| `emby.image.tag`                                     | The image tag to use.                                                                                                               | `4.9.1`                    |
| `emby.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`             |
| `emby.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                              | `false`                    |
| `emby.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                       |
| `emby.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                       |
| `emby.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                       |
| `emby.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                            | `""`                       |
| `emby.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                       |
| `emby.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                       |
| `emby.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                 |
| `emby.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                     |
| `emby.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                       |
| `emby.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                       |
| `emby.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                       |
| `emby.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                    | `1000`                     |
| `emby.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                        | `OnRootMismatch`           |
| `emby.securityContext.allowPrivilegeEscalation`      | Whether to allow privilege escalation.                                                                                              | `false`                    |
| `emby.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                       |
| `emby.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`             |
| `emby.service.port`                                  | The port on which the service will run.                                                                                             | `8096`                     |
| `emby.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                       |
| `emby.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                    |
| `emby.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                       |
| `emby.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                       |
| `emby.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`      |
| `emby.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                        |
| `emby.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`   |
| `emby.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                       |
| `emby.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                       |
| `emby.runtimeClassName`                              | The runtime class to use for the pod.                                                                                               | `""`                       |
| `emby.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                    |
| `emby.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                        |
| `emby.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                      |
| `emby.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                       |
| `emby.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                       |
| `emby.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                       |
| `emby.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                       |
| `emby.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                       |
| `emby.env.UID`                                       | The user ID to run emby as.                                                                                                         | `1000`                     |
| `emby.env.GID`                                       | The group ID to run emby as.                                                                                                        | `100`                      |
| `emby.env.GIDLIST`                                   | A comma-separated list of additional GIDs to run emby as.                                                                           | `100`                      |
| `emby.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`            |
| `emby.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                     |
| `emby.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                       |
| `emby.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                       |
| `emby.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`            |
| `emby.persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                    |
| `emby.persistence.backup.enabled`                    | Whether to enable backup persistence for the config.                                                                                | `true`                     |
| `emby.persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                    | `cephfs`                   |
| `emby.persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                        | `""`                       |
| `emby.persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                      | `ReadWriteMany`            |
| `emby.persistence.backup.size`                       | The size to use for backup persistence.                                                                                             | `512Mi`                    |
| `emby.persistence.transcode.enabled`                 | Whether to enable transcode volume for temporary transcodes.                                                                        | `true`                     |
| `emby.persistence.transcode.type`                    | Type of transcode volume: `memory` (RAM disk) or `disk` (ephemeral/persistent volume).                                              | `memory`                   |
| `emby.persistence.transcode.memory.sizeLimit`        | Size limit for the in-memory emptyDir transcode volume (when type is `memory`).                                                     | `4Gi`                      |
| `emby.persistence.transcode.disk.storageClass`       | The storage class to use for the disk-based transcode volume (when type is `disk`).                                                 | `""`                       |
| `emby.persistence.transcode.disk.existingClaim`      | The name of an existing claim to use for disk-based transcode (when type is `disk`).                                                | `""`                       |
| `emby.persistence.transcode.disk.size`               | Size for the ephemeral transcode volume (when type is `disk` and no existingClaim).                                                 | `10Gi`                     |
| `emby.persistence.transcode.disk.accessMode`         | The access mode to use for the disk-based transcode volume (when type is `disk`).                                                   | `ReadWriteOnce`            |
| `emby.persistence.cache.enabled`                     | Whether to enable ephemeral cache volume for the service.                                                                           | `true`                     |
| `emby.persistence.cache.storageClass`                | The storage class to use for the ephemeral cache volume.                                                                            | `""`                       |
| `emby.persistence.cache.accessMode`                  | The access mode to use for the ephemeral cache volume.                                                                              | `ReadWriteOnce`            |
| `emby.persistence.cache.size`                        | Size for the ephemeral cache volume (default: "1Gi").                                                                               | `1Gi`                      |
| `emby.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                       |
| `emby.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                       |

### Dispatcharr parameters

| Name                                                      | Description                                                                                                                         | Value                             |
| --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `dispatcharr.enabled`                                       | Whether to enable Dispatcharr.                                                                                                 | `false`                           |
| `dispatcharr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                               |
| `dispatcharr.image.repository`                              | The Docker repository to pull the Dispatcharr image from.                                                                           | `ghcr.io/dispatcharr/dispatcharr` |
| `dispatcharr.image.tag`                                     | The image tag to use for Dispatcharr.                                                                                               | `latest`                          |
| `dispatcharr.image.pullPolicy`                              | The logic of image pulling for Dispatcharr.                                                                                         | `IfNotPresent`                    |
| `dispatcharr.image.autoupdate.enabled`                      | Whether to enable autoupdate for this service's image.                                                                              | `false`                           |
| `dispatcharr.image.autoupdate.strategy`                     | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                              |
| `dispatcharr.image.autoupdate.allowTags`                    | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                              |
| `dispatcharr.image.autoupdate.ignoreTags`                   | List of glob patterns to ignore specific tags.                                                                                      | `[]`                              |
| `dispatcharr.image.autoupdate.pullSecret`                   | Pull secret name for private registries.                                                                                            | `""`                              |
| `dispatcharr.image.autoupdate.platforms`                    | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                              |
| `dispatcharr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                              |
| `dispatcharr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                        |
| `dispatcharr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                            |
| `dispatcharr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                              |
| `dispatcharr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                              |
| `dispatcharr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                              |
| `dispatcharr.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                    | `1000`                            |
| `dispatcharr.podSecurityContext.fsGroupChangePolicy`        | Policy for changing ownership and permissions of the volume.                                                                        | `OnRootMismatch`                  |
| `dispatcharr.securityContext`                               | Security context for the Dispatcharr container.                                                                                     | `{}`                              |
| `dispatcharr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                              |
| `dispatcharr.env`                                           | Additional environment variables to add to the Dispatcharr container.                                                               | See values.yaml                   |
| `dispatcharr.env.PUID`                                      | User ID for Dispatcharr process.                                                                                                    | `1000`                            |
| `dispatcharr.env.PGID`                                      | Group ID for Dispatcharr process.                                                                                                   | `1000`                            |
| `dispatcharr.env.TZ`                                        | Timezone for Dispatcharr.                                                                                                           | `Europe/London`                   |
| `dispatcharr.env.UMASK`                                     | File creation mask for Dispatcharr.                                                                                                 | `002`                             |
| `dispatcharr.resources`                                     | Resource limits and requests for the Dispatcharr container.                                                                         | `{}`                              |
| `dispatcharr.acestream.enabled`                             | Whether to enable the Acestream Engine sidecar container.                                                                           | `true`                            |
| `dispatcharr.acestream.image.repository`                    | The Docker repository to pull the Acestream Engine image from.                                                                      | `wafy80/acestream`                |
| `dispatcharr.acestream.image.tag`                           | The image tag to use for Acestream Engine.                                                                                          | `latest`                          |
| `dispatcharr.acestream.image.pullPolicy`                    | The logic of image pulling for Acestream Engine.                                                                                    | `IfNotPresent`                    |
| `dispatcharr.acestream.image.autoupdate.enabled`            | Whether to enable autoupdate for the Acestream Engine image.                                                                        | `false`                           |
| `dispatcharr.acestream.image.autoupdate.strategy`           | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                              |
| `dispatcharr.acestream.image.autoupdate.allowTags`          | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                              |
| `dispatcharr.acestream.image.autoupdate.ignoreTags`         | List of glob patterns to ignore specific tags.                                                                                      | `[]`                              |
| `dispatcharr.acestream.image.autoupdate.pullSecret`         | Pull secret name for private registries.                                                                                            | `""`                              |
| `dispatcharr.acestream.image.autoupdate.platforms`          | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                              |
| `dispatcharr.acestream.securityContext.privileged`          | Whether to run the acestream-engine container in privileged mode to allow multicast operations.                                     | `true`                            |
| `dispatcharr.acestream.env`                                 | Additional environment variables to add to the acestream engine container.                                                          | `{}`                              |
| `dispatcharr.acestream.resources`                           | Resource limits and requests for the Acestream Engine container.                                                                    | `{}`                              |
| `dispatcharr.service.type`                                  | The type of service to create (applies to all ports).                                                                               | `LoadBalancer`                    |
| `dispatcharr.service.http.port`                             | The port on which the Acestream HTTP service will run. Only used when acestream.enabled is true.                                    | `6878`                            |
| `dispatcharr.service.http.nodePort`                         | The nodePort to use for the Acestream HTTP service. Only used if service.type is NodePort.                                          | `""`                              |
| `dispatcharr.service.udp.port`                              | The port on which the Acestream UDP service will run. Only used when acestream.enabled is true.                                     | `8621`                            |
| `dispatcharr.service.udp.nodePort`                          | The nodePort to use for the Acestream UDP service. Only used if service.type is NodePort.                                           | `""`                              |
| `dispatcharr.service.dispatcharr.port`                      | The port on which the Dispatcharr service will run.                                                                                 | `9191`                            |
| `dispatcharr.service.dispatcharr.nodePort`                  | The nodePort to use for the Dispatcharr service. Only used if service.type is NodePort.                                             | `""`                              |
| `dispatcharr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                           |
| `dispatcharr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                              |
| `dispatcharr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                              |
| `dispatcharr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`             |
| `dispatcharr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                               |
| `dispatcharr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`          |
| `dispatcharr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                              |
| `dispatcharr.runtimeClassName`                              | The runtime class to use for the pod.                                                                                               | `""`                              |
| `dispatcharr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                           |
| `dispatcharr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                               |
| `dispatcharr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                             |
| `dispatcharr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                              |
| `dispatcharr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                              |
| `dispatcharr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                              |
| `dispatcharr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                              |
| `dispatcharr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                              |
| `dispatcharr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                            |
| `dispatcharr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                              |
| `dispatcharr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                              |
| `dispatcharr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`                   |
| `dispatcharr.persistence.size`                              | The size to use for the persistence.                                                                                                | `512Mi`                           |
| `dispatcharr.persistence.backup.enabled`                    | Whether to enable backup persistence for Dispatcharr.                                                                               | `true`                            |
| `dispatcharr.persistence.backup.storageClass`               | The storage class to use for the backup persistence.                                                                                | `cephfs`                          |
| `dispatcharr.persistence.backup.existingClaim`              | The name of an existing claim to use for the backup persistence.                                                                    | `""`                              |
| `dispatcharr.persistence.backup.accessMode`                 | The access mode to use for the backup persistence.                                                                                  | `ReadWriteMany`                   |
| `dispatcharr.persistence.backup.size`                       | The size to use for the backup persistence.                                                                                         | `512Mi`                           |
| `dispatcharr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                              |
| `dispatcharr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                              |
| `dispatcharr.gluetun.enabled`                               | Whether to enable Gluetun VPN sidecar for routing acestream traffic through a VPN.                                                  | `false`                           |
| `dispatcharr.gluetun.image.repository`                      | The Docker repository to pull the Gluetun image from.                                                                               | `qmcgaw/gluetun`                  |
| `dispatcharr.gluetun.image.tag`                             | The image tag to use for Gluetun.                                                                                                   | `v3.39.2`                         |
| `dispatcharr.gluetun.image.pullPolicy`                      | The logic of image pulling for Gluetun.                                                                                             | `IfNotPresent`                    |
| `dispatcharr.gluetun.image.autoupdate.enabled`              | Whether to enable autoupdate for the Gluetun image.                                                                                 | `false`                           |
| `dispatcharr.gluetun.image.autoupdate.strategy`             | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                                              | `""`                              |
| `dispatcharr.gluetun.image.autoupdate.allowTags`            | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                                               | `""`                              |
| `dispatcharr.gluetun.image.autoupdate.ignoreTags`           | List of glob patterns to ignore specific tags.                                                                                      | `[]`                              |
| `dispatcharr.gluetun.image.autoupdate.pullSecret`           | Pull secret name for private registries.                                                                                            | `""`                              |
| `dispatcharr.gluetun.image.autoupdate.platforms`            | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                                                    | `[]`                              |
| `dispatcharr.gluetun.env.VPN_SERVICE_PROVIDER`              | The VPN service provider (e.g., nordvpn, expressvpn, mullvad, etc.).                                                                | `""`                              |
| `dispatcharr.gluetun.env.VPN_TYPE`                          | The type of VPN protocol to use (openvpn or wireguard).                                                                             | `openvpn`                         |
| `dispatcharr.gluetun.env.OPENVPN_USER`                      | Username for OpenVPN authentication (if using OpenVPN).                                                                             | `""`                              |
| `dispatcharr.gluetun.env.OPENVPN_PASSWORD`                  | Password for OpenVPN authentication (if using OpenVPN).                                                                             | `""`                              |
| `dispatcharr.gluetun.env.SERVER_REGIONS`                    | Region for server selection (e.g., for VPN providers that use regions instead of countries).                                        | `""`                              |
| `dispatcharr.gluetun.httpProxy.enabled`                     | Whether to enable HTTP proxy server in Gluetun.                                                                                     | `true`                            |
| `dispatcharr.gluetun.httpProxy.port`                        | The port on which the HTTP proxy server will listen.                                                                                | `8888`                            |
| `dispatcharr.gluetun.shadowsocksProxy.enabled`              | Whether to enable Shadowsocks proxy server in Gluetun.                                                                              | `true`                            |
| `dispatcharr.gluetun.shadowsocksProxy.port`                 | The port on which the Shadowsocks proxy server will listen.                                                                         | `8388`                            |
| `dispatcharr.gluetun.portForwarding.enabled`                | Whether to enable VPN port forwarding for acestream (starts acestream with --port set to the forwarded port).                       | `false`                           |
| `dispatcharr.gluetun.portForwarding.provider`               | The VPN port forwarding provider (e.g., protonvpn, private internet access). Leave empty to use VPN_SERVICE_PROVIDER.               | `""`                              |
| `dispatcharr.gluetun.resources`                             | Resource limits and requests for the Gluetun container.                                                                             | `{}`                              |

### ArgoCD Image Updater parameters

| Name                           | Description                                                                    | Value    |
| ------------------------------ | ------------------------------------------------------------------------------ | -------- |
| `imageUpdater.namespace`       | Namespace where the ImageUpdater CRD will be created.                          | `argocd` |
| `imageUpdater.argocdNamespace` | Namespace where ArgoCD Applications are located.                               | `argocd` |
| `imageUpdater.applicationName` | Name or pattern of the ArgoCD Application to update. Defaults to Release name. | `""`     |
| `imageUpdater.writeBackConfig` | Write-back configuration for GitOps.                                           | `{}`     |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install example \
  --set user=example \
  --set password=example \
    raulpatel/example
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install example -f values.yaml raulpatel/example
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and helpful examples

### Shared volume and Sonarr hardlinks

The shared media volume is a shared volume between all the apps that need it. It is used to store the media files. It is created by Jellyfin.

Sonarr can use hardlinks to save space, but it needs to write to the same volume as the original files. This is where the shared media volume comes in. By design, all apps that use the shared media volume will have the same ownership and permissions, and the directories are created with init containers that set the ownership and permissions.

If you use subPath in the volumeMounts, Sonarr will not be able to create hardlinks because Kubernetes sees the subdirectory as a different filesystem and will not be able to create hardlinks.

It is highly recommended that you simply use the chart's default values for this. These are the directories that are mounted by Sonarr, Radarr, Lidarr, and qBittorrent:

- `/media/tv`
- `/media/movies`
- `/media/music`
- `/media/books`
- `/media/downloads`

### Local path provisioner scenario

To make this chart work with a local path provisioner, you must deploy the whole stack on a single node. This is because `hostPath` does not support ReadWriteMany as storage access mode. Simply use a node selector and use the same storage class:

```yaml
jellyfin:
  nodeSelector:
    kubito/hdd: enabled

  persistence:
    config:
      enabled: true
      storageClass: hdd
      size: 1Gi
    media:
      enabled: true
      storageClass: hdd
      size: 100Gi
      accessMode: ReadWriteOnce
```

### Velero Backup Configuration

The chart supports automatic backup scheduling using Velero. When enabled, Velero Schedules are created for each enabled service to backup their persistent volumes.

#### Example: Enabling Velero backups

To enable Velero backups for all services with a daily schedule at 2am and 30-day retention:

```yaml
velero:
  enabled: true
  schedule: "0 2 * * *"  # Daily at 2am
  ttl: "720h"  # 30 days retention
  snapshotVolumes: true
```

This will automatically create Velero backup schedules for all enabled services. Each service's schedule uses a priority-based system to backup exactly ONE PVC:
- If `persistence.backup.enabled=true`: backs up only the backup PVC (e.g., `radarr-backup`)
- If `persistence.backup.enabled=false` but `persistence.enabled=true`: backs up only the config PVC (e.g., `radarr-config`)
- If both are disabled: no backup schedule is created

#### Example: Custom backup schedule with storage location

```yaml
velero:
  enabled: true
  schedule: "0 3 * * 0"  # Weekly on Sundays at 3am
  ttl: "2160h"  # 90 days retention
  snapshotVolumes: true
  storageLocation: "aws-s3-backup"
  volumeSnapshotLocations:
    - "aws-ebs-snapshots"
```

### FlareSolverr environment variables

FlareSolverr can be configured using environment variables to customize its behavior. The chart now supports adding custom environment variables to the FlareSolverr pod.

#### Example: Configuring FlareSolverr with environment variables

```yaml
flaresolverr:
  enabled: true
  env:
    - name: LOG_LEVEL
      value: info
    - name: LOG_HTML
      value: "false"
    - name: CAPTCHA_SOLVER
      value: none
    - name: TZ
      value: America/New_York
```

You can also use secrets or configmaps for sensitive values:

```yaml
flaresolverr:
  enabled: true
  env:
    - name: LOG_LEVEL
      value: debug
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: flaresolverr-secret
          key: api-key
```

Common FlareSolverr environment variables:
- `LOG_LEVEL`: Set logging level (debug, info, warning, error)
- `LOG_HTML`: Enable/disable HTML logging (true/false)
- `CAPTCHA_SOLVER`: Configure captcha solver (none, hcaptcha-solver, etc.)
- `TZ`: Set timezone for the container
- `HEADLESS`: Run in headless mode (true/false)

For a complete list of available environment variables, refer to the [FlareSolverr documentation](https://github.com/FlareSolverr/FlareSolverr).

### Local storage for temporary files and downloads

Services like SABnzbd and qBittorrent can benefit from local storage for temporary files, incomplete downloads, and caching. This feature creates an emptyDir volume with a configurable size limit for temporary storage needs.

#### Example: Enabling temporary storage for SABnzbd

```yaml
sabnzbd:
  enabled: true
  localStorage:
    enabled: true
    mountPath: /local-storage
    size: 5Gi
```

#### Example: Enabling temporary storage for qBittorrent

```yaml
qbittorrent:
  enabled: true
  localStorage:
    enabled: true
    mountPath: /incomplete-downloads
    size: 10Gi
```

**Note**: The localStorage uses an emptyDir volume type, which provides a temporary directory that persists for the lifetime of the pod. When the pod is deleted or restarted, the data in this directory is lost. The `size` parameter sets the maximum size limit for the temporary storage.

#### Example: Enabling VPN Port Forwarding for qBittorrent

When using a VPN provider that supports port forwarding (e.g., ProtonVPN, Private Internet Access), you can enable automatic port forwarding to ensure qBittorrent uses the dynamically assigned port:

```yaml
qbittorrent:
  enabled: true
  gluetun:
    enabled: true
    env:
      VPN_SERVICE_PROVIDER: "private internet access"
      VPN_TYPE: "openvpn"
      OPENVPN_USER: "your-username"
      OPENVPN_PASSWORD: "your-password"
      SERVER_REGIONS: "US East"
    portForwarding:
      enabled: true
      # Optional: specify a different provider for port forwarding
      # provider: "protonvpn"
```

This configuration will:
1. Enable Gluetun VPN sidecar with your VPN provider
2. Automatically request a forwarded port from the VPN provider
3. Configure qBittorrent to use the forwarded port via gluetun's `VPN_PORT_FORWARDING_UP_COMMAND` which calls qBittorrent's API directly

**Important**: For automatic port configuration to work, you must enable "Bypass authentication for clients on localhost" in qBittorrent's Web UI settings (Settings → Web UI → Authentication). This allows gluetun to communicate with qBittorrent's API without authentication.

#### Example: Enabling VPN Port Forwarding for Acestream

Similarly, you can enable port forwarding for Acestream:

```yaml
acestream:
  enabled: true
  gluetun:
    enabled: true
    env:
      VPN_SERVICE_PROVIDER: "private internet access"
      VPN_TYPE: "openvpn"
      OPENVPN_USER: "your-username"
      OPENVPN_PASSWORD: "your-password"
      SERVER_REGIONS: "US East"
    portForwarding:
      enabled: true
```

This configuration will:
1. Enable Gluetun VPN sidecar with your VPN provider
2. Automatically request a forwarded port from the VPN provider
3. Start acestream with `--port <forwarded_port>` so P2P peers can connect directly

**Note**: VPN port forwarding is only supported by certain VPN providers. Check your VPN provider's documentation to confirm support. Common providers that support port forwarding include:
- Private Internet Access (PIA)
- ProtonVPN
- Mullvad

### Intro Skipper plugin for Jellyfin permissions fix

The Intro Skipper plugin for Jellyfin, which is really useful, will complain that it can't write to the `/usr/share/jellyfin/web/index.html` file inside the Jellyfin pod. To fix this, simply add an init container:

```yaml
jellyfin:
  extraVolumeMounts:
    - name: custom-cont-init
      mountPath: /custom-cont-init.d

  extraVolumes:
    - name: custom-cont-init
      emptyDir: {}

  extraInitContainers:
    - name: create-custom-init-script
      image: busybox
      command:
        - sh
        - -c
        - |
          cat << 'EOF' > /custom-cont-init.d/01-fix-permissions.sh
          #!/bin/sh
          chown abc /usr/share/jellyfin/web/index.html
          EOF
          chmod +x /custom-cont-init.d/01-fix-permissions.sh
      volumeMounts:
        - name: custom-cont-init
          mountPath: /custom-cont-init.d
```

## License

Copyright &copy; 2025 Raul Patel

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
