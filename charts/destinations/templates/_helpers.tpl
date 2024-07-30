{{ define "helper.k8s_name" }}
{{- . -}}
{{ end }}

{{ define "helper.alloy_name" }}
{{- . | lower | replace "-" "_" -}}
{{ end }}
