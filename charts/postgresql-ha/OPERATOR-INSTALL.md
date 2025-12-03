# Installing CloudNativePG Operator

The CloudNativePG operator must be installed before deploying PostgreSQL clusters.

## Quick Installation

```bash
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
```

## Verify Installation

```bash
kubectl get deployment -n cnpg-system cnpg-controller-manager
```

## Using Helm (Alternative)

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm install cnpg cnpg/cloudnative-pg -n cnpg-system --create-namespace
```

## What Gets Installed

The operator installs:
- Custom Resource Definitions (CRDs) for Cluster, Pooler, Backup, ScheduledBackup
- Controller manager deployment
- Webhook service for validation and mutation
- RBAC resources

## Upgrading the Operator

```bash
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
```

Or with Helm:

```bash
helm upgrade cnpg cnpg/cloudnative-pg -n cnpg-system
```

## Uninstalling

```bash
kubectl delete -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
```

Or with Helm:

```bash
helm uninstall cnpg -n cnpg-system
```

**Note:** Uninstalling the operator does NOT delete existing PostgreSQL clusters.
