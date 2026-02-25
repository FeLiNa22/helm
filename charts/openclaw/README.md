# OpenClaw

OpenClaw is a personal AI assistant you run on your own devices. It answers you on the channels you already use (WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, WebChat).

## TL;DR

```console
helm repo add raulpatel https://charts.raulpatel.com
helm install openclaw raulpatel/openclaw \
  --set openclaw.gatewayToken.value="your-gateway-token"
```

## Introduction

This chart deploys the OpenClaw Gateway on a Kubernetes cluster using the Helm package manager. The Gateway is the control plane for OpenClaw, handling messaging channels, AI model routing, and agent tool execution.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)
- An OpenClaw gateway token (generated during `openclaw onboard`)

## Installing the Chart

To install the chart with the release name `openclaw`:

```console
helm install openclaw raulpatel/openclaw \
  --set openclaw.gatewayToken.value="your-gateway-token"
```

Or with an existing secret:

```console
kubectl create secret generic openclaw-token \
  --from-literal=OPENCLAW_GATEWAY_TOKEN="your-gateway-token"

helm install openclaw raulpatel/openclaw \
  --set openclaw.gatewayToken.secretName="openclaw-token"
```

The command deploys OpenClaw on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `openclaw` deployment:

```console
helm delete openclaw
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Image parameters

| Name                          | Description                                                                            | Value                        |
| ----------------------------- | -------------------------------------------------------------------------------------- | ---------------------------- |
| `image.repository`            | The Docker repository to pull the image from.                                          | `ghcr.io/openclaw/openclaw`  |
| `image.tag`                   | The image tag to use.                                                                  | `main`                       |
| `image.pullPolicy`            | The logic of image pulling.                                                            | `IfNotPresent`               |
| `image.autoupdate.enabled`    | Enable automatic image updates via ArgoCD Image Updater.                               | `false`                      |
| `image.autoupdate.strategy`   | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest). | `""`                         |
| `image.autoupdate.allowTags`  | Match function for allowed tags.                                                       | `""`                         |
| `image.autoupdate.ignoreTags` | List of glob patterns to ignore specific tags.                                         | `[]`                         |
| `image.autoupdate.pullSecret` | Reference to secret for private registry authentication.                               | `""`                         |
| `image.autoupdate.platforms`  | List of target platforms.                                                              | `[]`                         |

### Deployment parameters

| Name                                               | Description                                                                         | Value       |
| -------------------------------------------------- | ----------------------------------------------------------------------------------- | ----------- |
| `replicaCount`                                     | The number of replicas to deploy.                                                   | `1`         |
| `openclaw.port`                                    | Port on which the OpenClaw gateway will listen.                                     | `18789`     |
| `openclaw.bridgePort`                              | Port for the OpenClaw bridge/WebSocket relay.                                       | `18790`     |
| `openclaw.bind`                                    | Gateway bind mode. Use 'lan' for container/Kubernetes deployments.                  | `lan`       |
| `openclaw.gatewayToken.secretName`                 | Existing secret name containing the gateway token (mutually exclusive with value).  | `""`        |
| `openclaw.gatewayToken.value`                      | Direct gateway token value to create a secret (mutually exclusive with secretName). | `""`        |
| `openclaw.persistence.config.enabled`              | Whether to enable persistence for OpenClaw config.                                  | `true`      |
| `openclaw.persistence.config.storageClass`         | The storage class to use for config persistence.                                    | `""`        |
| `openclaw.persistence.config.size`                 | Size of the config persistence volume.                                              | `512Mi`     |
| `openclaw.persistence.config.existingClaim`        | Use an existing PVC for config persistence.                                         | `""`        |
| `openclaw.persistence.workspace.enabled`           | Whether to enable persistence for the agent workspace.                              | `true`      |
| `openclaw.persistence.workspace.storageClass`      | The storage class to use for workspace persistence.                                 | `""`        |
| `openclaw.persistence.workspace.size`              | Size of the workspace persistence volume.                                           | `1Gi`       |
| `openclaw.persistence.workspace.existingClaim`     | Use an existing PVC for workspace persistence.                                      | `""`        |
| `openclaw.resources`                               | Resource limits and requests for the OpenClaw container.                            | `{}`        |
| `openclaw.nodeSelector`                            | Optional node selector for pod scheduling.                                          | `{}`        |
| `openclaw.tolerations`                             | Tolerations for pod scheduling.                                                     | `[]`        |
| `openclaw.affinity`                                | Affinity rules for pod scheduling.                                                  | `{}`        |

### Velero Backup Schedule parameters

| Name                                | Description                                                        | Value       |
| ----------------------------------- | ------------------------------------------------------------------ | ----------- |
| `velero.enabled`                    | Whether to enable Velero backup schedules                          | `false`     |
| `velero.namespace`                  | The namespace where Velero is deployed                             | `velero`    |
| `velero.schedule`                   | The cron schedule for Velero backups                               | `0 2 * * *` |
| `velero.ttl`                        | Time to live for backups                                           | `168h`      |
| `velero.includeClusterResources`    | Whether to include cluster-scoped resources in backup              | `false`     |
| `velero.snapshotVolumes`            | Whether to take volume snapshots                                   | `true`      |
| `velero.defaultVolumesToFsBackup`   | Whether to use file system backup for volumes by default           | `false`     |
| `velero.storageLocation`            | The storage location for backups (leave empty for default)         | `""`        |
| `velero.volumeSnapshotLocations`    | The volume snapshot locations (leave empty for default)            | `[]`        |
| `velero.labelSelector`              | Additional label selector to filter resources                      | `{}`        |
| `velero.annotations`                | Additional annotations to add to the Velero Schedule resources     | `{}`        |

### Environment Variables

| Name  | Description                                                | Value  |
| ----- | ---------------------------------------------------------- | ------ |
| `env` | Environment variables for OpenClaw (use map format: key: value). | `{}`  |

### Service parameters

| Name           | Description                              | Value       |
| -------------- | ---------------------------------------- | ----------- |
| `service.type` | The type of service to create.           | `ClusterIP` |
| `service.port` | The port on which the service will run.  | `80`        |

### Ingress parameters

| Name                                 | Description                                    | Value              |
| ------------------------------------ | ---------------------------------------------- | ------------------ |
| `ingress.enabled`                    | Whether to enable the ingress.                 | `false`            |
| `ingress.className`                  | The ingress class name to use.                 | `""`               |
| `ingress.annotations`                | Annotations for the Ingress resource.          | `{}`               |
| `ingress.tls.enabled`                | Enable TLS for the Ingress.                    | `false`            |
| `ingress.tls.hosts`                  | List of hosts for TLS certificate.             | `[]`               |
| `ingress.hosts[0].host`              | The host name that the Ingress will respond to.| `openclaw.local`   |
| `ingress.hosts[0].paths[0].path`     | URL path for the HTTP rule.                    | `/`                |
| `ingress.hosts[0].paths[0].pathType` | Type of path matching.                         | `Prefix`           |

### ArgoCD Image Updater parameters

| Name                           | Description                                                                            | Value  |
| ------------------------------ | -------------------------------------------------------------------------------------- | ------ |
| `imageUpdater.namespace`       | Namespace where the ImageUpdater CRD will be created.                                  | `argocd` |
| `imageUpdater.argocdNamespace` | Namespace where ArgoCD Applications are located.                                       | `argocd` |
| `imageUpdater.applicationName` | Name or pattern of the ArgoCD Application to update. Defaults to Release name.         | `""`   |
| `imageUpdater.imageAlias`      | Alias for the image in the ImageUpdater CRD. Defaults to Release name.                 | `""`   |
| `imageUpdater.forceUpdate`     | Force update even if image is not currently deployed.                                  | `false` |
| `imageUpdater.helm`            | Helm-specific configuration for parameter names.                                       | `{}`   |
| `imageUpdater.kustomize`       | Kustomize-specific configuration.                                                      | `{}`   |
| `imageUpdater.writeBackConfig` | Write-back configuration for GitOps.                                                   | `{}`   |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install openclaw \
  --set openclaw.gatewayToken.value="my-secret-token" \
    raulpatel/openclaw
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install openclaw -f values.yaml raulpatel/openclaw
```

> **Tip**: You can use the default [values.yaml](values.yaml)

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
