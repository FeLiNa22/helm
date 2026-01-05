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

### Homepage Parameters

| Name                     | Description                                                          | Value                                |
| ------------------------ | -------------------------------------------------------------------- | ------------------------------------ |
| `enabled`                | Whether to enable Homepage                                           | `true`                               |
| `replicaCount`           | Number of Homepage replicas to deploy                                | `1`                                  |
| `image.repository`       | Homepage image repository                                            | `ghcr.io/gethomepage/homepage`       |
| `image.tag`              | Homepage image tag                                                   | `v0.9.15`                            |
| `image.pullPolicy`       | Image pull policy                                                    | `IfNotPresent`                       |
| `service.type`           | Service type                                                         | `LoadBalancer`                       |
| `service.port`           | Service port                                                         | `3000`                               |
| `ingress.enabled`        | Enable ingress                                                       | `true`                               |
| `persistence.enabled`    | Enable persistence                                                   | `true`                               |
| `persistence.size`       | Size of persistent volume                                            | `1Gi`                                |

### Homepage Configuration

| Name                              | Description                                     | Value     |
| --------------------------------- | ----------------------------------------------- | --------- |
| `config.enableKubernetes`         | Enable Kubernetes integration                   | `true`    |
| `config.kubernetes.mode`          | Kubernetes mode (cluster or default)            | `cluster` |
| `config.allowedHosts`             | Comma-separated list of allowed hosts for HOMEPAGE_ALLOWED_HOSTS environment variable | `""`      |

### RBAC Configuration

| Name          | Description                                                   | Value  |
| ------------- | ------------------------------------------------------------- | ------ |
| `rbac.create` | Create RBAC resources for Kubernetes service discovery        | `true` |

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
