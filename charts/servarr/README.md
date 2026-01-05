# Servarr

A Helm chart for deploying the Servarr suite of applications - including Sonarr, Radarr, Lidarr, Prowlarr, and Jellyfin. These applications provide media management, automation, and streaming capabilities for TV shows, movies, music, books, and more. The chart also supports enabling additional services like Bazarr for subtitle management, FlareSolverr for handling anti-bot protections, Jellyseerr for media requests, qBittorrent for downloading, and other complementary applications to create a complete media server stack.

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
| `media.size`            | The size to use for the config.                                                        | `10Gi`          |
| `media.labels`          | Additional labels to add to the config.                                                | `{}`            |
| `media.annotations`     | Additional annotations to add to the config.                                           | `{}`            |
| `media.paths.tv`        | The subpath for TV shows within the media PVC. Don't use leading or trailing slashes.  | `tv`            |
| `media.paths.movies`    | The subpath for movies within the media PVC. Don't use leading or trailing slashes.    | `movies`        |
| `media.paths.music`     | The subpath for music within the media PVC. Don't use leading or trailing slashes.     | `music`         |
| `media.paths.downloads` | The subpath for downloads within the media PVC. Don't use leading or trailing slashes. | `downloads`     |

### Jellyfin parameters

| Name                                            | Description                                                                                                                                                                                                        | Value                          |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------ |
| `jellyfin.enabled`                              | Whether to enable Jellyfin.                                                                                                                                                                                        | `true`                         |
| `jellyfin.replicaCount`                         | The number of replicas to deploy.                                                                                                                                                                                  | `1`                            |
| `jellyfin.image.repository`                     | The Docker repository to pull the image from.                                                                                                                                                                      | `lscr.io/linuxserver/jellyfin` |
| `jellyfin.image.tag`                            | The image tag to use.                                                                                                                                                                                              | `10.11.5`                      |
| `jellyfin.image.pullPolicy`                     | The logic of image pulling.                                                                                                                                                                                        | `IfNotPresent`                 |
| `jellyfin.enableDLNA`                           | Whether to enable DLNA which requires the pod to be attached to the host network in order to be useful - this can break things like ingress to the service https://jellyfin.org/docs/general/networking/dlna.html. | `false`                        |
| `jellyfin.service.type`                         | The type of service to create.                                                                                                                                                                                     | `LoadBalancer`                 |
| `jellyfin.service.port`                         | The port on which the service will run.                                                                                                                                                                            | `8096`                         |
| `jellyfin.service.nodePort`                     | The nodePort to use for the service. Only used if service.type is NodePort.                                                                                                                                        | `""`                           |
| `jellyfin.service.annotations`                  | Additional annotations to add to the service.                                                                                                                                                                      | `{}`                           |
| `jellyfin.service.labels`                       | Additional labels to add to the service.                                                                                                                                                                           | `{}`                           |
| `jellyfin.service.loadBalancerIP`               | The IP address to use for the LoadBalancer service. Only used if service.type is LoadBalancer.                                                                                                                     | `""`                           |
| `jellyfin.service.loadBalancerSourceRanges`     | The source ranges to use for the LoadBalancer service. Only used if service.type is LoadBalancer.                                                                                                                  | `[]`                           |
| `jellyfin.service.externalTrafficPolicy`        | The external traffic policy to use for the service. Set to either Cluster or Local.                                                                                                                                | `nil`                          |
| `jellyfin.ingress.enabled`                      | Whether to create an ingress for the service.                                                                                                                                                                      | `false`                        |
| `jellyfin.ingress.labels`                       | Additional labels to add to the ingress.                                                                                                                                                                           | `{}`                           |
| `jellyfin.ingress.annotations`                  | Additional annotations to add to the ingress.                                                                                                                                                                      | `{}`                           |
| `jellyfin.ingress.path`                         | The path to use for the ingress.                                                                                                                                                                                   | `/`                            |
| `jellyfin.ingress.hosts`                        | The hosts to use for the ingress.                                                                                                                                                                                  | `["chart-example.local"]`      |
| `jellyfin.ingress.tls`                          | The TLS configuration for the ingress.                                                                                                                                                                             | `[]`                           |
| `jellyfin.persistence.enabled`                  | Whether to enable persistence for the config.                                                                                                                                                                      | `true`                         |
| `jellyfin.persistence.storageClass`             | The storage class to use for the config.                                                                                                                                                                           | `""`                           |
| `jellyfin.persistence.existingClaim`            | The name of an existing claim to use for the config.                                                                                                                                                               | `""`                           |
| `jellyfin.persistence.accessMode`               | The access mode to use for the config.                                                                                                                                                                             | `ReadWriteOnce`                |
| `jellyfin.persistence.size`                     | The size to use for the config.                                                                                                                                                                                    | `1Gi`                          |
| `jellyfin.persistence.labels`                   | Additional labels to add to the config.                                                                                                                                                                            | `{}`                           |
| `jellyfin.persistence.annotations`              | Additional annotations to add to the config.                                                                                                                                                                       | `{}`                           |
| `jellyfin.persistence.extraExistingClaimMounts` | Additional existing claim mounts to add to the pod.                                                                                                                                                                | `[]`                           |
| `jellyfin.resources`                            | The resources to use for the pod.                                                                                                                                                                                  | `{}`                           |
| `jellyfin.nodeSelector`                         | The node selector to use for the pod.                                                                                                                                                                              | `{}`                           |
| `jellyfin.tolerations`                          | The tolerations to use for the pod.                                                                                                                                                                                | `[]`                           |
| `jellyfin.affinity`                             | The affinity to use for the pod.                                                                                                                                                                                   | `{}`                           |
| `jellyfin.extraVolumes`                         | Additional volumes to add to the pod.                                                                                                                                                                              | `[]`                           |
| `jellyfin.extraVolumeMounts`                    | Additional volume mounts to add to the pod.                                                                                                                                                                        | `[]`                           |
| `jellyfin.extraEnvVars`                         | Additional environment variables to add to the pod.                                                                                                                                                                | `[]`                           |
| `jellyfin.extraInitContainers`                  | Additional init containers to add to the pod.                                                                                                                                                                      | `{}`                           |
| `jellyfin.extraContainers`                      | Additional sidecar containers to add to the pod.                                                                                                                                                                   | `{}`                           |
| `jellyfin.podSecurityContext`                   | The security context to use for the pod.                                                                                                                                                                           | `{}`                           |
| `jellyfin.securityContext`                      | The security context to use for the container.                                                                                                                                                                     | `{}`                           |
| `jellyfin.livenessProbe.enabled`                | Whether to enable the liveness probe.                                                                                                                                                                              | `false`                        |
| `jellyfin.livenessProbe.failureThreshold`       | The number of times to retry before giving up.                                                                                                                                                                     | `3`                            |
| `jellyfin.livenessProbe.initialDelaySeconds`    | The number of seconds to wait before starting the probe.                                                                                                                                                           | `10`                           |
| `jellyfin.livenessProbe.periodSeconds`          | The number of seconds between probe attempts.                                                                                                                                                                      | `10`                           |
| `jellyfin.livenessProbe.successThreshold`       | The minimum consecutive successes required to consider the probe successful.                                                                                                                                       | `1`                            |
| `jellyfin.livenessProbe.timeoutSeconds`         | The number of seconds after which the probe times out.                                                                                                                                                             | `1`                            |
| `jellyfin.readinessProbe.enabled`               | Whether to enable the readiness probe.                                                                                                                                                                             | `false`                        |
| `jellyfin.readinessProbe.failureThreshold`      | The number of times to retry before giving up.                                                                                                                                                                     | `3`                            |
| `jellyfin.readinessProbe.initialDelaySeconds`   | The number of seconds to wait before starting the probe.                                                                                                                                                           | `10`                           |
| `jellyfin.readinessProbe.periodSeconds`         | The number of seconds between probe attempts.                                                                                                                                                                      | `10`                           |
| `jellyfin.readinessProbe.successThreshold`      | The minimum consecutive successes required to consider the probe successful.                                                                                                                                       | `1`                            |
| `jellyfin.readinessProbe.timeoutSeconds`        | The number of seconds after which the probe times out.                                                                                                                                                             | `1`                            |

