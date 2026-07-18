## DEPLOY FLUXCD VIA HELM
# helm upgrade --install fluxcd  . -n flux-system --create-namespace -f values.yaml 
# flux create secret git github-pat-auth --namespace=flux-system --url=https:/github.com/lynh7/home-talos-cluster --username=lynh7  --password=$(GIT_PAT)
# helm upgrade --install fluxcd-custom  . -n flux-system --create-namespace

# Longhorn namespace needs to be installed manually.