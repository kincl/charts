# Standard Chart

One container as a Deployment and Service, with optional config files, persistent storage and
a hostname published through an Ingress, Gateway API HTTPRoute or OpenShift Route. It works on
plain Kubernetes and OpenShift.

Values are plain YAML. Common things have short forms (`env`, `files`, `persistence`,
`healthCheck`); everything else passes through as raw Kubernetes fields (`extraEnv`,
`extraVolumes`, `securityContext`, ...). It is deliberately one workload: no sidecars,
init containers, StatefulSets or CronJobs.

## Example

```yaml
image: docker.io/searxng/searxng:2026.10.27-abc1234
port: 8080

env:
  SEARXNG_BASE_URL: https://search.example.com/
extraEnv:
  - name: SEARXNG_SECRET
    valueFrom:
      secretKeyRef: {name: searxng, key: secret}

files:
  /etc/searxng/settings.yml: |
    use_default_settings: true
    server:
      limiter: false

healthCheck: /healthz

expose:
  hostname: search.example.com
  className: cilium
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
```

```bash
helm repo add kincl https://kincl.github.io/charts/
helm install searxng kincl/standard -n searxng -f values.yaml
```

## Values

Value | Description
------|------------
`image` | Container image (required)
`port` | Main container port, named `http`. The Service, `expose` and `healthCheck` use it
`extraPorts` | More ports, `name: containerPort`. Also added to the Service
`command`, `args` | Container command and args
`env` | Literal variables, `NAME: value`
`extraEnv`, `envFrom` | Raw `EnvVar` / `EnvFromSource` lists, for secrets and field refs
`files` | `/absolute/path: content`. Rendered into the `<release>-files` ConfigMap and mounted read-only with `subPath`. A change rolls the pod
`persistence` | `name: {mountPath, size, storageClass, accessMode, existingClaim, keep}`. Creates PVC `<release>-<name>` unless `existingClaim` is set. `keep` (default `true`) keeps it on uninstall and Argo CD prune
`healthCheck` | HTTP GET path for liveness and readiness on `http`. `livenessProbe` / `readinessProbe` / `startupProbe` take raw probes and override it
`service.type`, `service.port`, `service.appProtocol`, `service.annotations` | Service settings for `http` (`port` defaults to `port`)
`expose.hostname` | Publish `http` at this hostname. Nothing is created when empty
`expose.type` | `ingress`, `httproute` or `route`. Empty: `route` on OpenShift, otherwise `ingress`
`expose.path` | Path prefix, default `/`
`expose.annotations` | Annotations on the Ingress/HTTPRoute/Route (e.g. cert-manager)
`expose.className` | `ingressClassName` (ingress)
`expose.tls`, `expose.tlsSecretName` | ingress: TLS from secret `<release>-tls` (or `tlsSecretName`). route: edge termination with redirect. Default `true`
`expose.parentRefs` | Gateway parentRefs (httproute, required)
`openshift.imageStream` | Import `image` through an ImageStream and run it from the internal registry
`openshift.scc` | Bind this SCC to the service account (`anyuid`, `nonroot-v2`, `privileged`, ...)
`serviceAccount.*` | Create or name the service account
`replicas`, `strategy` | Default `1`, `Recreate` (so a ReadWriteOnce volume is released first)
`podAnnotations`, `podLabels`, `podSecurityContext`, `securityContext`, `resources`, `extraVolumes`, `extraVolumeMounts`, `nodeSelector`, `tolerations`, `affinity` | Raw passthrough

## Notes

- Pod Security `restricted` needs a security context, e.g.
  `securityContext: {allowPrivilegeEscalation: false, capabilities: {drop: [ALL]}}` and
  `podSecurityContext: {runAsNonRoot: true, seccompProfile: {type: RuntimeDefault}}`.
- `expose` auto-detects OpenShift from the cluster's API versions (`helm install` and Argo CD
  both pass them). Plain `helm template` doesn't, so pass `--api-versions route.openshift.io/v1`
  or set `expose.type`.
