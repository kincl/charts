# Helm Charts

This is a Helm repository hosted on GitHub Pages. It contains the following charts:

- `simple`: A simple Helm chart
- `standard`: One container with config files, storage and an Ingress, HTTPRoute or Route
- `skupper-hub-bridge`: A Helm chart for Skupper Hub Bridge

## Using this Repository

Add this repository to your Helm installation:

```bash
helm repo add kincl https://kincl.github.io/charts/
helm repo update
```

## Installing Charts

You can then install charts from this repository:

```bash
# Install the simple chart
helm install my-release kincl/simple

# Install the standard chart
helm install my-app kincl/standard -f values.yaml

# Install the skupper-hub-bridge chart
helm install my-bridge kincl/skupper-hub-bridge
```