### Sonarr parameters

| Name                                                   | Description                                                                                                                         | Value                        |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `sonarr.enabled`                                       | Whether to enable Sonarr.                                                                                                           | `true`                       |
| `sonarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                          |
| `sonarr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/sonarr` |
| `sonarr.image.tag`                                     | The image tag to use.                                                                                                               | `4.0.16`                     |
| `sonarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`               |
| `sonarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                         |
| `sonarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                   |
| `sonarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                       |
| `sonarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                         |
| `sonarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                         |
| `sonarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                         |
| `sonarr.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                         |
| `sonarr.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                         |
| `sonarr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                         |
| `sonarr.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`               |
| `sonarr.service.port`                                  | The port on which the service will run.                                                                                             | `80`                         |
| `sonarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                         |
| `sonarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                      |
| `sonarr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                         |
| `sonarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                         |
| `sonarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`        |
| `sonarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                          |
| `sonarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`     |
| `sonarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                         |
| `sonarr.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                         |
| `sonarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                      |
| `sonarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                          |
| `sonarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                        |
| `sonarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                         |
| `sonarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                         |
| `sonarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                         |
| `sonarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                         |
| `sonarr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                         |
| `sonarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                       |
| `sonarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                       |
| `sonarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`              |
| `sonarr.env.UMASK`                                     | The umask to use for the pod.                                                                                                       | `002`                        |
| `sonarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                       |
| `sonarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                         |
| `sonarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                         |
| `sonarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`              |
| `sonarr.persistence.size`                              | The size to use for the persistence.                                                                                                | `800Mi`                      |
| `sonarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                         |
| `sonarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                         |

