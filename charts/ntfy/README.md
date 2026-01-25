# ntfy

Simple HTTP-based pub-sub notification service. Send push notifications to your phone or desktop via PUT/POST.

## TL;DR

```console
helm repo add raulpatel https://charts.raulpatel.com
helm install ntfy raulpatel/ntfy
```

## Introduction

ntfy (pronounce: notify) is a simple HTTP-based pub-sub notification service. It allows you to send notifications to your phone or desktop via scripts from any computer, entirely without signup or cost.

## Prerequisites

- Kubernetes 1.12+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `ntfy`:

```console
helm install ntfy raulpatel/ntfy
```

The command deploys ntfy on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `ntfy` deployment:

```console
helm delete ntfy
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### ntfy parameters

| Name                                            | Description                                                                                                                         | Value                    |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                      |
| `image.repository`                              | The Docker repository to pull the image from.                                                                                       | `binwiederhier/ntfy`     |
| `image.tag`                                     | The image tag to use.                                                                                                               | `v2.16.0`                |
| `image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`           |
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
| `ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                  |
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
| `env`                                           | Environment variables to set for the container (map format).                                                                        | `{}`                     |
| `persistence.enabled`                           | Whether to enable persistence for the cache.                                                                                        | `true`                   |
| `persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `ceph-rbd`               |
| `persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                     |
| `persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`          |
| `persistence.size`                              | The size to use for the persistence.                                                                                                | `1Gi`                    |
| `persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                     |
| `persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                     |

### ArgoCD Image Updater parameters

| Name                           | Description                                                                                           | Value    |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- | -------- |
| `imageUpdater.enabled`         | Enable ArgoCD Image Updater integration. Creates an ImageUpdater CRD for automatic image updates.     | `false`  |
| `imageUpdater.namespace`       | Namespace where the ImageUpdater CRD will be created.                                                 | `argocd` |
| `imageUpdater.argocdNamespace` | Namespace where ArgoCD Applications are located.                                                      | `argocd` |
| `imageUpdater.applicationName` | Name or pattern of the ArgoCD Application to update. Defaults to Release name.                        | `""`     |
| `imageUpdater.imageAlias`      | Alias for the image in the ImageUpdater CRD. Defaults to Release name.                                | `""`     |
| `imageUpdater.updateStrategy`  | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest).                | `semver` |
| `imageUpdater.forceUpdate`     | Force update even if image is not currently deployed.                                                 | `false`  |
| `imageUpdater.allowTags`       | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any").                 | `""`     |
| `imageUpdater.ignoreTags`      | List of glob patterns to ignore specific tags.                                                        | `[]`     |
| `imageUpdater.pullSecret`      | Reference to secret for private registry authentication.                                              | `""`     |
| `imageUpdater.platforms`       | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]).                                      | `[]`     |
| `imageUpdater.helm`            | Helm-specific configuration for parameter names (e.g., {name: "image.repository", tag: "image.tag"}). | `{}`     |
| `imageUpdater.kustomize`       | Kustomize-specific configuration (e.g., {name: "original/image"}).                                    | `{}`     |
| `imageUpdater.writeBackConfig` | Write-back configuration for GitOps.                                                                  | `{}`     |

## Configuration and Environment Variables

The ntfy server can be configured using environment variables. See the [ntfy configuration documentation](https://docs.ntfy.sh/config/) for all available options.

Example values to set environment variables:

```yaml
env:
  TZ: "UTC"
  NTFY_BASE_URL: "https://ntfy.example.com"
  NTFY_CACHE_FILE: "/var/cache/ntfy/cache.db"
```

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install ntfy \
  --set service.type=ClusterIP \
  --set ingress.enabled=true \
    raulpatel/ntfy
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install ntfy -f values.yaml raulpatel/ntfy
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

The chart mounts a Persistent Volume at `/var/cache/ntfy` for the message cache. The volume is created using dynamic volume provisioning by default. An existing PersistentVolumeClaim can also be defined.

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
