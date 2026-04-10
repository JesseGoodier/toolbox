FROM clickhouse/clickhouse-server:latest AS clickhouse

# ---- clickhouse-backup stage: use the official Altinity image ----
FROM altinity/clickhouse-backup:latest AS clickhouse_backup
FROM golang:alpine AS builder

RUN apk add --no-cache curl

ARG TARGETPLATFORM

RUN mkdir -p /out/usr/local/bin

RUN go install github.com/mikefarah/yq/v4@latest && \
    mv /go/bin/yq /out/usr/local/bin/yq

RUN case "${TARGETPLATFORM}" in \
    linux/amd64) KUBECTL_ARCH="amd64" ;; \
    linux/arm64) KUBECTL_ARCH="arm64" ;; \
    *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    KUBECTL_VERSION="$(curl -L -s --retry 3 --retry-delay 2 https://dl.k8s.io/release/stable.txt)" && \
    if [ -z "${KUBECTL_VERSION}" ]; then echo "Failed to get kubectl version" && exit 1; fi && \
    curl -LO --retry 3 --retry-delay 2 "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /out/usr/local/bin/

FROM python:3.14-slim-bookworm
LABEL org.opencontainers.image.source=https://github.com/jessegoodier/toolbox

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    bash bash-completion zsh zsh-syntax-highlighting zsh-autosuggestions \
    curl wget jq \
    ripgrep rclone tree less file silversearcher-ag \
    dnsutils netcat-openbsd tcpdump openssl mtr-tiny iputils-ping \
    htop strace procps lsof \
    vim neovim git \
    ca-certificates \
    fd-find fzf \
    sudo passwd && \
    rm -rf /var/lib/apt/lists/* && \
    python -m pip install --no-cache-dir --upgrade pip uv

COPY --from=builder /out/ /

RUN mkdir -p /toolbox \
    /usr/share/bash-completion/completions \
    /usr/share/zsh/site-functions

RUN kubectl completion bash > /usr/share/bash-completion/completions/kubectl && \
    yq shell-completion bash > /usr/share/bash-completion/completions/yq && \
    rclone completion bash > /usr/share/bash-completion/completions/rclone && \
    kubectl completion zsh > /usr/share/zsh/site-functions/_kubectl && \
    yq shell-completion zsh > /usr/share/zsh/site-functions/_yq && \
    rclone completion zsh > /usr/share/zsh/site-functions/_rclone && \
    ln -sf /usr/bin/fdfind /usr/local/bin/fd

RUN useradd -m -U -u 1001 -s /bin/zsh toolbox && \
    mkdir -p /etc/sudoers.d && \
    echo "toolbox ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/toolbox && \
    chmod 0440 /etc/sudoers.d/toolbox

COPY --from=common-files .zshrc .bashrc .vimrc shell-common aliases-git.sh aliases-kubectl.sh /home/toolbox/
COPY --from=common-files .zshrc .bashrc .vimrc shell-common aliases-git.sh aliases-kubectl.sh /root/

RUN mkdir -p /home/toolbox/.config/rclone /root/.config/rclone
COPY --from=common-files rclone.conf /home/toolbox/.config/rclone/rclone.conf
COPY --from=common-files rclone.conf /root/.config/rclone/rclone.conf
COPY --from=common-files kube-config-fix.sh /usr/local/bin/kube-config-fix.sh

RUN rm -rf /root/.cache /home/toolbox/.cache /home/toolbox/.aws && \
    mkdir -p /home/toolbox/.cache /home/toolbox/.aws && \
    chown -R toolbox:toolbox /home/toolbox /toolbox && \
    chmod -R 777 /home/toolbox /toolbox && \
    chmod +x /usr/local/bin/kube-config-fix.sh

COPY --from=clickhouse /usr/bin/clickhouse /usr/local/bin/clickhouse
COPY --from=clickhouse_backup /bin/clickhouse-backup /usr/local/bin/clickhouse-backup
RUN ln -sf /usr/local/bin/clickhouse /usr/local/bin/clickhouse-client && \
    ln -sf /usr/local/bin/clickhouse /usr/local/bin/clickhouse-local

USER toolbox
ENV USER=toolbox
ENV SHELL=/bin/zsh
ENV HOME=/home/toolbox
WORKDIR /toolbox

CMD ["sleep", "infinity"]
