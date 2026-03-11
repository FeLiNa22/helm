{{/*
Return the secret name for the dragonfly password.
*/}}
{{- define "dragonfly.secretName" -}}
{{- if .Values.password.secretName -}}
{{ .Values.password.secretName }}
{{- else -}}
{{ .Release.Name }}-dragonfly-secret
{{- end -}}
{{- end -}}

{{/*
Return the secret key for the dragonfly password.
*/}}
{{- define "dragonfly.passwordKey" -}}
{{ .Values.password.secretKey | default "password" }}
{{- end -}}

{{/*
Return the dragonfly username.
*/}}
{{- define "dragonfly.username" -}}
{{ .Values.username | default "default" }}
{{- end -}}

{{/*
Return the dragonfly host based on mode.
*/}}
{{- define "dragonfly.host" -}}
{{- if eq .Values.mode "standalone" -}}
{{ .Release.Name }}-dragonfly
{{- else if eq .Values.mode "cluster" -}}
{{ .Release.Name }}-dragonfly-cluster
{{- else -}}
{{ .Values.external.host }}
{{- end -}}
{{- end -}}

{{/*
Return the dragonfly port based on mode.
*/}}
{{- define "dragonfly.port" -}}
{{- if eq .Values.mode "external" -}}
{{ .Values.external.port }}
{{- else -}}
6379
{{- end -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "dragonfly.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
app.kubernetes.io/name: dragonfly
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: dragonfly
{{- end -}}

{{/*
Labels for the DragonflyDB cluster CR (component: dragonfly-cluster).
*/}}
{{- define "dragonfly.clusterLabels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
app.kubernetes.io/name: dragonfly
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: dragonfly-cluster
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "dragonfly.selectorLabels" -}}
app.kubernetes.io/name: dragonfly
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: dragonfly
{{- end -}}