### qBittorrent parameters

| Name                                                        | Description                                                                                                                         | Value                             |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `qbittorrent.enabled`                                       | Whether to enable qBittorrent.                                                                                                      | `true`                            |
| `qbittorrent.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                               |
| `qbittorrent.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/qbittorrent` |
| `qbittorrent.image.tag`                                     | The image tag to use.                                                                                                               | `5.1.4`                           |
| `qbittorrent.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                    |
| `qbittorrent.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                              |
| `qbittorrent.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                        |
| `qbittorrent.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                            |
| `qbittorrent.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                              |
| `qbittorrent.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                              |
| `qbittorrent.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                              |
| `qbittorrent.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                              |
| `qbittorrent.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                              |
| `qbittorrent.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                              |
| `qbittorrent.service.web.type`                              | The type of service to create.                                                                                                      | `LoadBalancer`                    |
| `qbittorrent.service.web.port`                              | The port on which the service will run.                                                                                             | `8080`                            |
| `qbittorrent.service.web.nodePort`                          | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                              |
| `qbittorrent.service.bt.type`                               | The type of service to create.                                                                                                      | `LoadBalancer`                    |
| `qbittorrent.service.bt.port`                               | The port on which the service will run.                                                                                             | `6881`                            |
| `qbittorrent.service.bt.nodePort`                           | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                              |
| `qbittorrent.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                           |
| `qbittorrent.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                              |
| `qbittorrent.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                              |
| `qbittorrent.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`             |
| `qbittorrent.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                               |
| `qbittorrent.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`          |
| `qbittorrent.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                              |
| `qbittorrent.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                              |
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
| `qbittorrent.persistence.size`                              | The size to use for the persistence.                                                                                                | `800Mi`                           |
| `qbittorrent.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                              |
| `qbittorrent.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                              |
| `qbittorrent.localStorage.enabled`                          | Whether to enable local storage for temporary files and downloads.                                                                  | `false`                           |
| `qbittorrent.localStorage.mountPath`                        | The mount path for the local storage.                                                                                               | `/local-storage`                  |
| `qbittorrent.localStorage.size`                             | The size limit for the temporary storage (emptyDir).                                                                                | `1Gi`                             |
| `qbittorrent.gluetun.enabled`                               | Whether to enable Gluetun VPN sidecar for routing qBittorrent traffic through a VPN.                                                | `false`                           |
| `qbittorrent.gluetun.image.repository`                      | The Docker repository to pull the Gluetun image from.                                                                               | `qmcgaw/gluetun`                  |
| `qbittorrent.gluetun.image.tag`                             | The image tag to use for Gluetun.                                                                                                   | `v3.39.2`                         |
| `qbittorrent.gluetun.image.pullPolicy`                      | The logic of image pulling for Gluetun.                                                                                             | `IfNotPresent`                    |
| `qbittorrent.gluetun.securityContext.capabilities.add`      | Security capabilities for the Gluetun container. NET_ADMIN is required for VPN functionality.                                       | `["NET_ADMIN"]`                   |
| `qbittorrent.gluetun.env.VPN_SERVICE_PROVIDER`              | The VPN service provider (e.g., nordvpn, expressvpn, mullvad, etc.).                                                                | `""`                              |
| `qbittorrent.gluetun.env.VPN_TYPE`                          | The type of VPN protocol to use (openvpn or wireguard).                                                                             | `openvpn`                         |
| `qbittorrent.gluetun.env.OPENVPN_USER`                      | Username for OpenVPN authentication (if using OpenVPN).                                                                             | `""`                              |
| `qbittorrent.gluetun.env.OPENVPN_PASSWORD`                  | Password for OpenVPN authentication (if using OpenVPN).                                                                             | `""`                              |
| `qbittorrent.gluetun.env.SERVER_COUNTRIES`                  | Comma-separated list of server countries to use.                                                                                    | `""`                              |
| `qbittorrent.gluetun.env.SERVER_REGION`                     | Region for server selection (e.g., for VPN providers that use regions instead of countries).                                        | `""`                              |
| `qbittorrent.gluetun.env.SERVER_NAMES`                      | Comma-separated list of specific server names to use.                                                                               | `""`                              |
| `qbittorrent.gluetun.env.SERVER_HOSTNAMES`                  | Comma-separated list of specific server hostnames to use.                                                                           | `""`                              |
| `qbittorrent.gluetun.env.FIREWALL_OUTBOUND_SUBNETS`         | Comma-separated list of subnets to allow outbound traffic to (e.g., local network).                                                 | `""`                              |
| `qbittorrent.gluetun.httpProxy.enabled`                     | Whether to enable HTTP proxy server in Gluetun.                                                                                     | `true`                            |
| `qbittorrent.gluetun.httpProxy.port`                        | The port on which the HTTP proxy server will listen.                                                                                | `8888`                            |
| `qbittorrent.gluetun.shadowsocksProxy.enabled`              | Whether to enable Shadowsocks proxy server in Gluetun.                                                                              | `true`                            |
| `qbittorrent.gluetun.shadowsocksProxy.port`                 | The port on which the Shadowsocks proxy server will listen.                                                                         | `8388`                            |
| `qbittorrent.gluetun.resources`                             | Resource limits and requests for the Gluetun container.                                                                             | `{}`                              |

### Prowlarr parameters

| Name                                                     | Description                                                                                                                         | Value                          |
| -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| `prowlarr.enabled`                                       | Whether to enable Prowlarr.                                                                                                         | `true`                         |
| `prowlarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                            |
| `prowlarr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/prowlarr` |
| `prowlarr.image.tag`                                     | The image tag to use.                                                                                                               | `2.3.0`                        |
| `prowlarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                 |
| `prowlarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                           |
| `prowlarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                     |
| `prowlarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                         |
| `prowlarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                           |
| `prowlarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                           |
| `prowlarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                           |
| `prowlarr.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                           |
| `prowlarr.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                           |
| `prowlarr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                           |
| `prowlarr.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`                 |
| `prowlarr.service.port`                                  | The port on which the service will run.                                                                                             | `9696`                         |
| `prowlarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                           |
| `prowlarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                        |
| `prowlarr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                           |
| `prowlarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                           |
| `prowlarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`          |
| `prowlarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                            |
| `prowlarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`       |
| `prowlarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                           |
| `prowlarr.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                           |
| `prowlarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                        |
| `prowlarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                            |
| `prowlarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                          |
| `prowlarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                           |
| `prowlarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                           |
| `prowlarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                           |
| `prowlarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                           |
| `prowlarr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                           |
| `prowlarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                         |
| `prowlarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                         |
| `prowlarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`                |
| `prowlarr.env.UMASK`                                     | The umask to use for the pod.                                                                                                       | `002`                          |
| `prowlarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                         |
| `prowlarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                           |
| `prowlarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                           |
| `prowlarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`                |
| `prowlarr.persistence.size`                              | The size to use for the persistence.                                                                                                | `800Mi`                        |
| `prowlarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                           |
| `prowlarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                           |

