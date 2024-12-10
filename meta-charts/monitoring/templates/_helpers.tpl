{{/* Validates the supported clusters */}}
{{- define "monitoring.clusterPathCheck" -}}
{{- if not (has $.Values.cluster (list "ioaiaaii")) }}
  {{ required "\nThe `.Values.cluster` must be one of: \n [ioaiaaii]! \n If you provide a new cluster, please add it in the list. " nil }}
{{- end }}
{{- end }}

{{/*
clusterPath, gets the Values.cluster and set the path of the prometheus rules.
This allows dynamic set per release
*/}}
{{- define "monitoring.rulesPath" -}}
{{ include "monitoring.clusterPathCheck" . }}
{{- printf "*/%s/*.yml" $.Values.prometheus.rulesPath -}}
{{- end -}}

{{/*
clusterPath, gets the Values.cluster and set the path of the prometheus rules.
This allows dynamic set per release
*/}}
{{- define "monitoring.dashboardsPath" -}}
{{ include "monitoring.clusterPathCheck" . }}
{{- printf "*/%s/*.json" $.Values.grafana.dashboardsPath -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "monitoring.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "monitoring.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "monitoring.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/* Generate basic labels */}}
{{- define "monitoring.labels" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ replace "+" "_" .Chart.Version }}"
app.kubernetes.io/part-of: {{ template "monitoring.name" . }}
chart: {{ template "monitoring.chartref" . }}
release: {{ $.Release.Name | quote }}
heritage: {{ $.Release.Service | quote }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "monitoring.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}