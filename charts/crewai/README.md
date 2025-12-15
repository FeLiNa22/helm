# CrewAI

CrewAI is a framework for orchestrating role-playing, autonomous AI agents. By fostering collaborative intelligence, CrewAI empowers agents to work together seamlessly, tackling complex tasks.

## TL;DR

```console
helm repo add felina22 https://felina22.github.io/helms
helm install crewai felina22/crewai
```

## Introduction

This chart helps you deploy CrewAI-based AI agent workflows to Kubernetes. It provides a production-ready deployment for running your CrewAI crews and agents with proper configuration for LLM providers, persistence, and scaling.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- An API key from your preferred LLM provider (OpenAI, Anthropic, or Azure OpenAI)

## Installing the Chart

To install the chart with the release name `crewai`:

```console
helm install crewai felina22/crewai
```

The command deploys CrewAI on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `crewai` deployment:

```console
helm delete crewai
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### CrewAI parameters

| Name | Description | Value |
|------|-------------|-------|
| `enabled` | Whether to enable CrewAI. | `true` |
| `replicaCount` | The number of replicas to deploy. | `1` |
| `image.repository` | The Docker repository to pull the image from. | `crewaiinc/crewai` |
| `image.tag` | The image tag to use. | `0.121.1` |
| `image.pullPolicy` | The logic of image pulling. | `IfNotPresent` |
| `imagePullSecrets` | The image pull secrets to use. | `[]` |
| `deployment.strategy.type` | The deployment strategy to use. | `Recreate` |
| `serviceAccount.create` | Whether to create a service account. | `true` |
| `serviceAccount.annotations` | Additional annotations to add to the service account. | `{}` |
| `serviceAccount.name` | The name of the service account to use. | `""` |
| `podAnnotations` | Additional annotations to add to the pod. | `{}` |
| `podSecurityContext` | The security context to use for the pod. | `{}` |
| `securityContext` | The security context to use for the container. | `{}` |
| `initContainers` | Additional init containers to add to the pod. | `[]` |
| `service.type` | The type of service to create. | `ClusterIP` |
| `service.port` | The port on which the service will run. | `8000` |
| `service.nodePort` | The nodePort to use for the service. | `""` |
| `ingress.enabled` | Whether to create an ingress for the service. | `false` |
| `ingress.className` | The ingress class name to use. | `""` |
| `ingress.annotations` | Additional annotations to add to the ingress. | `{}` |
| `ingress.hosts[0].host` | The host to use for the ingress. | `crewai.local` |
| `ingress.hosts[0].paths[0].path` | The path to use for the ingress. | `/` |
| `ingress.hosts[0].paths[0].pathType` | The path type to use for the ingress. | `ImplementationSpecific` |
| `ingress.tls` | The TLS configuration for the ingress. | `[]` |
| `resources` | The resources to use for the pod. | `{}` |
| `autoscaling.enabled` | Whether to enable autoscaling. | `false` |
| `autoscaling.minReplicas` | The minimum number of replicas to scale to. | `1` |
| `autoscaling.maxReplicas` | The maximum number of replicas to scale to. | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | The target CPU utilization percentage. | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage. | `80` |
| `nodeSelector` | The node selector to use for the pod. | `{}` |
| `tolerations` | The tolerations to use for the pod. | `[]` |
| `affinity` | The affinity to use for the pod. | `{}` |

### CrewAI Configuration

| Name | Description | Value |
|------|-------------|-------|
| `crewai.openaiApiKey.value` | Direct value for OpenAI API key. | `""` |
| `crewai.openaiApiKey.existingSecret` | Reference to existing secret for OpenAI API key. | `""` |
| `crewai.crewaiApiKey.value` | Direct value for CrewAI API key. | `""` |
| `crewai.crewaiApiKey.existingSecret` | Reference to existing secret for CrewAI API key. | `""` |
| `crewai.anthropicApiKey.value` | Direct value for Anthropic API key. | `""` |
| `crewai.anthropicApiKey.existingSecret` | Reference to existing secret for Anthropic API key. | `""` |
| `crewai.azureOpenaiApiKey.value` | Direct value for Azure OpenAI API key. | `""` |
| `crewai.azureOpenaiApiKey.existingSecret` | Reference to existing secret for Azure OpenAI API key. | `""` |
| `crewai.azureOpenaiEndpoint` | Azure OpenAI endpoint URL. | `""` |
| `crewai.azureOpenaiApiVersion` | Azure OpenAI API version. | `2024-02-01` |
| `crewai.telemetryEnabled` | Whether to enable telemetry. | `true` |
| `crewai.logLevel` | The log level (DEBUG, INFO, WARNING, ERROR). | `INFO` |
| `crewai.extraEnv` | Additional environment variables. | `{}` |

### Persistence parameters

| Name | Description | Value |
|------|-------------|-------|
| `persistence.enabled` | Whether to enable persistence. | `false` |
| `persistence.storageClass` | The storage class to use. | `""` |
| `persistence.existingClaim` | The name of an existing claim to use. | `""` |
| `persistence.accessMode` | The access mode to use. | `ReadWriteOnce` |
| `persistence.size` | The size to use for the persistence. | `5Gi` |
| `persistence.additionalVolumes` | Additional volumes to add to the pod. | `[]` |
| `persistence.additionalMounts` | Additional volume mounts to add to the pod. | `[]` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install crewai \
  --set crewai.openaiApiKey.value=sk-your-api-key \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=crewai.example.com \
    felina22/crewai
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install crewai -f values.yaml felina22/crewai
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and installation details

### Using existing secrets

For better security, you can use existing Kubernetes secrets for your API keys:

```yaml
crewai:
  openaiApiKey:
    existingSecret: my-crewai-secrets # key: openai-api-key
  crewaiApiKey:
    existingSecret: my-crewai-secrets # key: crewai-api-key
```

### Using Azure OpenAI

To configure Azure OpenAI as your LLM provider:

```yaml
crewai:
  azureOpenaiApiKey:
    existingSecret: azure-secrets
  azureOpenaiEndpoint: "https://your-resource.openai.azure.com/"
  azureOpenaiApiVersion: "2024-02-01"
```

### Enabling persistence

For production deployments, enable persistence to store crew data:

```yaml
persistence:
  enabled: true
  storageClass: "standard"
  size: 10Gi
```

### Setting resource limits

For production deployments, set appropriate resource limits:

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 1Gi
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
