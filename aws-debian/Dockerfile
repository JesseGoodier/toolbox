FROM toolbox-common-debian
USER root

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends awscli && \
    rm -rf /var/lib/apt/lists/* && \
    echo "complete -C '/usr/bin/aws_completer' aws" > /usr/share/bash-completion/completions/aws && \
    aws --version

RUN chown -R toolbox:toolbox /home/toolbox && \
    chmod -R 777 /home/toolbox

USER toolbox
