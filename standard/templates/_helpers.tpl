{{/*
Always use release name.
*/}}
{{- define "standard.name" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "standard.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "standard.labels" -}}
helm.sh/chart: {{ include "standard.chart" . }}
{{ include "standard.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "standard.selectorLabels" -}}
app.kubernetes.io/name: {{ include "standard.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "standard.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "standard.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ConfigMap key for a file path: /etc/app/config.yml → etc_app_config.yml
*/}}
{{- define "standard.fileKey" -}}
{{- trimPrefix "/" . | replace "/" "_" }}
{{- end }}

{{/*
Tag of an image reference, "latest" if it has none.
Example: "registry:5000/org/app:1.2" → "1.2"
*/}}
{{- define "standard.imageTag" -}}
{{- $last := last (splitList "/" .) }}
{{- if contains ":" $last }}
{{- last (splitList ":" $last) }}
{{- else }}
{{- "latest" }}
{{- end }}
{{- end }}

{{/*
Image the container runs: the internal-registry copy when imported through an ImageStream.
*/}}
{{- define "standard.image" -}}
{{- if .Values.openshift.imageStream }}
{{- printf "image-registry.openshift-image-registry.svc:5000/%s/%s:%s" .Release.Namespace (include "standard.name" .) (include "standard.imageTag" .Values.image) }}
{{- else }}
{{- .Values.image }}
{{- end }}
{{- end }}

{{/*
Service port for "http"
*/}}
{{- define "standard.servicePort" -}}
{{- .Values.service.port | default .Values.port }}
{{- end }}

{{/*
How expose publishes the hostname: ingress, httproute or route.
*/}}
{{- define "standard.exposeType" -}}
{{- $type := .Values.expose.type }}
{{- if not $type }}
{{- $type = ternary "route" "ingress" (.Capabilities.APIVersions.Has "route.openshift.io/v1") }}
{{- end }}
{{- if not (has $type (list "ingress" "httproute" "route")) }}
{{- fail (printf "expose.type must be ingress, httproute or route, not %q" $type) }}
{{- end }}
{{- if and .Values.expose.hostname (not .Values.port) }}
{{- fail "expose.hostname needs port" }}
{{- end }}
{{- $type }}
{{- end }}
