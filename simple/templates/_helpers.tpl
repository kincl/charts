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
Parse a storage volume entry and return flow-style YAML map
Usage: {{ include "simple.parseStorageVolume" . }}
Returns: flow-style YAML like "{name: data, mountPath: /data, size: 1Gi}"
*/}}
{{- define "simple.parseStorageVolume" -}}
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
{{- printf "{name: %s, mountPath: %s, size: %s}" $name $mountPath $size }}
{{- end }}

{{/*
Convert storage string to list of volume maps
Usage: {{ include "simple.parseStorage" . | fromYaml }}
Returns: list of maps from parseStorageVolume
*/}}
{{- define "simple.parseStorage" -}}
{{- $storage := .Values.storage }}
{{- if $storage }}
{{- $vols := splitList ":" $storage }}
{{- $result := list }}
{{- range $i, $vol := $vols }}
{{- $result = append $result (include "simple.parseStorageVolume" $vol) }}
{{- end }}
{{- $result | toYaml }}
{{- else }}
{{- "[]" }}
{{- end }}
{{- end }}

{{/*
Output volume entry for volumes list
Usage: {{ include "simple.volumeEntry" . | nindent 2 }}
*/}}
{{- define "simple.volumeEntry" -}}
{{- $vol := include "simple.parseStorageVolume" . | fromYaml }}
- name: {{ $vol.name }}
  persistentVolumeClaim:
    claimName: {{ $vol.name }}
{{- end }}

{{/*
Output volumeMount entry for volumeMounts list
Usage: {{ include "simple.volumeMountEntry" . | nindent 2 }}
*/}}
{{- define "simple.volumeMountEntry" -}}
{{- $vol := include "simple.parseStorageVolume" . | fromYaml }}
- mountPath: {{ $vol.mountPath }}
  name: {{ $vol.name }}
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
{{- range $volStr := $vols }}
{{- include "simple.volumeEntry" $volStr }}
{{- end }}
{{- end }}
{{- range $volume := $dynamicVolumes }}
- {{ toYaml $volume | nindent 2 }}
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
{{- range $volStr := $vols }}
{{- include "simple.volumeMountEntry" $volStr }}
{{- end }}
{{- end }}
{{- range $volume := $dynamicVolumes }}
- {{ toYaml $volume | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}