# Toolbox

A debug container for Kubernetes. Because `kubectl exec` into an alpine container with nothing but `sh` is not fun.

This project was created out of a need for a user-like zsh/bash shell for testing <https://github.com/jessegoodier/kpf> completions.

## Quick Start

The best way to use this is with the main **combined** image, which includes tools for all three major clouds:

```bash
kubectl run debug --rm -it --image=ghcr.io/jessegoodier/toolbox -- zsh
```

## What's Inside

**Main image** (`toolbox`):
- All common tools (see below)
- AWS CLI
- Google Cloud SDK (`gcloud`, `gsutil`)
- Azure CLI (`az`)

**Common base image** (`toolbox-common`):
- `openssl`, `kubectl`, `curl`, `wget`, `jq`, `yq`
- `dig`, `nslookup`, `doggo`, `mtr`, `ping`, `netcat`, `tcpdump`
- `htop`, `strace`, `lsof`, `ps`
- `ripgrep`, `rclone`, `tree`, `less`, `file`
- `fzf`, `fd`, `eza`
- `neovim`, `git`
- `bash` + `zsh` with completions, syntax highlighting, autosuggestions
- Python 3.14 + `uv`

**Cloud-specific images** (lighter alternatives):
- `toolbox-aws` - AWS CLI only
- `toolbox-aws-debian` - AWS CLI only on Debian
- `toolbox-gcp` - Google Cloud SDK only
- `toolbox-azure` - Azure CLI only

**Debian alternatives**:
- `toolbox-common-debian` - Common tools on a Debian base
- `toolbox-aws-debian` - Debian base + AWS CLI

All images are multi-arch (`amd64`/`arm64`) and rebuilt daily.

## Usage

```bash
# All-in-one (Recommended)
kubectl run debug --rm -it --image=ghcr.io/jessegoodier/toolbox -- zsh

# Specific cloud provider
kubectl run debug --rm -it --image=ghcr.io/jessegoodier/toolbox-aws -- zsh

# Minimal (Common tools only)
kubectl run debug --rm -it --image=ghcr.io/jessegoodier/toolbox-common -- zsh

# Debian-based AWS image
kubectl run debug --rm -it --image=ghcr.io/jessegoodier/toolbox-aws-debian -- zsh
```

## Images

| Image | Description |
|-------|-------------|
| `ghcr.io/jessegoodier/toolbox` | **(Recommended)** Combined tools for AWS, GCP, and Azure |
| `ghcr.io/jessegoodier/toolbox-common` | Base image with common tools |
| `ghcr.io/jessegoodier/toolbox-common-debian` | Debian base image with common tools |
| `ghcr.io/jessegoodier/toolbox-aws` | + AWS CLI |
| `ghcr.io/jessegoodier/toolbox-aws-debian` | Debian base image + AWS CLI |
| `ghcr.io/jessegoodier/toolbox-gcp` | + gcloud |
| `ghcr.io/jessegoodier/toolbox-azure` | + az CLI |

## Building Locally

```bash
# Dry run (no push)
./build_images.sh

# Push to registry
PUSH=true ./build_images.sh
```

## License

Do whatever you want with it. If it breaks your cluster, you get to keep both pieces.