### FlareSolverr parameters

| Name                                                         | Description                                                                                                                         | Value                               |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `flaresolverr.enabled`                                       | Whether to enable FlareSolverr.                                                                                                     | `true`                              |
| `flaresolverr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                                 |
| `flaresolverr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `ghcr.io/flaresolverr/flaresolverr` |
| `flaresolverr.image.tag`                                     | The image tag to use.                                                                                                               | `v3.3.21`                           |
| `flaresolverr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                      |
| `flaresolverr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                                |
| `flaresolverr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                          |
| `flaresolverr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                              |
| `flaresolverr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                                |
| `flaresolverr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                                |
| `flaresolverr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                                |
| `flaresolverr.podSecurityContext.fsGroup`                    | The group ID to use for the pod.                                                                                                    | `1000`                              |
| `flaresolverr.podSecurityContext.fsGroupChangePolicy`        | The policy to use for the pod.                                                                                                      | `OnRootMismatch`                    |
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
| `flaresolverr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                             |
| `flaresolverr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                                 |
| `flaresolverr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                               |
| `flaresolverr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                                |
| `flaresolverr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                                |
| `flaresolverr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                                |
| `flaresolverr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                                |
| `flaresolverr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                                |

### Jellyseerr parameters

| Name                                                       | Description                                                                                                                         | Value                              |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `jellyseerr.enabled`                                       | Whether to enable Jellyseerr.                                                                                                       | `true`                             |
| `jellyseerr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                                |
| `jellyseerr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `docker.io/fallenbagel/jellyseerr` |
| `jellyseerr.image.tag`                                     | The image tag to use.                                                                                                               | `2.7.3`                            |
| `jellyseerr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                     |
| `jellyseerr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                               |
| `jellyseerr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                         |
| `jellyseerr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                             |
| `jellyseerr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                               |
| `jellyseerr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                               |
| `jellyseerr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                               |
| `jellyseerr.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                               |
| `jellyseerr.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                               |
| `jellyseerr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                               |
| `jellyseerr.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`                     |
| `jellyseerr.service.port`                                  | The port on which the service will run.                                                                                             | `5055`                             |
| `jellyseerr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                               |
| `jellyseerr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                            |
| `jellyseerr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                               |
| `jellyseerr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                               |
| `jellyseerr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`              |
| `jellyseerr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                                |
| `jellyseerr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`           |
| `jellyseerr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                               |
| `jellyseerr.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                               |
| `jellyseerr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                            |
| `jellyseerr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                                |
| `jellyseerr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                              |
| `jellyseerr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                               |
| `jellyseerr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                               |
| `jellyseerr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                               |
| `jellyseerr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                               |
| `jellyseerr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                               |
| `jellyseerr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                             |
| `jellyseerr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                               |
| `jellyseerr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                               |
| `jellyseerr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`                    |
| `jellyseerr.persistence.size`                              | The size to use for the persistence.                                                                                                | `800Mi`                            |
| `jellyseerr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                               |
| `jellyseerr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                               |

### Bazarr parameters

| Name                                                   | Description                                                                                                                         | Value                        |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `bazarr.enabled`                                       | Whether to enable Bazarr.                                                                                                           | `true`                       |
| `bazarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                          |
| `bazarr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/bazarr` |
| `bazarr.image.tag`                                     | The image tag to use.                                                                                                               | `1.5.3`                      |
| `bazarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`               |
| `bazarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                         |
| `bazarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                   |
| `bazarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                       |
| `bazarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                         |
| `bazarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                         |
| `bazarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                         |
| `bazarr.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                         |
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
| `bazarr.persistence.size`                              | The size to use for the persistence.                                                                                                | `800Mi`                      |
| `bazarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                         |
| `bazarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                         |

### Radarr parameters

| Name                                                   | Description                                                                                                                         | Value                        |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `radarr.enabled`                                       | Whether to enable Radarr.                                                                                                           | `true`                       |
| `radarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                          |
| `radarr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/radarr` |
| `radarr.image.tag`                                     | The image tag to use.                                                                                                               | `6.0.4`                      |
| `radarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`               |
| `radarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                         |
| `radarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                   |
| `radarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                       |
| `radarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                         |
| `radarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                         |
| `radarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                         |
| `radarr.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                         |
| `radarr.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                         |
| `radarr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                         |
| `radarr.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`               |
| `radarr.service.port`                                  | The port on which the service will run.                                                                                             | `7878`                       |
| `radarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                         |
| `radarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                      |
| `radarr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                         |
| `radarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                         |
| `radarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`        |
| `radarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                          |
| `radarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`     |
| `radarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                         |
| `radarr.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                         |
| `radarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                      |
| `radarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                          |
| `radarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                        |
| `radarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                         |
| `radarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                         |
| `radarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                         |
| `radarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                         |
| `radarr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                         |
| `radarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                       |
| `radarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                       |
| `radarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`              |
| `radarr.env.UMASK`                                     | The umask to use for the pod.                                                                                                       | `002`                        |
| `radarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                       |
| `radarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                         |
| `radarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                         |
| `radarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`              |
| `radarr.persistence.size`                              | The size to use for the persistence.                                                                                                | `800Mi`                      |
| `radarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                         |
| `radarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                         |

### Lidarr parameters

| Name                                                   | Description                                                                                                                         | Value                        |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `lidarr.enabled`                                       | Whether to enable Lidarr.                                                                                                           | `true`                       |
| `lidarr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                          |
| `lidarr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/lidarr` |
| `lidarr.image.tag`                                     | The image tag to use.                                                                                                               | `3.1.0`                      |
| `lidarr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`               |
| `lidarr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                         |
| `lidarr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                   |
| `lidarr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                       |
| `lidarr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                         |
| `lidarr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                         |
| `lidarr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                         |
| `lidarr.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                         |
| `lidarr.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                         |
| `lidarr.initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                         |
| `lidarr.service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`               |
| `lidarr.service.port`                                  | The port on which the service will run.                                                                                             | `8686`                       |
| `lidarr.service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                         |
| `lidarr.ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                      |
| `lidarr.ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                         |
| `lidarr.ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                         |
| `lidarr.ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`        |
| `lidarr.ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                          |
| `lidarr.ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`     |
| `lidarr.ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                         |
| `lidarr.resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                         |
| `lidarr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                      |
| `lidarr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                          |
| `lidarr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                        |
| `lidarr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                         |
| `lidarr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                         |
| `lidarr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                         |
| `lidarr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                         |
| `lidarr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                         |
| `lidarr.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                       |
| `lidarr.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                       |
| `lidarr.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`              |
| `lidarr.env.UMASK`                                     | The umask to use for the pod.                                                                                                       | `002`                        |
| `lidarr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                       |
| `lidarr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                         |
| `lidarr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                         |
| `lidarr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`              |
| `lidarr.persistence.size`                              | The size to use for the persistence.                                                                                                | `800Mi`                      |
| `lidarr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                         |
| `lidarr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                         |

### Cleanuparr parameters

| Name                                                       | Description                                                                                                                         | Value                           |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `cleanuparr.enabled`                                       | Whether to enable Cleanuparr.                                                                                                       | `false`                         |
| `cleanuparr.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                             |
| `cleanuparr.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `ghcr.io/cleanuparr/cleanuparr` |
| `cleanuparr.image.tag`                                     | The image tag to use.                                                                                                               | `latest`                        |
| `cleanuparr.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                  |
| `cleanuparr.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                            |
| `cleanuparr.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                      |
| `cleanuparr.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                          |
| `cleanuparr.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                            |
| `cleanuparr.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                            |
| `cleanuparr.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                            |
| `cleanuparr.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                            |
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
| `cleanuparr.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                         |
| `cleanuparr.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                             |
| `cleanuparr.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                           |
| `cleanuparr.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                            |
| `cleanuparr.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                            |
| `cleanuparr.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                            |
| `cleanuparr.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                            |
| `cleanuparr.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                            |
| `cleanuparr.env.BASE_PATH`                                 | The base path to use for the service.                                                                                               | `""`                            |
| `cleanuparr.env.PORT`                                      | The port on which the service will run.                                                                                             | `11011`                         |
| `cleanuparr.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                          |
| `cleanuparr.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                          |
| `cleanuparr.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`                 |
| `cleanuparr.env.UMASK`                                     | The umask to use for the pod.                                                                                                       | `002`                           |
| `cleanuparr.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `false`                         |
| `cleanuparr.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                            |
| `cleanuparr.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                            |
| `cleanuparr.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`                 |
| `cleanuparr.persistence.size`                              | The size to use for the persistence.                                                                                                | `100Mi`                         |
| `cleanuparr.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                            |
| `cleanuparr.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                            |

