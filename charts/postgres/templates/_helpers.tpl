{{/*
Secret name for PostgreSQL password.
Uses password.secretName if provided, otherwise generates one from Release.Name.
*/}}
{{- define "postgres.secretName" -}}
{{- if .Values.password.secretName }}
{{- .Values.password.secretName }}
{{- else }}
{{- printf "%s-postgres-secret" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host for client connections.
*/}}
{{- define "postgres.host" -}}
{{- if eq .Values.mode "standalone" }}
{{- printf "%s-postgres" .Release.Name }}
{{- else if eq .Values.mode "cluster" }}
{{- printf "%s-postgres-cluster-rw" .Release.Name }}
{{- else }}
{{- .Values.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port for client connections.
*/}}
{{- define "postgres.port" -}}
{{- if eq .Values.mode "external" }}
{{- .Values.external.port | default "5432" }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username.
*/}}
{{- define "postgres.username" -}}
{{- .Values.username | default "postgres" }}
{{- end }}

{{/*
PostgreSQL database name.
*/}}
{{- define "postgres.database" -}}
{{- .Values.database | default "postgres" }}
{{- end }}

{{/*
CNPG Cluster resource name: {Release.Name}-postgres-cluster
*/}}
{{- define "postgres.clusterName" -}}
{{- printf "%s-postgres-cluster" .Release.Name }}
{{- end }}
{{/*
Common labels
*/}}
{{- define "postgres.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: postgres
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "postgres.selectorLabels" -}}
app.kubernetes.io/name: postgres
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
