# kincl's Helm Charts

This repository contains a collection of Helm charts for Kubernetes deployment.

## Using the Published Charts

To use the published charts, add this repository to your Helm repos:

```bash
helm repo add kincl https://kincl.github.io/charts/
helm repo update
```

Then you can install the charts:

```bash
helm install my-release kincl/simple
# or
helm install my-app kincl/standard -f values.yaml
# or
helm install my-bridge kincl/skupper-hub-bridge
```

## Available Charts

### Simple Chart

A flexible, general-purpose Helm chart for deploying applications on Kubernetes.

### Standard Chart

One container as a Deployment and Service, with optional config files, persistent storage and
an Ingress, HTTPRoute or OpenShift Route. Works on plain Kubernetes and OpenShift.

### Skupper Hub Bridge Chart

A Helm chart for deploying Skupper Hub Bridge configuration.

## Contributing

Feel free to open issues or pull requests if you have suggestions for improvements or bug fixes.
