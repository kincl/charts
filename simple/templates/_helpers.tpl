{{/*
Always use release name.
*/}}
{{- define "simple.name" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "simple.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "simple.labels" -}}
helm.sh/chart: {{ include "simple.chart" . }}
{{ include "simple.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "simple.selectorLabels" -}}
app.kubernetes.io/name: {{ include "simple.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "simple.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "simple.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Convert comma-delimited env vars to a list of env objects
Usage: {{ include "simple.env" .Values.env | nindent 12 }}
*/}}
{{- define "simple.env" -}}
{{- range $index, $var := splitList "," . }}
{{- $pair := regexSplit "=" (trimPrefix "=" $var) 2 }}
- name: {{ index $pair 0 | quote }}
  value: {{ index $pair 1 | quote }}
{{- end }}
{{- end }}

{{/*
Convert comma-delimited port vars to a list of port objects
Usage: {{ include "simple.ports" .Values.env | nindent 12 }}
*/}}
{{- define "simple.ports" -}}
{{- range $index, $var := splitList "," . }}
{{- $pair := regexSplit ":" (trimPrefix ":" $var) 2 }}
- port: {{ index $pair 0 }}
  targetPort: {{ index $pair 1 }}
  protocol: TCP
  name: port-{{ add $index 1 }}
{{- end }}
{{- end }}

{{/*
Parse a volume entry and return a map with name, mountPath, and size
Usage: {{ include "simple.parseVolume" "/data,1Gi" }}
*/}}
{{- define "simple.parseVolume" -}}
{{- $parts := splitList "," . }}
{{- $mountPath := index $parts 0 }}
{{- $size := index $parts 1 }}
{{- $customName := "" }}
{{- if gt (len $parts) 2 }}
{{- $customName = index $parts 2 }}
{{- end }}
{{- $name := $customName }}
{{- if not $name }}
{{- $name = replace "/" "-" $mountPath | trimPrefix "-" }}
{{- end }}
{{- printf "name: %s\nmountPath: %s\nsize: %s\n" $name $mountPath $size }}
{{- end }}

{{/*
Convert storage string (old format) to list of volume maps
Supports: /data,1Gi (single) or /data,1Gi:/home,10Gi (multi-colon)
*/}}
{{- define "simple.parseStorage" -}}
{{- $storage := .Values.storage }}
{{- if $storage }}
{{- $vols := splitList ":" $storage }}
{{- $count := len $vols }}
{{- range $i, $vol := $vols }}
{{- include "simple.parseVolume" $vol }}
{{- if lt $i (sub $count 1)}}
---
{{- end}}
{{- end }}
{{- end }}
{{- end }}

{{/*
Combine dynamic volumes from .Values.volumes with static storage configuration
Usage: {{ include "simple.volumes" . | nindent 12 }}
*/}}
{{- define "simple.volumes" -}}
{{- $storage := .Values.storage }}
{{- $dynamicVolumes := .Values.volumes | default list -}}

{{- if or $storage $dynamicVolumes }}
volumes:
{{- if $storage }}
{{- $vols := splitList ":" $storage }}
{{- range $i, $vol := $vols }}
{{- $parts := splitList "," $vol }}
{{- $mountPath := index $parts 0 }}
{{- $customName := "" }}
{{- if gt (len $parts) 2 }}
{{- $customName = index $parts 2 }}
{{- end }}
{{- $name := $customName }}
{{- if not $name }}
{{- $name = replace "/" "-" $mountPath | trimPrefix "-" }}
{{- end }}
- name: {{ $name }}
  persistentVolumeClaim:
    claimName: {{ $name }}
{{- end }}
{{- end }}
{{- range $volume := $dynamicVolumes }}
- {{ toYaml $volume | indent 2 | trimPrefix "  " }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Combine dynamic volumes from .Values.volumes with static storage configuration
Usage: {{ include "simple.volumeMounts" . | nindent 12 }}
*/}}
{{- define "simple.volumeMounts" -}}
{{- $storage := .Values.storage }}
{{- $dynamicVolumes := .Values.volumeMounts | default list -}}

{{- if or $storage $dynamicVolumes }}
volumeMounts:
{{- if $storage }}
{{- $vols := splitList ":" $storage }}
{{- range $i, $vol := $vols }}
{{- $parts := splitList "," $vol }}
{{- $mountPath := index $parts 0 }}
{{- $customName := "" }}
{{- if gt (len $parts) 2 }}
{{- $customName = index $parts 2 }}
{{- end }}
{{- $name := $customName }}
{{- if not $name }}
{{- $name = replace "/" "-" $mountPath | trimPrefix "-" }}
{{- end }}
- mountPath: {{ $mountPath }}
  name: {{ $name }}
{{- end }}
{{- end }}
{{- range $volume := $dynamicVolumes }}
- {{ toYaml $volume | indent 2 | trimPrefix "  " }}
{{- end }}
{{- end }}
{{- end }}
