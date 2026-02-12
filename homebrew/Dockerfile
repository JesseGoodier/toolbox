# ---- Runtime stage: homebrew toolbox ----
FROM docker.io/homebrew/brew:latest

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

# Phase 2: Brew packages (as linuxbrew)
# Split into multiple layers so arm64 QEMU builds can cache progress
USER linuxbrew
RUN brew install python && brew cleanup --prune=all
RUN brew install node && brew cleanup --prune=all
RUN brew install neovim && brew cleanup --prune=all
RUN brew install \
    curl doggo eza fd fzf htop kubectl mtr \
    rclone ripgrep the_silver_searcher tree uv vim wget \
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
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
