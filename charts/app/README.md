# app

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.10.2](https://img.shields.io/badge/AppVersion-v1.10.2-informational?style=flat-square)

A minimal, hardened chart for a single-pod stateless application

A deliberately small chart: one Deployment, one Service, an optional Ingress, and
a ServiceAccount. Defaults are hardened (non-root, read-only root filesystem, all
capabilities dropped, no service-account token mounted) and `values.schema.json`
rejects unknown or malformed values at install time rather than producing a
subtly broken manifest.

## Install

```console
helm repo add mycroft https://mycroft.github.io/helm-charts/
helm repo update
helm install my-app mycroft/app \
  --set image.repository=ghcr.io/mycroft/my-app \
  --set image.tag=v1.2.3
```

Or straight from the OCI registry, no `helm repo add` needed:

```console
helm install my-app oci://ghcr.io/mycroft/charts/app --version 0.1.0
```

## Notes on the defaults

- **`image.repository` is a placeholder** (`traefik/whoami`) so that a bare
  `helm install` works. Always override it.
- **No CPU limit.** Only a memory limit is set: CPU throttling degrades tail
  latency without giving the node the protection a memory limit does.
- **`serviceAccount.automount` is `false`.** Turn it on only if the workload
  actually calls the Kubernetes API.
- **`readOnlyRootFilesystem: true`.** If your image writes to disk, mount an
  `emptyDir` via `volumes`/`volumeMounts` rather than relaxing this.
- **Probes assume an HTTP endpoint on `/`.** Point them at a real health path,
  or set them to `{}` to disable.

## Requirements

Kubernetes: `>=1.27.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of replicas. This chart targets single-pod workloads; raising this is supported but you are then responsible for the app tolerating concurrency. |
| image.repository | string | `"traefik/whoami"` | Container image repository. Replace this placeholder with your own image. |
| image.tag | string | `""` | Image tag. Defaults to `.Chart.AppVersion` when empty. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| imagePullSecrets | list | `[]` | Secrets used to pull the image, e.g. `[{name: my-regcred}]` |
| nameOverride | string | `""` | Override the chart name used in resource names |
| fullnameOverride | string | `""` | Override the fully qualified resource name |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount |
| serviceAccount.automount | bool | `false` | Mount the ServiceAccount token into the pod. Leave `false` unless the app actually talks to the Kubernetes API. |
| serviceAccount.annotations | object | `{}` | Annotations for the ServiceAccount (e.g. IRSA / Workload Identity) |
| serviceAccount.name | string | `""` | Name of the ServiceAccount. Generated from the fullname when empty. |
| podAnnotations | object | `{}` | Extra annotations for the pod |
| podLabels | object | `{}` | Extra labels for the pod |
| podSecurityContext | object | `{"fsGroup":65532,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod-level security context |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true}` | Container-level security context |
| command | list | `[]` | Override the image entrypoint |
| args | list | `["--port=8080"]` | Arguments passed to the container |
| containerPort | int | `8080` | Port the container listens on |
| env | list | `[]` | Environment variables, in plain Kubernetes `EnvVar` form |
| envFrom | list | `[]` | ConfigMaps / Secrets to load wholesale as environment variables |
| volumes | list | `[]` | Extra volumes for the pod |
| volumeMounts | list | `[]` | Extra volume mounts for the container |
| resources | object | `{"limits":{"memory":"128Mi"},"requests":{"cpu":"10m","memory":"32Mi"}}` | Resource requests and limits. A CPU limit is deliberately omitted: CPU throttling degrades latency without protecting the node the way a memory limit does. |
| livenessProbe | object | `{"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":5,"periodSeconds":10}` | Liveness probe. Set to `{}` to disable. |
| readinessProbe | object | `{"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":2,"periodSeconds":5}` | Readiness probe. Set to `{}` to disable. |
| startupProbe | object | `{}` | Startup probe. Set to `{}` to disable. |
| service.enabled | bool | `true` | Create a Service for the pod |
| service.type | string | `"ClusterIP"` | Service type |
| service.port | int | `80` | Service port |
| service.annotations | object | `{}` | Extra annotations for the Service |
| ingress.enabled | bool | `false` | Create an Ingress for the Service |
| ingress.className | string | `""` | IngressClass name |
| ingress.annotations | object | `{}` | Extra annotations for the Ingress |
| ingress.hosts | list | `[]` | Hosts and paths, e.g. `[{host: app.example.com, paths: [{path: /, pathType: Prefix}]}]` |
| ingress.tls | list | `[]` | TLS configuration, in plain Kubernetes `IngressTLS` form |
| strategy | object | `{}` | Deployment update strategy. `Recreate` is a common choice for single-pod apps that cannot run two instances at once. |
| terminationGracePeriodSeconds | int | `30` | Grace period before the pod is killed |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| tolerations | list | `[]` | Tolerations for pod assignment |
| affinity | object | `{}` | Affinity rules for pod assignment |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| mycroft |  |  |

---

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
