# Release notes for version 0.10.0

**Release date:** 2024-08-21

![AppVersion: v1.102.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.102.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Update note**: `vmalert` main container name was changed to `vmalert`, which will recreate a pod.

**Update note**: `alertmanager` main container name was changed to `alertmanager`, which will recreate a pod.

- Added `basicAuth` support for `ServiceMonitor`
- Removed `PodSecurityPolicy`
- Set minimal kubernetes version to `1.25`
- Removed support for `policy/v1beta1/PodDisruptionBudget`
- Added `.Values.global.imagePullSecrets` and `.Values.global.image.registry`
- Added `.Values.alertmanager.emptyDir` to customize default cache directory
- Addded alertmanager service `.Values.alertmanager.service.externalTrafficPolicy` and `.Values.alertmanager.service.healthCheckNodePort`
- Use static container names in a pod
- Removed `networking.k8s.io/v1beta1/Ingress` and `extensions/v1beta1/Ingress` support
- Added `.Values.server.service.ipFamilies`, `.Values.server.service.ipFamilyPolicy`, `.Values.alertmanager.service.ipFamilies` and `.Values.alertmanager.service.ipFamilyPolicy` for services IP family management

