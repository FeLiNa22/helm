# Integration Guide: Connecting Applications to PostgreSQL Clusters

This guide shows how to update your application charts (Nextcloud, Immich, Home Assistant, Mealie) to use the CloudNativePG clusters.

## Overview

Each application needs to know:
1. Database host (service name)
2. Database port (usually 5432)
3. Database name
4. Username and password

## Option 1: Using Existing Secrets (Recommended)

The PostgreSQL chart creates secrets automatically. Reference them in your application.

### Nextcloud Integration

```yaml
# charts/nextcloud/values.yaml
env:
  POSTGRES_HOST: "nextcloud-db-rw"
  POSTGRES_PORT: "5432"
  POSTGRES_DB: "nextcloud"
  # Use secret for credentials
  POSTGRES_USER:
    valueFrom:
      secretKeyRef:
        name: nextcloud-db-app
        key: username
  POSTGRES_PASSWORD:
    valueFrom:
      secretKeyRef:
        name: nextcloud-db-app
        key: password
```

Update `charts/nextcloud/templates/deployment.yaml`:

```yaml
env:
  - name: POSTGRES_HOST
    value: {{ .Values.env.POSTGRES_HOST | quote }}
  - name: POSTGRES_PORT
    value: {{ .Values.env.POSTGRES_PORT | quote }}
  - name: POSTGRES_DB
    value: {{ .Values.env.POSTGRES_DB | quote }}
  - name: POSTGRES_USER
    valueFrom:
      secretKeyRef:
        name: {{ .Values.database.secretName | default "nextcloud-db-app" }}
        key: username
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Values.database.secretName | default "nextcloud-db-app" }}
        key: password
```

### Immich Integration

```yaml
# charts/immich/values.yaml
env:
  DB_HOSTNAME: "immich-db-pooler-rw"  # Using connection pooler
  DB_PORT: "5432"
  DB_DATABASE_NAME: "immich"
  # Credentials from secret
  DB_USERNAME:
    valueFrom:
      secretKeyRef:
        name: immich-db-app
        key: username
  DB_PASSWORD:
    valueFrom:
      secretKeyRef:
        name: immich-db-app
        key: password
```

Update `charts/immich/templates/deployment.yaml`:

```yaml
env:
  - name: DB_HOSTNAME
    value: {{ .Values.env.DB_HOSTNAME | quote }}
  - name: DB_PORT
    value: {{ .Values.env.DB_PORT | quote }}
  - name: DB_DATABASE_NAME
    value: {{ .Values.env.DB_DATABASE_NAME | quote }}
  - name: DB_USERNAME
    valueFrom:
      secretKeyRef:
        name: {{ .Values.database.secretName | default "immich-db-app" }}
        key: username
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Values.database.secretName | default "immich-db-app" }}
        key: password
  # Immich also needs Redis
  - name: REDIS_HOSTNAME
    value: {{ .Values.env.REDIS_HOSTNAME | quote }}
```

### Home Assistant Integration

Home Assistant uses a database URL format:

```yaml
# charts/home-assistant/values.yaml
database:
  enabled: true
  host: "home-assistant-db-rw"
  port: 5432
  name: "homeassistant"
  secretName: "home-assistant-db-app"
```

Update configuration:

```yaml
# In deployment, add an init container to create configuration
initContainers:
  - name: db-config
    image: busybox
    command:
      - sh
      - -c
      - |
        cat > /config/secrets.yaml <<EOF
        postgres_db: postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)
        EOF
    env:
      - name: DB_HOST
        value: {{ .Values.database.host | quote }}
      - name: DB_PORT
        value: {{ .Values.database.port | quote }}
      - name: DB_NAME
        value: {{ .Values.database.name | quote }}
      - name: DB_USER
        valueFrom:
          secretKeyRef:
            name: {{ .Values.database.secretName }}
            key: username
      - name: DB_PASSWORD
        valueFrom:
          secretKeyRef:
            name: {{ .Values.database.secretName }}
            key: password
    volumeMounts:
      - name: config
        mountPath: /config
```

### Mealie Integration

```yaml
# charts/mealie/values.yaml
database:
  type: postgres
  host: "mealie-db-rw"
  port: 5432
  name: "mealie"
  secretName: "mealie-db-app"
```

Update `charts/mealie/templates/deployment.yaml`:

```yaml
env:
  - name: DB_ENGINE
    value: "postgres"
  - name: POSTGRES_SERVER
    value: {{ .Values.database.host | quote }}
  - name: POSTGRES_PORT
    value: {{ .Values.database.port | quote }}
  - name: POSTGRES_DB
    value: {{ .Values.database.name | quote }}
  - name: POSTGRES_USER
    valueFrom:
      secretKeyRef:
        name: {{ .Values.database.secretName }}
        key: username
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Values.database.secretName }}
        key: password
```

## Option 2: Using Plain Values (Development Only)

For development, you might want to use plain text credentials:

