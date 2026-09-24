## DEPLOY FLUXCD VIA HELM
# helm upgrade --install fluxcd  . -n flux-system --create-namespace -f values.yaml 
# flux create secret git github-pat-auth --namespace=flux-system --url=https://github.com/lynh7/home-talos-cluster --username=lynh7  --password=$(GIT_PAT)
# helm upgrade --install fluxcd-custom  . -n flux-system --create-namespace

# Longhorn namespace needs to be installed manually (infrastructure/staging/longhorn/namespace.yaml).

# Note: the repo was renamed to lynh7/home-cluster; templates/gitrepository.yaml still uses the old URL (works via GitHub redirect).
# Deployed stacks: see docs/current-state.md. Add a stack with templates/kustomization/<infra-stacks|application>/<name>.yaml.
