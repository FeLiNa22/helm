# Homepage Helm Chart

Homepage is a modern, highly customizable application dashboard with integrations for over 100 services and translations into multiple languages. This Helm chart deploys Homepage with automatic Kubernetes service discovery enabled.

## TL;DR

```bash
helm repo add felina22 https://felina22.github.io/helms
helm install my-homepage felina22/homepage
```

## Introduction

This chart bootstraps a [Homepage](https://github.com/gethomepage/homepage) deployment on a Kubernetes cluster using the Helm package manager.

Homepage is configured to automatically discover services deployed in your Kubernetes cluster, including all services from this repository.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `my-homepage`:

```bash
helm install my-homepage felina22/homepage
```

The command deploys Homepage on the Kubernetes cluster with the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-homepage` deployment:

```bash
helm uninstall my-homepage
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Homepage parameters

| Name                                            | Description                                                                                                                         | Value                          |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| `enabled`                                       | Whether to enable Homepage.                                                                                                         | `true`                         |
| `replicaCount`                                  | The number of replicas to deploy.                                                                                                   | `1`                            |
| `image.repository`                              | The Docker repository to pull the image from.                                                                                       | `ghcr.io/gethomepage/homepage` |
| `image.tag`                                     | The image tag to use.                                                                                                               | `latest`                       |
| `image.pullPolicy`                              | The logic of image pulling.                                                                                                         | `IfNotPresent`                 |
| `imagePullSecrets`                              | The image pull secrets to use.                                                                                                      | `[]`                           |
| `deployment.strategy.type`                      | The deployment strategy to use.                                                                                                     | `Recreate`                     |
| `serviceAccount.create`                         | Whether to create a service account.                                                                                                | `true`                         |
| `serviceAccount.annotations`                    | Additional annotations to add to the service account.                                                                               | `{}`                           |
| `serviceAccount.name`                           | The name of the service account to use. If not set and create is true, a new service account will be created with a generated name. | `""`                           |
| `podAnnotations`                                | Additional annotations to add to the pod.                                                                                           | `{}`                           |
| `podSecurityContext`                            | The security context to use for the pod.                                                                                            | `{}`                           |
| `securityContext`                               | The security context to use for the container.                                                                                      | `{}`                           |
| `initContainers`                                | Additional init containers to add to the pod.                                                                                       | `[]`                           |
| `service.type`                                  | The type of service to create.                                                                                                      | `LoadBalancer`                 |
| `service.port`                                  | The port on which the service will run.                                                                                             | `3000`                         |
| `service.nodePort`                              | The nodePort to use for the service. Only used if service.type is NodePort.                                                         | `""`                           |
| `ingress.enabled`                               | Whether to create an ingress for the service.                                                                                       | `false`                        |
| `ingress.className`                             | The ingress class name to use.                                                                                                      | `""`                           |
| `ingress.annotations`                           | Additional annotations to add to the ingress.                                                                                       | `{}`                           |
| `ingress.hosts[0].host`                         | The host to use for the ingress.                                                                                                    | `chart-example.local`          |
| `ingress.hosts[0].paths[0].path`                | The path to use for the ingress.                                                                                                    | `/`                            |
| `ingress.hosts[0].paths[0].pathType`            | The path type to use for the ingress.                                                                                               | `ImplementationSpecific`       |
| `ingress.tls`                                   | The TLS configuration for the ingress.                                                                                              | `[]`                           |
| `resources`                                     | The resources to use for the pod.                                                                                                   | `{}`                           |
| `autoscaling.enabled`                           | Whether to enable autoscaling.                                                                                                      | `false`                        |
| `autoscaling.minReplicas`                       | The minimum number of replicas to scale to.                                                                                         | `1`                            |
| `autoscaling.maxReplicas`                       | The maximum number of replicas to scale to.                                                                                         | `100`                          |
| `autoscaling.targetCPUUtilizationPercentage`    | The target CPU utilization percentage to use for autoscaling.                                                                       | `80`                           |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to use for autoscaling.                                                                    | `80`                           |
| `nodeSelector`                                  | The node selector to use for the pod.                                                                                               | `{}`                           |
| `tolerations`                                   | The tolerations to use for the pod.                                                                                                 | `[]`                           |
| `affinity`                                      | The affinity to use for the pod.                                                                                                    | `{}`                           |
| `env`                                           | Additional environment variables to add to the pod.                                                                                 | `{}`                           |
| `persistence.enabled`                           | Whether to enable persistence.                                                                                                      | `true`                         |
| `persistence.storageClass`                      | The storage class to use for the persistence.                                                                                       | `""`                           |
| `persistence.existingClaim`                     | The name of an existing claim to use for the persistence.                                                                           | `""`                           |
| `persistence.accessMode`                        | The access mode to use for the persistence.                                                                                         | `ReadWriteOnce`                |
| `persistence.size`                              | The size to use for the persistence.                                                                                                | `1Gi`                          |
| `persistence.backup.enabled`                    | Whether to enable backup persistence.                                                                                               | `false`                        |
| `persistence.backup.storageClass`               | The storage class to use for backup persistence.                                                                                    | `cephfs`                       |
| `persistence.backup.existingClaim`              | The name of an existing claim to use for backup persistence.                                                                        | `""`                           |
| `persistence.backup.accessMode`                 | The access mode to use for backup persistence.                                                                                      | `ReadWriteMany`                |
| `persistence.backup.size`                       | The size to use for backup persistence.                                                                                             | `5Gi`                          |
| `persistence.additionalVolumes`                 | Additional volumes to add to the pod.                                                                                               | `[]`                           |
| `persistence.additionalMounts`                  | Additional volume mounts to add to the pod.                                                                                         | `[]`                           |
| `env`                                           | Additional environment variables to add to the pod.                                                                                 | `{}`                           |

### Homepage Configuration

| Name                      | Description                                                                                                                     | Value     |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | --------- |
| `config.enableKubernetes` | Enable Kubernetes integration for service discovery                                                                             | `true`    |
| `config.kubernetes.mode`  | Mode for Kubernetes integration (cluster or default)                                                                            | `cluster` |
| `config.allowedHosts`     | Comma-separated list of allowed hosts for the HOMEPAGE_ALLOWED_HOSTS environment variable (e.g., "example.com,www.example.com") | `""`      |

### RBAC Configuration

| Name          | Description                                                                      | Value  |
| ------------- | -------------------------------------------------------------------------------- | ------ |
| `rbac.create` | Create RBAC resources (ClusterRole and ClusterRoleBinding) for service discovery | `true` |

## Service Discovery

This chart automatically discovers and displays all services deployed in your Kubernetes cluster, including:

### Media Management
- Sonarr, Radarr, Lidarr, Bazarr, Prowlarr

### Media Servers
- Jellyfin, Jellyseerr, Plex, Emby

### Download Clients
- qBittorrent, SABnzbd, FlareSolverr

### Home Automation & Security
- Home Assistant, Frigate

### Productivity
- Nextcloud, Vaultwarden, Mealie, Outline, Penpot, Excalidraw

### Utilities
- Immich, SearXNG, Cloudflare Tunnel, Cloudflare Dynamic IP, CrewAI

### Maintenance
- Cleanuparr

## How Automatic Service Discovery Works

Homepage uses Kubernetes service discovery to automatically detect and display services running in your cluster. The discovery mechanism works as follows:

### 1. Kubernetes Integration Mode

The chart enables Kubernetes integration by mounting a `kubernetes.yaml` configuration file that sets the mode to `cluster`. This tells Homepage to use the in-cluster Kubernetes API to discover services.

```yaml
config:
  enableKubernetes: true
  kubernetes:
    mode: cluster
```

### 2. RBAC Permissions

Homepage requires read-only access to Kubernetes resources. The chart automatically creates:
- **ServiceAccount**: Provides an identity for the Homepage pod
- **ClusterRole**: Defines permissions to read services, pods, ingresses, etc.
- **ClusterRoleBinding**: Binds the ClusterRole to the ServiceAccount

These permissions allow Homepage to query the Kubernetes API and discover services across all namespaces.

### 3. Service Configuration

Services are defined in the `services.yaml` file within the ConfigMap. Each service entry includes:

```yaml
- Group Name:
    - Service Name:
        icon: service-icon.png
        href: http://service-name
        description: Service Description
        server: kubernetes          # Enables Kubernetes integration
        namespace: default          # Namespace where service is deployed
        app: service-name           # Label selector to find the service
```

The `server: kubernetes` directive tells Homepage to use Kubernetes service discovery instead of making direct HTTP requests.

### 4. Service Discovery Process

When Homepage starts:
1. It reads the `kubernetes.yaml` configuration to determine the mode
2. It authenticates to the Kubernetes API using the ServiceAccount token
3. For each service in `services.yaml` with `server: kubernetes`, it:
   - Queries the specified namespace for services matching the `app` label
   - Retrieves service status, endpoints, and pod information
   - Displays the service with real-time status indicators
4. Services are automatically updated with live status information

## Enabling Service Discovery for Other Charts

To enable Homepage service discovery for services from other Helm charts, you need to ensure they have the correct labels. Here's how:

### Method 1: Using Standard Labels (Recommended)

Homepage uses the `app` selector to find services. Ensure your service has the `app.kubernetes.io/name` label:

```yaml
# In your service template
apiVersion: v1
kind: Service
metadata:
  name: my-service
  labels:
    app.kubernetes.io/name: my-service  # This is what Homepage looks for
    app.kubernetes.io/instance: my-release
spec:
  selector:
    app.kubernetes.io/name: my-service
  ports:
    - port: 80
```

### Method 2: Custom App Label

If your service uses a different label, you can use that in the Homepage configuration:

```yaml
# In your service
metadata:
  labels:
    app: my-custom-app  # Your custom label

# In Homepage's services.yaml
- My Services:
    - My Custom App:
        icon: custom-icon.png
        href: http://my-custom-app
        server: kubernetes
        namespace: default
        app: my-custom-app  # Matches your custom label
```

### Method 3: Adding to Homepage's ConfigMap

To add a new service to Homepage, update the `services.yaml` in the ConfigMap:

```yaml
# Add to the appropriate group in configmap.yaml
- My New Group:
    - My New Service:
        icon: my-service.png
        href: http://my-service
        description: My Service Description
        server: kubernetes
        namespace: my-namespace  # Change to your namespace
        app: my-service-name     # Change to your app label value
```

### Example: Adding a PostgreSQL Database

```yaml
- Databases:
    - PostgreSQL:
        icon: postgres.png
        href: http://postgresql
        description: PostgreSQL Database
        server: kubernetes
        namespace: default
        app: postgresql
        widget:
          type: postgres
          url: http://postgresql:5432
```

### Notes for Chart Authors

When creating Helm charts that should work with Homepage:

1. **Use standard Kubernetes labels** from the [Kubernetes common labels spec](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/):
   - `app.kubernetes.io/name`: The name of the application
   - `app.kubernetes.io/instance`: A unique name identifying the instance
   - `app.kubernetes.io/version`: The current version of the application

2. **Create a Service resource** with proper labels and selectors

3. **Document the service name** and namespace in your chart's README

4. **Optionally add Homepage annotations** to your service for automatic discovery (if using Homepage's auto-discovery features):
   ```yaml
   annotations:
     gethomepage.dev/enabled: "true"
     gethomepage.dev/name: "My Service"
     gethomepage.dev/description: "My service description"
     gethomepage.dev/group: "My Group"
     gethomepage.dev/icon: "my-icon.png"
   ```

## Configuration

The chart includes pre-configured service discovery for all services in this repository. Services are organized into logical groups and include appropriate icons and descriptions.

### Customization

You can customize the Homepage configuration by modifying the ConfigMap that is created. The configuration includes:

- `services.yaml` - Service definitions and discovery
- `widgets.yaml` - Dashboard widgets
- `bookmarks.yaml` - Bookmarked links
- `settings.yaml` - Dashboard settings (theme, layout, etc.)
- `kubernetes.yaml` - Kubernetes integration settings

### RBAC Permissions

The chart creates a ClusterRole and ClusterRoleBinding to allow Homepage to discover services across all namespaces. The ServiceAccount is granted read-only access to:

- Services
- Pods
- Ingresses
- Namespaces
- Deployments, StatefulSets, DaemonSets

## Persistence

The chart mounts a persistent volume at `/app/config` for Homepage configuration. This ensures that any customizations you make to the Homepage configuration are persisted across pod restarts.

## License

This Helm chart is licensed under the Apache License 2.0.

The Homepage application is licensed under the GNU General Public License v3.0.
