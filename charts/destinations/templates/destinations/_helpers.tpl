{{- define "destination.auth.type" }}
{{- if hasKey . "auth" }}{{ .auth.type | default "none" }}{{ else }}none{{ end }}
{{- end }}

{{- define "destination.secret.type" }}
{{- if hasKey . "secret" }}
  {{- if .secret.embed -}}
embedded
  {{- else if .secret.create -}}
create
  {{- else -}}
external
  {{- end }}
{{- else -}}
create
{{- end }}
{{- end }}

{{- define "pre-existing-secret" }}
{{- if and (hasKey .values "secret") (hasKey .values.secret "create") (not .values.secret.create) }}true{{ else }}false{{ end }}
{{- end }}

{{/*This returns true if:*/}}
{{/*1. It has secret data (anything inside auth)*/}}
{{/*2. It specifically sets secret.create (true or false)*/}}
{{/*3. It specifically does not set secret.embed*/}}
{{- define "uses_k8s_secret" }}
{{- if and (hasKey .values "auth") (not (eq .values.auth.type "none")) }}
  {{- if and (hasKey .values "secret") (not .values.secret.embed) }}true{{ else }}false{{- end }}
{{ else }}false{{- end }}
{{- end }}

{{- define "grafana-telemetry-collector.helper.has_secret" }}
{{- if (include "pre-existing-secret" (dict "values" .values)) }}
true
{{- else if (index .values .key) -}}
true
{{- else -}}
false
{{- end }}
{{- end }}

{{- define "destination.secret.ref" -}}
{{- $defaultKey := (( regexSplit "\\." .key -1) | last) -}}
{{- $value := .values -}}
{{- range $pathPart := (regexSplit "\\." (printf "%sFrom" .key) -1) -}}
{{- if hasKey $value $pathPart -}}
  {{- $value = (index $value $pathPart) -}}
{{- else -}}
  {{- $value = "" -}}
  {{- break -}}
{{- end -}}
{{- end -}}
{{- $value -}}
{{- end -}}


{{- define "destination.secret.key" -}}
{{- $defaultKey := (( regexSplit "\\." .key -1) | last) -}}
{{- $value := .values -}}
{{- range $pathPart := (regexSplit "\\." (printf "%sKey" .key) -1) -}}
{{- if hasKey $value $pathPart -}}
  {{- $value = (index $value $pathPart) -}}
{{- else -}}
  {{- $value = $defaultKey -}}
  {{- break -}}
{{- end -}}
{{- end -}}
{{- $value -}}
{{- end -}}

{{- define "destination.secret.value" }}
{{- $key := .key -}}
{{- $value := .values -}}
{{- range $pathPart := (regexSplit "\\." .key -1) -}}
{{- if hasKey $value $pathPart -}}
  {{- $value = (index $value $pathPart) -}}
{{- else -}}
  {{- fail (printf "cannot find %s" $key) -}}
{{- end -}}
{{- end -}}
{{- $value -}}
{{- end }}


{{- define "destination.secret.read" }}
{{- $credRef := include "destination.secret.ref" (dict "values" .values "key" .key) -}}
{{- if $credRef -}}
{{ $credRef }}
{{- else if eq (include "destination.secret.type" .values) "embedded" -}}
{{ include "destination.secret.value" (dict "values" .values "key" .key) | quote }}
{{- else -}}
{{- $credKey := include "destination.secret.key" (dict "values" .values "key" .key) -}}
{{- if .nonsensitive -}}
nonsensitive(remote.kubernetes.secret.{{ include "helper.alloy_name" .values.name }}.data[{{ $credKey | quote }}])
{{- else -}}
remote.kubernetes.secret.{{ include "helper.alloy_name" .values.name }}.data[{{ $credKey | quote }}]
{{- end -}}
{{- end -}}
{{- end -}}
