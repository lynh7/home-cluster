▶️ Using the issuer in your application charts
Once the internal-ca chart is installed, the ClusterIssuer named internal-ca-issuer (by default) is ready. In your application’s Helm chart you can simply reference it:

yaml
# templates/certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ include "mychart.fullname" . }}-tls
spec:
  secretName: {{ include "mychart.fullname" . }}-tls
  issuerRef:
    name: {{ .Values.tls.issuerName }}   # e.g. internal-ca-issuer
    kind: ClusterIssuer
  commonName: {{ .Values.tls.commonName }}
  dnsNames:
    - {{ .Values.tls.commonName }}
And set in your app’s values.yaml:

yaml
tls:
  issuerName: internal-ca-issuer
  commonName: my-service.internal.lan