### SABnzbd parameters

| Name                                                    | Description                                                                                                                         | Value                         |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| `sabnzbd.enabled`                                       | Whether to enable SABnzbd.                                                                                                          | `false`                       |
| `sabnzbd.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                           |
| `sabnzbd.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/sabnzbd` |
| `sabnzbd.image.tag`                                     | The image tag to use.                                                                                                               | `4.5.5`                       |
| `sabnzbd.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                |
| `sabnzbd.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                          |
| `sabnzbd.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                    |
| `sabnzbd.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                        |
| `sabnzbd.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                          |
| `sabnzbd.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                          |
| `sabnzbd.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                          |
| `sabnzbd.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                          |
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
| `sabnzbd.persistence.size`                              | The size to use for the persistence.                                                                                                | `800Mi`                       |
| `sabnzbd.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                          |
| `sabnzbd.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                          |
| `sabnzbd.localStorage.enabled`                          | Whether to enable local storage for temporary files and downloads.                                                                  | `false`                       |
| `sabnzbd.localStorage.mountPath`                        | The mount path for the local storage.                                                                                               | `/local-storage`              |
| `sabnzbd.localStorage.size`                             | The size limit for the temporary storage (emptyDir).                                                                                | `1Gi`                         |

### Plex parameters

| Name                                                 | Description                                                                                                                         | Value                      |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `plex.enabled`                                       | Whether to enable Plex.                                                                                                             | `false`                    |
| `plex.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                        |
| `plex.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/plex` |
| `plex.image.tag`                                     | The image tag to use.                                                                                                               | `1.42.2`                   |
| `plex.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`             |
| `plex.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                       |
| `plex.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                 |
| `plex.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                     |
| `plex.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                       |
| `plex.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                       |
| `plex.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                       |
| `plex.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                       |
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
| `plex.persistence.size`                              | The size to use for the persistence.                                                                                                | `1Gi`                      |
| `plex.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                       |
| `plex.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                       |

### Emby parameters

| Name                                                 | Description                                                                                                                         | Value                      |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `emby.enabled`                                       | Whether to enable Emby.                                                                                                             | `false`                    |
| `emby.replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                        |
| `emby.image.repository`                              | The Docker repository to pull the image from.                                                                                       | `lscr.io/linuxserver/emby` |
| `emby.image.tag`                                     | The image tag to use.                                                                                                               | `4.9.1`                    |
| `emby.image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`             |
| `emby.imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                       |
| `emby.deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                 |
| `emby.serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                     |
| `emby.serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                       |
| `emby.serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                       |
| `emby.podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                       |
| `emby.podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                       |
| `emby.securityContext`                               | The security context to use for the container.                                                                                      | `{}`                       |
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
| `emby.autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                    |
| `emby.autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                        |
| `emby.autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                      |
| `emby.autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                       |
| `emby.autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                       |
| `emby.nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                       |
| `emby.tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                       |
| `emby.affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                       |
| `emby.env.PUID`                                      | The user ID to use for the pod.                                                                                                     | `1000`                     |
| `emby.env.PGID`                                      | The group ID to use for the pod.                                                                                                    | `1000`                     |
| `emby.env.TZ`                                        | The timezone to use for the pod.                                                                                                    | `Europe/London`            |
| `emby.persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                     |
| `emby.persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                       |
| `emby.persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                       |
| `emby.persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`            |
| `emby.persistence.size`                              | The size to use for the persistence.                                                                                                | `1Gi`                      |
| `emby.persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                       |
| `emby.persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                       |

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

