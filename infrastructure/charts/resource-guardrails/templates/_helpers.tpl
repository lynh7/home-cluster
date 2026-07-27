{{- define "resource-guardrails.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "resource-guardrails.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "resource-guardrails.name" . -}}
{{- end -}}
{{- end -}}

{{- define "resource-guardrails.labels" -}}
app.kubernetes.io/name: {{ include "resource-guardrails.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "resource-guardrails.policyName" -}}
{{- $root := .root -}}
{{- $policy := .policy -}}
{{- default (printf "%s-%s" (include "resource-guardrails.fullname" $root) $policy.name) $policy.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "resource-guardrails.bindingName" -}}
{{- $root := .root -}}
{{- $policy := .policy -}}
{{- default (printf "%s-%s-binding" (include "resource-guardrails.fullname" $root) $policy.name) $policy.bindingName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
