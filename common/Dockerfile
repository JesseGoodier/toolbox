FROM golang:alpine AS builder

# Initialize output directories
RUN mkdir -p /out/usr/local/bin

# 1. yq (latest version)
RUN go install github.com/mikefarah/yq/v4@latest && \
    mv /go/bin/yq /out/usr/local/bin/yq

# === Final Stage ===
FROM python:3.14-alpine
LABEL org.opencontainers.image.source=https://github.com/jessegoodier/toolbox

# Install packages available via apk
# Included caching for apk
RUN --mount=type=cache,target=/var/cache/apk \
    apk upgrade --no-cache && \
    apk add \
    # Shell and basics
    zsh bash bash-completion zsh-syntax-highlighting zsh-autosuggestions \
    # HTTP and data transfer
    curl wget \
    # JSON/YAML processing
    jq \
    # Search and file tools
    ripgrep rclone tree less file the_silver_searcher coreutils \
    # Networking and DNS
    bind-tools netcat-openbsd tcpdump openssl mtr iputils doggo \
    # Kubernetes tools
    kubectl \
    # System and process debugging
    htop strace procps lsof \
    # Editors and version control
    vim neovim git \
    # Compatibility and certs
    ca-certificates \
    # python utils
    uv gcompat libc6-compat \
    # Interactive tools
    fzf fd eza \
    # admin tools
    shadow su-exec sudo \
    && update-ca-certificates \
    && python -m pip install --upgrade pip

# Copy binaries and tools from builder
COPY --from=builder /out /

# Generate completions
RUN mkdir -p /toolbox \
    && mkdir -p /usr/share/bash-completion/completions \
    && mkdir -p /usr/share/zsh/site-functions

RUN kubectl completion bash > /usr/share/bash-completion/completions/kubectl && \
    yq shell-completion bash > /usr/share/bash-completion/completions/yq && \
    rclone completion bash /usr/share/bash-completion/completions/rclone && \
    (doggo completion bash > /usr/share/bash-completion/completions/doggo || echo "doggo bash completion failed") && \
    echo "complete -C '/usr/bin/aws_completer' aws" > /usr/share/bash-completion/completions/aws && \
    kubectl completion zsh > /usr/share/zsh/site-functions/_kubectl && \
    yq shell-completion zsh > /usr/share/zsh/site-functions/_yq && \
    rclone completion zsh /usr/share/zsh/site-functions/_rclone && \
    (doggo completion zsh > /usr/share/zsh/site-functions/_doggo || echo "doggo zsh completion failed")

# Copy configuration files (Last to optimize caching)
# Create user toolbox with uid 1001
RUN adduser -D -u 1001 -s /bin/zsh toolbox

# Copy configuration files
COPY .zshrc .bashrc .vimrc shell-common aliases-git.sh aliases-kubectl.sh /home/toolbox/
# Also copy to root for root shell usage
COPY .zshrc .bashrc .vimrc shell-common aliases-git.sh aliases-kubectl.sh /root/
# Copy rclone config template
RUN mkdir -p /home/toolbox/.config/rclone /root/.config/rclone
COPY rclone.conf /home/toolbox/.config/rclone/rclone.conf
COPY rclone.conf /root/.config/rclone/rclone.conf
# Copy kube config fix script
COPY kube-config-fix.sh /usr/local/bin/kube-config-fix.sh

# Configure permissions for arbitrary users (OpenShift/K8s random UID support)
# We make /home/toolbox writable by anyone so that random UIDs can use it as HOME
# Clean up any root-owned cache from build steps
RUN rm -rf /root/.cache /home/toolbox/.cache /home/toolbox/.azure && \
    mkdir -p /home/toolbox/.cache /home/toolbox/.azure && \
    chown -R toolbox:toolbox /home/toolbox /toolbox && \
    chmod -R 777 /home/toolbox /toolbox && \
    chmod +x /usr/local/bin/kube-config-fix.sh && \
    echo "toolbox ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/toolbox


USER toolbox
ENV USER=toolbox
ENV SHELL=/bin/zsh
ENV HOME=/home/toolbox
WORKDIR /toolbox

CMD ["sleep", "infinity"]
