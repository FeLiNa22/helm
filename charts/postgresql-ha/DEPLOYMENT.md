# Deployment Guide: PostgreSQL Cluster with Applications

This guide shows how to deploy PostgreSQL clusters for your applications using CloudNativePG.

## Prerequisites

1. Install the CloudNativePG operator (see `OPERATOR-INSTALL.md`)
2. Kubernetes cluster with persistent storage

## Deployment Steps

### 1. Deploy PostgreSQL Cluster for Nextcloud

```bash
# Deploy the PostgreSQL cluster
helm install nextcloud-db ./postgresql-cluster -f ./postgresql-cluster/examples/nextcloud-values.yaml

# Wait for the cluster to be ready
kubectl wait --for=condition=Ready cluster/nextcloud-db --timeout=300s

# Get the credentials
export PGPASSWORD=$(kubectl get secret nextcloud-db-app -o jsonpath='{.data.password}' | base64 -d)
export PGUSER=$(kubectl get secret nextcloud-db-app -o jsonpath='{.data.username}' | base64 -d)

echo "Database: nextcloud"
echo "Username: $PGUSER"
echo "Password: $PGPASSWORD"
echo "Host: nextcloud-db-rw"
echo "Port: 5432"
```

### 2. Deploy Nextcloud

Update your Nextcloud values.yaml:

```yaml
env:
  POSTGRES_HOST: nextcloud-db-rw
  POSTGRES_DB: nextcloud
  POSTGRES_USER: nextcloud  # From secret
  POSTGRES_PASSWORD: ""     # From secret

# Or use existing secret
database:
  existingSecret: nextcloud-db-app
  secretKeys:
    usernameKey: username
    passwordKey: password
```

### 3. Deploy PostgreSQL Cluster for Immich

```bash
# Deploy the PostgreSQL cluster
helm install immich-db ./postgresql-cluster -f ./postgresql-cluster/examples/immich-values.yaml

# Wait for the cluster to be ready
kubectl wait --for=condition=Ready cluster/immich-db --timeout=300s

# Get the credentials
export IMMICH_PGPASSWORD=$(kubectl get secret immich-db-app -o jsonpath='{.data.password}' | base64 -d)
export IMMICH_PGUSER=$(kubectl get secret immich-db-app -o jsonpath='{.data.username}' | base64 -d)

echo "Database: immich"
echo "Username: $IMMICH_PGUSER"
echo "Password: $IMMICH_PGPASSWORD"
echo "Host: immich-db-pooler-rw"  # Using connection pooler
echo "Port: 5432"
```

### 4. Deploy Immich

Update your Immich values.yaml:

```yaml
env:
  DB_HOSTNAME: immich-db-pooler-rw  # Using PgBouncer for better performance
  DB_PORT: "5432"
  DB_DATABASE_NAME: immich
  DB_USERNAME: immich  # From secret
  DB_PASSWORD: ""      # From secret
```

## Service Names

Each PostgreSQL cluster creates multiple services:

| Service Type | Service Name Pattern | Purpose |
|-------------|---------------------|---------|
| Read-Write | `<release-name>-rw` | Primary instance (read/write) |
| Read-Only | `<release-name>-ro` | Load balanced across replicas (read-only) |
| Read | `<release-name>-r` | Load balanced across all instances including primary |
| Pooler (if enabled) | `<release-name>-pooler-rw` | Connection pooler for read-write |
| Pooler (if enabled) | `<release-name>-pooler-ro` | Connection pooler for read-only |

## Connection Examples

### Direct Connection (without pooler)

```bash
psql postgresql://nextcloud:password@nextcloud-db-rw:5432/nextcloud
```

### With Connection Pooler

```bash
psql postgresql://immich:password@immich-db-pooler-rw:5432/immich
```

### Read-Only Queries

```bash
psql postgresql://immich:password@immich-db-ro:5432/immich
```

## Monitoring

### Check Cluster Status

```bash
kubectl get cluster
kubectl describe cluster nextcloud-db
```

### Check Pod Status

```bash
kubectl get pods -l cnpg.io/cluster=nextcloud-db
```

### View Logs

```bash
# Primary pod
kubectl logs -l cnpg.io/cluster=nextcloud-db,role=primary

# All pods
kubectl logs -l cnpg.io/cluster=nextcloud-db
```

### Check Backup Status

```bash
kubectl get backup
kubectl describe backup nextcloud-db-<backup-id>
```

## Scaling Operations

### Scale Up

```bash
helm upgrade nextcloud-db ./postgresql-cluster \
  -f ./postgresql-cluster/examples/nextcloud-values.yaml \
  --set cluster.instances=5
```

### Scale Down

```bash
helm upgrade nextcloud-db ./postgresql-cluster \
  -f ./postgresql-cluster/examples/nextcloud-values.yaml \
  --set cluster.instances=2
```

## Backup and Restore

### Manual Backup

```bash
kubectl cnpg backup nextcloud-db
```

### List Backups

```bash
kubectl get backup
```

### Restore from Backup

Create a new cluster from backup:

```yaml
bootstrap:
  recovery:
    backup:
      name: nextcloud-db-20240101000000
```

## Troubleshooting

### Cluster Not Ready

```bash
kubectl describe cluster nextcloud-db
kubectl get events --sort-by='.lastTimestamp'
```

### Connection Issues

```bash
# Test from a pod
kubectl run -it --rm psql --image=postgres:16 --restart=Never -- \
  psql postgresql://nextcloud:password@nextcloud-db-rw:5432/nextcloud
```

### Check Resource Usage

```bash
kubectl top pods -l cnpg.io/cluster=nextcloud-db
```

## Maintenance

### Upgrade PostgreSQL Version

Update the image tag in values.yaml:

```yaml
image:
  tag: "17.0"  # New version
```

Then upgrade:

```bash
helm upgrade nextcloud-db ./postgresql-cluster \
  -f ./postgresql-cluster/examples/nextcloud-values.yaml
```

The operator performs a rolling upgrade with minimal downtime.

### Switchover (Promote Replica)

```bash
kubectl cnpg promote nextcloud-db nextcloud-db-2
```

## Best Practices

1. **Always enable backups** for production databases
2. **Use connection poolers** for applications with many connections (like Immich)
3. **Monitor resource usage** and adjust limits accordingly
4. **Use anti-affinity rules** to spread pods across nodes
5. **Test restore procedures** regularly
6. **Keep credentials in secrets**, never in plain text
7. **Use read replicas** for read-heavy workloads
8. **Enable monitoring** with Prometheus

## Multi-Service Deployment Example

Deploy all databases at once:

```bash
#!/bin/bash
set -e

# Install operator if not present
kubectl get deployment -n cnpg-system cnpg-controller-manager || \
  kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml

# Wait for operator
kubectl wait --for=condition=Available deployment/cnpg-controller-manager -n cnpg-system --timeout=300s

# Deploy databases
for app in nextcloud immich home-assistant mealie; do
  echo "Deploying ${app}-db..."
  helm install ${app}-db ./postgresql-cluster \
    -f ./postgresql-cluster/examples/${app}-values.yaml
done

# Wait for all clusters
for app in nextcloud immich home-assistant mealie; do
  kubectl wait --for=condition=Ready cluster/${app}-db --timeout=300s
done

echo "All databases deployed successfully!"
```
