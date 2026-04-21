# ---- ClickHouse stage: use the packaged binary from the official image ----
FROM clickhouse/clickhouse-server:latest AS clickhouse

# ---- clickhouse-backup stage: build from a pinned upstream commit ----
FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS clickhouse_backup_builder

ARG TARGETARCH
ARG CLICKHOUSE_BACKUP_REF=c1faeb9762c4e99f72015e293c29f844f28bd084

RUN apk add --no-cache ca-certificates curl tar

WORKDIR /src/clickhouse-backup

RUN curl -fsSL "https://codeload.github.com/Altinity/clickhouse-backup/tar.gz/${CLICKHOUSE_BACKUP_REF}" | \
    tar -xz --strip-components=1

RUN --mount=type=cache,target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,target=/root/.cache/go-build,sharing=locked \
    case "${TARGETARCH}" in \
    amd64|arm64) ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    CGO_ENABLED=0 GOOS=linux GOARCH="${TARGETARCH}" \
    go build -trimpath -buildvcs=false -tags netgo,osusergo \
    -ldflags "-X 'main.version=${CLICKHOUSE_BACKUP_REF}' -X 'main.gitCommit=${CLICKHOUSE_BACKUP_REF}' -X 'main.buildDate=unknown' -X 'main.buildArch=linux/${TARGETARCH}'" \
    -o /out/clickhouse-backup ./cmd/clickhouse-backup

# ---- Runtime stage: homebrew toolbox ----
FROM docker.io/homebrew/brew:latest
LABEL org.opencontainers.image.source=https://github.com/jessegoodier/toolbox

# Phase 1: System packages via apt-get (as root)
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh bash-completion \
    dnsutils netcat-openbsd tcpdump openssl iputils-ping \
    strace procps lsof \
    systemd systemd-sysv dbus cron \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Strip unnecessary systemd units that fail/hang in containers
RUN (cd /lib/systemd/system/sysinit.target.wants/ && ls | grep -v systemd-tmpfiles-setup | xargs rm -f) && \
    rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/*

# Install ClickHouse from the official Docker image rather than the
# self-extracting standalone binary, which unpacks into /tmp at runtime.
COPY --from=clickhouse /usr/bin/clickhouse /usr/local/bin/clickhouse
COPY --from=clickhouse_backup_builder /out/clickhouse-backup /usr/local/bin/clickhouse-backup
RUN ln -sf /usr/local/bin/clickhouse /usr/local/bin/clickhouse-client && \
    ln -sf /usr/local/bin/clickhouse /usr/local/bin/clickhouse-local

# Phase 2: Brew packages (as linuxbrew)
# Split into multiple layers so arm64 QEMU builds can cache progress
USER linuxbrew
RUN brew install python && brew cleanup --prune=all
RUN brew install node && brew cleanup --prune=all
RUN brew install neovim && brew cleanup --prune=all
RUN brew install \
    curl doggo eza fd fzf htop kubectl mtr \
    rclone ripgrep the_silver_searcher tree tmux uv vim wget \
    yq zsh-autosuggestions zsh-syntax-highlighting \
    && brew cleanup --prune=all

# Phase 3: Completions
RUN mkdir -p "$(brew --prefix)/share/bash-completion/completions" \
    "$(brew --prefix)/share/zsh/site-functions" && \
    kubectl completion bash > "$(brew --prefix)/share/bash-completion/completions/kubectl" && \
    yq shell-completion bash > "$(brew --prefix)/share/bash-completion/completions/yq" && \
    rclone completion bash "$(brew --prefix)/share/bash-completion/completions/rclone" && \
    (doggo completion bash > "$(brew --prefix)/share/bash-completion/completions/doggo" || true) && \
    kubectl completion zsh > "$(brew --prefix)/share/zsh/site-functions/_kubectl" && \
    yq shell-completion zsh > "$(brew --prefix)/share/zsh/site-functions/_yq" && \
    rclone completion zsh "$(brew --prefix)/share/zsh/site-functions/_rclone" && \
    (doggo completion zsh > "$(brew --prefix)/share/zsh/site-functions/_doggo" || true)

# Phase 4: Create toolbox user, copy configs (as root)
USER root
RUN useradd -m -U -u 1001 -G linuxbrew -s /bin/zsh toolbox && \
    echo "toolbox ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/toolbox

RUN mkdir -p /toolbox

COPY .zshrc .bashrc .vimrc shell-common aliases-git.sh aliases-kubectl.sh /home/toolbox/
COPY .zshrc .bashrc .vimrc shell-common aliases-git.sh aliases-kubectl.sh /root/
RUN mkdir -p /home/toolbox/.config/rclone /root/.config/rclone
COPY rclone.conf /home/toolbox/.config/rclone/rclone.conf
COPY rclone.conf /root/.config/rclone/rclone.conf
COPY kube-config-fix.sh /usr/local/bin/kube-config-fix.sh

# Phase 5: Permissions (OpenShift/K8s random UID support)
# Make homebrew prefix group-writable and cache toolbox-owned so toolbox user can brew install at runtime
RUN chmod -R g+w /home/linuxbrew/.linuxbrew && \
    chown -R toolbox:linuxbrew /home/linuxbrew/.cache/Homebrew && \
    git config --system --add safe.directory /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core && \
    rm -rf /root/.cache /home/toolbox/.cache /home/toolbox/.azure && \
    mkdir -p /home/toolbox/.cache /home/toolbox/.azure && \
    chown -R toolbox:toolbox /home/toolbox /toolbox && \
    chmod -R 777 /home/toolbox /toolbox && \
    chmod +x /usr/local/bin/kube-config-fix.sh

USER toolbox
ENV USER=toolbox
ENV SHELL=/bin/zsh
ENV HOME=/home/toolbox
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
WORKDIR /toolbox

CMD ["sleep", "infinity"]
