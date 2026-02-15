{{/*
PostgreSQL secret name
*/}}
{{- define "nextcloud.postgresql.secretName" -}}
{{- if .Values.postgres.password.secretName }}
{{- .Values.postgres.password.secretName }}
{{- else }}
{{- printf "%s-postgres-secret" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "nextcloud.postgresql.secretKey" -}}
{{- .Values.postgres.password.secretKey | default "password" }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "nextcloud.postgresql.host" -}}
{{- printf "%s-nextcloud-db-rw" .Release.Name }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "nextcloud.postgresql.database" -}}
{{- .Values.postgres.database | default "nextcloud" }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "nextcloud.postgresql.username" -}}
{{- .Values.postgres.username | default "nextcloud" }}
{{- end }}

{{/*
DragonflyDB/Redis secret name
*/}}
{{- define "nextcloud.dragonfly.secretName" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.existingSecret }}
{{- else if .Values.dragonfly.auth.password.secretName }}
{{- .Values.dragonfly.auth.password.secretName }}
{{- else }}
{{- printf "%s-dragonfly-secret" .Release.Name }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis password key
*/}}
{{- define "nextcloud.dragonfly.passwordKey" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.secretKey | default "password" }}
{{- else }}
{{- .Values.dragonfly.auth.password.secretKey | default "password" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis username
*/}}
{{- define "nextcloud.dragonfly.username" -}}
{{- .Values.dragonfly.auth.username | default "default" }}
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

{{/*
DragonflyDB/Redis port
*/}}
{{- define "nextcloud.dragonfly.port" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.port | default "6379" }}
{{- else }}
{{- "6379" }}
{{- end }}
{{- end }}
