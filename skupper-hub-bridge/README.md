# Skupper Hub Bridge Chart

A Helm chart for deploying Skupper Hub Bridge configuration.

## Configuration Parameters

Parameter | Description | Example
----------|-------------|----------
`dns.zone` | DNS zone for the hub bridge | `example.com`
`clusterName` | Name of the cluster (defaults to namespace) | `my-cluster`

## Installation

To install the chart with custom values:

```bash
helm install skupper-bridge ./skupper-hub-bridge \
  --set dns.zone=example.com
```

## Notes

- If `clusterName` is not specified, it will default to the namespace name
- The DNS zone is used to configure the Skupper hub bridge endpoints
