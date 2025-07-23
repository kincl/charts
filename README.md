# kincl's Helm Charts

This repository contains a collection of Helm charts for Kubernetes deployment.

## Available Charts

### Simple Chart

A flexible, general-purpose Helm chart for deploying applications on Kubernetes.

#### Configuration Parameters

Parameter | Description | Example
----------|-------------|----------
`image` | Container image registry URL | `quay.io/myorg/myapp:latest`
`hostname` | Fully qualified domain name for route exposure | `myapp.example.com`
`scc` | SecurityContextConstraints (OpenShift) | `anyuid`
`ports` | Comma-separated list of source:destination ports | `8080:80,9000:9000`
`env` | Environment variables in key=value format | `DB_HOST=mysql,API_KEY=secret123`
`storage` | Mount path and size for persistent storage | `/test,1Gi`

#### Installation

To install the chart with custom values:

```bash
helm install myapp ./simple \
  --set image=quay.io/myorg/myapp:latest \
  --set hostname=myapp.example.com \
  --set scc=anyuid \
  --set ports=8080:80,9000:9000 \
  --set-literal env="DB_HOST=mysql,API_KEY=secret123" \
  --set-literal storage="/test,1Gi"
```

#### Notes

- When setting environment variables, use `--set-literal` to preserve any special characters
- The `scc` parameter is specific to OpenShift environments
- Ports are specified as `sourcePort:destinationPort` pairs, multiple pairs can be comma-separated
- The hostname parameter will create a Route (OpenShift) or Ingress (Kubernetes) resource
- Storage parameter format is `mountPath,storageSize` where storageSize follows Kubernetes conventions (e.g., Mi, Gi)

### Skupper Hub Bridge Chart

A Helm chart for deploying Skupper Hub Bridge configuration.

#### Configuration Parameters

Parameter | Description | Example
----------|-------------|----------
`dns.zone` | DNS zone for the hub bridge | `example.com`
`clusterName` | Name of the cluster (defaults to namespace) | `my-cluster`

#### Installation

To install the chart with custom values:

```bash
helm install skupper-bridge ./skupper-hub-bridge \
  --set dns.zone=example.com
```

#### Notes

- If `clusterName` is not specified, it will default to the namespace name
- The DNS zone is used to configure the Skupper hub bridge endpoints

## Contributing

Feel free to open issues or pull requests if you have suggestions for improvements or bug fixes.
