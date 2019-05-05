{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "polling.name" -}}
{{- default "polling" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "polling.fullname" -}}
{{- $name := default "polling" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "polling.labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app: "{{ template "polling.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "polling.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ template "polling.name" . }}"
{{- end -}}

{{- define "polling.database" -}}
  {{- printf "%s-database" (include "polling.fullname" .) -}}
{{- end -}}

{{- define "polling.database.host" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- template "polling.database" . }}
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "polling.database.port" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "3306" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "polling.database.name" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.database -}}
  {{- else -}}
    {{- .Values.database.external.database -}}
  {{- end -}}
{{- end -}}

{{- define "polling.database.username" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.username -}}
  {{- else -}}
    {{- .Values.database.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "polling.database.rawPassword" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{- define "polling.database.encryptedPassword" -}}
  {{- include "polling.database.rawPassword" . | b64enc | quote -}}
{{- end -}}

{{- define "polling.api" -}}
  {{- printf "%s-api" (include "polling.fullname" .) -}}
{{- end -}}

{{- define "polling.ui" -}}
  {{- printf "%s-ui" (include "polling.fullname" .) -}}
{{- end -}}

{{- define "polling.ingress" -}}
  {{- printf "%s-ingress" (include "polling.fullname" .) -}}
{{- end -}}


