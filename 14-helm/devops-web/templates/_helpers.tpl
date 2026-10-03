{{- define "devops-web.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "devops-web.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "devops-web.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "devops-web.labels" -}}
app.kubernetes.io/name: {{ include "devops-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{- define "devops-web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "devops-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
