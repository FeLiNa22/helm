# Quick Start Guide

Get PostgreSQL clusters running in 5 minutes!

## Prerequisites

- Kubernetes cluster (1.20+)
- kubectl configured
- helm 3.x installed

## Step 1: Install CloudNativePG Operator (1 minute)

```bash
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml

# Wait for operator to be ready
kubectl wait --for=condition=Available deployment/cnpg-controller-manager -n cnpg-system --timeout=180s
```

## Step 2: Deploy Your First Cluster (2 minutes)

### Simple Development Cluster

```bash
# Create a simple single-instance cluster
helm install my-postgres ./postgresql-cluster \
  --set cluster.instances=1 \
  --set storage.size=5Gi
```

### Production HA Cluster

```bash
# Create a 3-node production cluster with backups
helm install prod-postgres ./postgresql-cluster \
  --set cluster.instances=3 \
  --set storage.size=20Gi \
  --set backup.enabled=true
```

## Step 3: Get Connection Info (30 seconds)

```bash
# Get the username
export PGUSER=$(kubectl get secret prod-postgres-app -o jsonpath='{.data.username}' | base64 -d)

# Get the password
export PGPASSWORD=$(kubectl get secret prod-postgres-app -o jsonpath='{.data.password}' | base64 -d)

# Connection details
echo "Database: app"
echo "Username: $PGUSER"
echo "Password: $PGPASSWORD"
echo "Host: prod-postgres-rw"
echo "Port: 5432"
```

## Step 4: Connect and Use (1 minute)

```bash
# Quick connection test
kubectl run -it --rm psql --image=postgres:16 --restart=Never -- \
  psql "postgresql://$PGUSER:$PGPASSWORD@prod-postgres-rw:5432/app"
```

## Common Deployment Scenarios

### For Nextcloud

```bash
helm install nextcloud-db ./postgresql-cluster \
  -f ./postgresql-cluster/examples/nextcloud-values.yaml
```

### For Immich (with connection pooler)

```bash
helm install immich-db ./postgresql-cluster \
  -f ./postgresql-cluster/examples/immich-values.yaml
```

### For Home Assistant

```bash
helm install homeassistant-db ./postgresql-cluster \
  -f ./postgresql-cluster/examples/home-assistant-values.yaml
```

### For Mealie

```bash
helm install mealie-db ./postgresql-cluster \
  -f ./postgresql-cluster/examples/mealie-values.yaml
```

## Quick Commands

### Check cluster status
```bash
kubectl get cluster
```

### View cluster details
```bash
kubectl describe cluster prod-postgres
```

### List all PostgreSQL pods
```bash
kubectl get pods -l cnpg.io/cluster=prod-postgres
```

### Scale the cluster
```bash
helm upgrade prod-postgres ./postgresql-cluster --set cluster.instances=5
```

### Create a manual backup
```bash
kubectl cnpg backup prod-postgres
```

### View logs
```bash
kubectl logs -l cnpg.io/cluster=prod-postgres,role=primary
```

## Customization Examples

### Custom Database and User

```bash
helm install my-app-db ./postgresql-cluster \
  --set appSecret.username=myapp \
  --set bootstrap.initdb.database=myapp \
  --set bootstrap.initdb.owner=myapp
```

### With Specific Storage Class

```bash
helm install my-postgres ./postgresql-cluster \
  --set storage.storageClass=fast-ssd \
  --set storage.size=50Gi
```

### With Custom Passwords

```bash
helm install my-postgres ./postgresql-cluster \
  --set superuserSecret.password=my-super-secret \
  --set appSecret.password=my-app-secret
```

### Enable S3 Backups

```bash
# First, create S3 credentials secret
kubectl create secret generic s3-creds \
  --from-literal=ACCESS_KEY_ID=your-key \
  --from-literal=ACCESS_SECRET_KEY=your-secret

# Deploy with backups
helm install my-postgres ./postgresql-cluster \
  --set backup.enabled=true \
  --set backup.s3.enabled=true \
  --set backup.s3.bucket=my-backups \
  --set backup.s3.secret.name=s3-creds
```

## Troubleshooting

### Cluster won't start

```bash
# Check operator is running
kubectl get pods -n cnpg-system

# Check cluster events
kubectl describe cluster prod-postgres

# Check pod events
kubectl describe pod prod-postgres-1
```

### Can't connect

```bash
# Verify service exists
kubectl get svc | grep prod-postgres

# Check secret
kubectl get secret prod-postgres-app

# Test from inside cluster
kubectl run -it --rm debug --image=postgres:16 --restart=Never -- \
  psql postgresql://prod-postgres-rw:5432/app
```

## Next Steps

- Read [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment guides
- Check [INTEGRATION.md](INTEGRATION.md) to connect your applications
- See [EXAMPLES.md](EXAMPLES.md) for more configuration examples
- Learn [WHY-CNPG.md](WHY-CNPG.md) about CloudNativePG benefits

## Cleanup

To remove a cluster:

```bash
# Delete the cluster (this will delete all data!)
helm uninstall prod-postgres

# Optionally remove PVCs
kubectl delete pvc -l cnpg.io/cluster=prod-postgres
```

To remove the operator:

```bash
kubectl delete -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
```

## Support

- 📚 [CloudNativePG Documentation](https://cloudnative-pg.io/documentation/)
- 💬 [Slack Channel](https://cloudnativepg.slack.com/)
- 🐛 [GitHub Issues](https://github.com/cloudnative-pg/cloudnative-pg/issues)

Happy clustering! 🐘
