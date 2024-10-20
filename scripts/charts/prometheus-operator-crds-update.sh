#!/bin/bash

# Script to download and replace Prometheus Operator CRDs with JSON logging
# Version: 1.6

set -euo pipefail

# Default version if not provided by the user
DEFAULT_PROMETHEUS_OPERATOR_VERSION="v0.60.1"

# Default target directory
TARGET_DIR="../../meta-charts/kube-prometheus-stack/crds"
CHART_YAML_PATH="../../meta-charts/kube-prometheus-stack/Chart.yaml"

# Extract the appVersion from Chart.yaml using yq
PROMETHEUS_OPERATOR_VERSION=$(yq eval '.appVersion' "$CHART_YAML_PATH")

# Fallback if yq fails or the version is empty
if [[ -z "$PROMETHEUS_OPERATOR_VERSION" ]]; then
  echo "Failed to read appVersion from $CHART_YAML_PATH or version is empty."
  exit 1
fi

BASE_URL="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${PROMETHEUS_OPERATOR_VERSION}/example/prometheus-operator-crd"
CRD_FILES=(
  "monitoring.coreos.com_alertmanagerconfigs.yaml"
  "monitoring.coreos.com_alertmanagers.yaml"
  "monitoring.coreos.com_podmonitors.yaml"
  "monitoring.coreos.com_probes.yaml"
  "monitoring.coreos.com_prometheuses.yaml"
  "monitoring.coreos.com_prometheusrules.yaml"
  "monitoring.coreos.com_servicemonitors.yaml"
  "monitoring.coreos.com_thanosrulers.yaml"
)

# Function to log messages in JSON format
json_log() {
  local LEVEL="$1"
  local MESSAGE="$2"
  local TIMESTAMP
  TIMESTAMP=$(date '+%Y-%m-%dT%H:%M:%S%z')

  # Print JSON log entry
  echo "{\"timestamp\": \"${TIMESTAMP}\", \"level\": \"${LEVEL}\", \"message\": \"${MESSAGE}\"}"
}

# Function to download a file
download_crd() {
  local FILE="$1"
  local URL="${BASE_URL}/${FILE}"
  
  json_log "INFO" "Downloading ${FILE}..."
  
  if curl -sS -O -L "${URL}" 2>/dev/null; then
    json_log "INFO" "Successfully downloaded ${FILE}."
  else
    json_log "ERROR" "Failed to download ${FILE}."
    exit 1
  fi
}

# Function to replace CRDs in the target directory
replace_crds() {
  local FILE="$1"
  local TARGET_PATH="${TARGET_DIR}/${FILE}"

  if mv -f "${FILE}" "${TARGET_PATH}"; then
    json_log "INFO" "Replaced ${FILE} in ${TARGET_DIR}."
    rm -f "${FILE}"
  else
    json_log "ERROR" "Failed to replace ${FILE} in ${TARGET_DIR}."
    exit 1
  fi
}

# Main script
main() {
  json_log "INFO" "Starting download for Prometheus Operator version: ${PROMETHEUS_OPERATOR_VERSION}"
  
  for CRD in "${CRD_FILES[@]}"; do
    download_crd "${CRD}"
    replace_crds "${CRD}"
  done

  json_log "INFO" "All CRD files have been downloaded, replaced, and cleaned up successfully."
}

# Execute the script
main
