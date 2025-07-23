{{- define "skupper-hub-bridge.escapedZone" -}}
{{- .Values.dns.zone | replace "." "\\." -}}
{{- end -}}

{{- define "skupper-hub-bridge.clusterName" -}}
{{- if .Values.clusterName -}}
{{- .Values.clusterName -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "skupper-hub-bridge.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "skupper-hub-bridge.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "skupper-hub-bridge.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "skupper-hub-bridge.labels" -}}
helm.sh/chart: {{ include "skupper-hub-bridge.chart" . }}
{{ include "skupper-hub-bridge.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "skupper-hub-bridge.selectorLabels" -}}
app.kubernetes.io/name: {{ include "skupper-hub-bridge.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
