
# Argo CD Meta-Chart

Managed Argo CD with custom configurations.

## Prerequisites

- Helm 3.x or newer
- Kubernetes 1.21+
- An existing Kubernetes cluster

## Installation

1. Update dependencies:

   ```bash
   helm dependency update meta-argo-cd/
   ```

2. Install the chart:

   ```bash
   helm install argocd-instance ./meta-argo-cd -n argocd --create-namespace
   ```

## Configuration

You can customize your Argo CD setup by editing `values.yaml`. Examples:

- **Set Argo CD Version**:

  ```yaml
  argo-cd:
    global:
      image:
        tag: "v2.9.5"
  ```

- **Expose Service via LoadBalancer**:

  ```yaml
  argo-cd:
    server:
      service:
        type: LoadBalancer
  ```

To apply custom settings, create a `my-values.yaml` and use:

```bash
helm install argocd-instance ./argocd-meta-chart -f my-values.yaml -n argocd
```

## Upgrading

Update dependencies and run:

```bash
helm upgrade argocd-instance ./argocd-meta-chart -n argocd
```