### Using Gluetun VPN with qBittorrent and proxy services

The qBittorrent deployment supports an optional Gluetun VPN sidecar container that can route qBittorrent traffic through a VPN connection. Additionally, Gluetun can expose HTTP and Shadowsocks proxy servers that other applications (like Prowlarr, Sonarr, Radarr, etc.) can use to route their traffic through the VPN.

#### Enabling Gluetun VPN

To enable Gluetun with qBittorrent:

```yaml
qbittorrent:
  enabled: true
  gluetun:
    enabled: true
    env:
      VPN_SERVICE_PROVIDER: "nordvpn"  # or your VPN provider
      VPN_TYPE: "openvpn"
      OPENVPN_USER: "your-username"
      OPENVPN_PASSWORD: "your-password"
      SERVER_COUNTRIES: "United States"
    httpProxy:
      enabled: true
      port: 8888
    shadowsocksProxy:
      enabled: true
      port: 8388
```

#### Configuring other services to use Gluetun proxies

When Gluetun proxies are enabled, they are accessible via Kubernetes services with the following naming pattern:

- **HTTP Proxy**: `<release-name>-gluetun-http.<namespace>.svc.cluster.local:<port>`
- **Shadowsocks Proxy**: `<release-name>-gluetun-shadowsocks.<namespace>.svc.cluster.local:<port>`

**Example**: If you installed the chart with release name `servarr` in the `media` namespace with default ports, the proxy addresses would be:

- **HTTP Proxy**: `servarr-gluetun-http.media.svc.cluster.local:8888`
- **Shadowsocks Proxy**: `servarr-gluetun-shadowsocks.media.svc.cluster.local:8388`

To configure Prowlarr (or other *arr applications) to use the Shadowsocks proxy:

1. In Prowlarr, go to **Settings** → **Indexers** → **Add Indexer Proxy**
2. Select **Socks5** as the proxy type (Shadowsocks uses SOCKS5 protocol)
3. Enter the proxy hostname: `servarr-gluetun-shadowsocks.media.svc.cluster.local` (replace `servarr` with your release name and `media` with your namespace)
4. Enter the port: `8388` (or your configured shadowsocksProxy.port)
5. Test and save the configuration

**Important**: Make sure to use `cluster.local` (not `cluster.loal`) as the cluster domain suffix in the hostname.

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