```yaml
# NOT RECOMMENDED FOR PRODUCTION
env:
  POSTGRES_HOST: "nextcloud-db-rw"
  POSTGRES_DB: "nextcloud"
  POSTGRES_USER: "nextcloud"
  POSTGRES_PASSWORD: "dev-password-123"
```

## Deployment Order

Deploy in this order:

```bash
# 1. Install CloudNativePG operator
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml

# 2. Deploy PostgreSQL cluster
helm install nextcloud-db ./postgresql-cluster -f ./postgresql-cluster/examples/nextcloud-values.yaml

# 3. Wait for database to be ready
kubectl wait --for=condition=Ready cluster/nextcloud-db --timeout=300s

# 4. Deploy application
helm install nextcloud ./nextcloud
```

## Complete Example: Nextcloud Deployment

```bash
#!/bin/bash
set -e

# Deploy database
echo "Deploying PostgreSQL cluster..."
helm install nextcloud-db ./postgresql-cluster \
  --set cluster.instances=3 \
  --set storage.size=20Gi \
  --set appSecret.username=nextcloud \
  --set bootstrap.initdb.database=nextcloud \
  --set backup.enabled=true

# Wait for cluster
echo "Waiting for database cluster..."
kubectl wait --for=condition=Ready cluster/nextcloud-db --timeout=300s

# Get credentials
DB_USER=$(kubectl get secret nextcloud-db-app -o jsonpath='{.data.username}' | base64 -d)
DB_PASS=$(kubectl get secret nextcloud-db-app -o jsonpath='{.data.password}' | base64 -d)

echo "Database ready!"
echo "Host: nextcloud-db-rw"
echo "Database: nextcloud"
echo "User: $DB_USER"
echo "Password: $DB_PASS"

# Deploy Nextcloud
echo "Deploying Nextcloud..."
helm install nextcloud ./nextcloud \
  --set env.POSTGRES_HOST=nextcloud-db-rw \
  --set env.POSTGRES_DB=nextcloud \
  --set database.secretName=nextcloud-db-app

echo "Deployment complete!"
```

## Verifying Connection

Test database connectivity from your application pod:

```bash
# Get app pod name
APP_POD=$(kubectl get pod -l app=nextcloud -o jsonpath='{.items[0].metadata.name}')

# Get database credentials
DB_USER=$(kubectl get secret nextcloud-db-app -o jsonpath='{.data.username}' | base64 -d)
DB_PASS=$(kubectl get secret nextcloud-db-app -o jsonpath='{.data.password}' | base64 -d)

# Test connection
kubectl exec -it $APP_POD -- sh -c "
  PGPASSWORD='$DB_PASS' psql -h nextcloud-db-rw -U $DB_USER -d nextcloud -c 'SELECT version();'
"
```

## Troubleshooting

### Application Can't Connect

1. Check database is ready:
```bash
kubectl get cluster
kubectl get pods -l cnpg.io/cluster=nextcloud-db
```

2. Verify service exists:
```bash
kubectl get svc | grep nextcloud-db
```

3. Check secret exists:
```bash
kubectl get secret nextcloud-db-app
```

4. Test from a debug pod:
```bash
kubectl run -it --rm debug --image=postgres:16 --restart=Never -- \
  psql postgresql://nextcloud-db-rw:5432/nextcloud
```

### Wrong Credentials

If you need to reset the password:

```bash
# Delete the secret
kubectl delete secret nextcloud-db-app

# Recreate with new password
kubectl create secret generic nextcloud-db-app \
  --from-literal=username=nextcloud \
  --from-literal=password=new-password
```

### Database Migration

To migrate from an existing database:

```bash
# 1. Dump old database
kubectl exec old-postgres-pod -- pg_dump -U user dbname > backup.sql

# 2. Load into new cluster
kubectl exec -i nextcloud-db-1 -- psql -U nextcloud nextcloud < backup.sql
```

## Best Practices

1. **Always use secrets** for credentials in production
2. **Use connection pooler** for apps with many connections (Immich)
3. **Enable backups** for production databases
4. **Monitor connections**: Check PgBouncer stats if using pooler
5. **Test failover**: Verify app reconnects after database failover
6. **Use read replicas** for read-heavy operations
7. **Keep applications updated** to handle connection drops gracefully

## Service Selection Guide

| Service Name | Use Case | Example Apps |
|--------------|----------|--------------|
| `<name>-rw` | Read-write operations | All apps (default) |
| `<name>-ro` | Read-only queries | Analytics, reports |
| `<name>-r` | Read operations | Caching layers |
| `<name>-pooler-rw` | High-connection apps | Immich, web apps |
| `<name>-pooler-ro` | Read-only pooled | Read-heavy services |

## Example Values Files

See the `examples/` directory for complete values files:
- `nextcloud-values.yaml`
- `immich-values.yaml`
- `home-assistant-values.yaml`
- `mealie-values.yaml`

Each includes recommended settings for the specific application.
