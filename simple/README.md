# Simple Chart

A flexible, general-purpose Helm chart for deploying applications on Kubernetes.

## Configuration Parameters

Parameter | Description | Example
----------|-------------|----------
`image` | Container image registry URL | `quay.io/myorg/myapp:latest`
`hostname` | Fully qualified domain name for route exposure | `myapp.example.com`
`scc` | SecurityContextConstraints (OpenShift) | `anyuid`
`ports` | Comma-separated list of source:destination ports | `8080:80,9000:9000`
`env` | Environment variables in key=value format | `DB_HOST=mysql,API_KEY=secret123`
`storage` | Mount path and size for persistent storage | `/test,1Gi`

## Installation

To install the chart with custom values:

```bash
helm install myapp ./simple \
  --set image=quay.io/myorg/myapp:latest \
  --set hostname=myapp.example.com \
  --set scc=anyuid \
  --set-literal ports=8080:80,9000:9000 \
  --set-literal env="DB_HOST=mysql,API_KEY=secret123" \
  --set-literal storage="/test,1Gi"
```

## Notes

- When setting any variables with commas, use `--set-literal` to preserve the comma
- The `scc` parameter is specific to OpenShift environments, common options are: [anyuid, nonroot-v2, privileged]
- Ports are specified as `sourcePort:destinationPort` pairs, multiple pairs can be comma-separated
- The hostname parameter will create a Route (OpenShift) or Ingress (Kubernetes) resource
- Storage parameter format is `mountPath,storageSize` where storageSize follows Kubernetes conventions (e.g., Mi, Gi)
