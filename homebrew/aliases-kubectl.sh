# Oh My Zsh Kubectl Aliases

# This command is used a LOT both below and in daily life
alias k=kubectl
alias kx=kubectx
alias kn=kubens

# Exec into all namespaces
alias kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'

# Apply (f for file)
alias kaf='kubectl apply -f'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -t -i'

# Manage configuration context
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'
alias kcgc='kubectl config get-contexts'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'

# Pod management.
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'
alias kgpl='kubectl get pods -l'
alias kgpn='kubectl get pods -n'

# Service management.
alias kgs='kubectl get svc'
alias kgsa='kubectl get svc --all-namespaces'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias kgia='kubectl get ingress --all-namespaces'
alias kes='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl delete ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdelns='kubectl delete namespace'
alias kcn='kubectl config set-context --current --namespace'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kgcma='kubectl get configmaps --all-namespaces'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secrets'
alias kgseca='kubectl get secrets --all-namespaces'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
alias kgda='kubectl get deployment --all-namespaces'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'

# Rollout management.
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Statefulset management.
alias kgss='kubectl get statefulset'
alias kgssa='kubectl get statefulset --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswide='kgss -o wide'
alias kess='kubectl edit statefulset'
alias kdss='kubectl describe statefulset'
alias kdelss='kubectl delete statefulset'
alias ksss='kubectl scale statefulset'
alias krsss='kubectl rollout status statefulset'

# Node management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'

# Job management
alias kgj='kubectl get jobs'
alias kej='kubectl edit job'
alias kdj='kubectl describe job'
alias kdelj='kubectl delete job'

# CronJob management
alias kgcj='kubectl get cronjobs'
alias kecj='kubectl edit cronjob'
alias kdcj='kubectl describe cronjob'
alias kdelcj='kubectl delete cronjob'

# Rollout management
alias krrd='kubectl rollout restart deployment'
alias krrs='kubectl rollout restart statefulset'
alias krrds='kubectl rollout restart daemonset'
