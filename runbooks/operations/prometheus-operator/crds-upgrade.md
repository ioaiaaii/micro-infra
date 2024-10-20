# Runbook: Updating CRDs for Prometheus Operator

## Overview

This runbook describes the steps to update the Custom Resource Definitions (CRDs) for the Prometheus Operator in the `kube-prometheus-stack` meta chart. Managing CRDs independently ensures they stay in sync with the correct Prometheus Operator version, as Helm only installs CRDs during the initial deployment.

## Prerequisites

- Ensure that `yq` is installed and available on your system. The script uses `yq` to extract the `appVersion` from `Chart.yaml`.
- Access to the `kube-prometheus-stack` meta chart directory.
- Permissions to modify files in the `crds` directory.

## Procedure

### Step 1: Verify the Prometheus Operator Version

The script automatically extracts the `appVersion` from the `Chart.yaml` file located in the `kube-prometheus-stack` directory. Ensure that the `appVersion` matches the desired version of the Prometheus Operator.

**Example `Chart.yaml` snippet:**

```yaml
apiVersion: v2
name: kube-prometheus-stack
type: application
appVersion: v0.77.1  # Prometheus Operator version
version: 1.0.0
```

### Step 2: Locate the Update Script

The script to update CRDs is located at:
[scripts/charts/prometheus-operator-crds-update.sh](./scripts/charts/prometheus-operator-crds-update.sh)

### Step 3: Prepare the Script

Make the script executable if it is not already:

```bash
chmod +x scripts/charts/prometheus-operator-crds-update.sh
```

### Step 4: Execute the Script

Run the script to download the latest CRDs based on the `appVersion` defined in `Chart.yaml`:

```bash
./scripts/charts/prometheus-operator-crds-update.sh
```

### Step 5: Verify the Update

After the script completes, verify that the CRDs in the [crds](./crds/) directory have been updated. The script will:

- Download the latest CRDs from the Prometheus Operator GitHub repository.
- Replace the existing CRDs in the `crds` directory.
- Clean up any temporary files used during the process.

### Expected Output

The script will provide JSON-formatted log messages indicating the progress of the operation. Examples:

```json
{"timestamp": "2024-10-20T12:34:56+0000", "level": "INFO", "message": "Downloading monitoring.coreos.com_alertmanagers.yaml..."}
{"timestamp": "2024-10-20T12:34:59+0000", "level": "INFO", "message": "Successfully downloaded monitoring.coreos.com_alertmanagers.yaml."}
{"timestamp": "2024-10-20T12:35:05+0000", "level": "INFO", "message": "Replaced monitoring.coreos.com_alertmanagers.yaml in crds directory."}
```

## Troubleshooting

- **Script fails to download CRDs**: Ensure that the `appVersion` in `Chart.yaml` is correct and corresponds to a valid release version of the Prometheus Operator.
- **Permissions issues**: Confirm you have write permissions to the `crds` directory.
- **`yq` not found**: Verify that `yq` is installed and accessible in your system's `$PATH`.

## Additional Notes

- This runbook helps automate the process of updating CRDs, reducing the risk of mismatched versions and manual errors.
- Ensure that any updates to `Chart.yaml` are committed to version control to track changes in the Prometheus Operator version.

## References

- [Prometheus Operator GitHub Repository](https://github.com/prometheus-operator/prometheus-operator)
