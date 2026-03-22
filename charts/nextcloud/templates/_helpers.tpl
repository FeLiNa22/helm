{{/*
PostgreSQL host
*/}}
{{- define "nextcloud.postgresql.host" -}}
{{- if eq .Values.postgres.mode "standalone" }}
{{- printf "%s-postgres" .Release.Name }}
{{- else if eq .Values.postgres.mode "cluster" }}
{{- printf "%s-postgres-cluster-rw" .Release.Name }}
{{- else if eq .Values.postgres.mode "external" }}
{{- .Values.postgres.external.host }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis host
*/}}
{{- define "nextcloud.dragonfly.host" -}}
{{- if eq .Values.dragonfly.mode "standalone" }}
{{- printf "%s-dragonfly" .Release.Name }}
{{- else if eq .Values.dragonfly.mode "cluster" }}
{{- printf "%s-dragonfly-cluster" .Release.Name }}
{{- else if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.host }}
{{- end }}
{{- end }}

