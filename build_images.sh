#!/bin/bash
set -eo pipefail

# Get today's date
TODAY=$(date +%Y-%m-%d)
# Check if running in CI or local (default to local dry run unless specified)
PUSH=${PUSH:-false}

# Parse arguments
TEST_MODE=false
TARGET_IMAGE=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --test) TEST_MODE=true ;;
        --platform=*) PLATFORM="${1#*=}" ;;
        --platform) PLATFORM="$2"; shift ;;
        --metadata-file=*) METADATA_FILE="${1#*=}" ;;
        --metadata-file) METADATA_FILE="$2"; shift ;;
        --push)
            PUSH=true
            ;;
        *)
            # Positional argument: treat as bake target
            if [[ "$1" =~ ^(common|aws|gcp|azure|combined|homebrew|core|default)$ ]]; then
                TARGET_IMAGE="$1"
            else
                echo "Error: Unknown argument or invalid target '$1'. Valid targets: common, aws, gcp, azure, combined, homebrew, core, default."
                exit 1
            fi
            ;;
    esac
    shift
done

echo "Building images with tags: latest, $TODAY"
echo "Push enabled: $PUSH"
echo "Target: ${TARGET_IMAGE:-all (default group)}"
echo "Test mode: $TEST_MODE"
if [ -n "$PLATFORM" ]; then
    echo "Platform override: $PLATFORM"
fi
if [ -n "$METADATA_FILE" ]; then
    echo "Metadata file: $METADATA_FILE"
fi

# Create a buildx builder if one doesn't exist (needed for multi-arch)
# In CI, we expect the environment to be set up by actions, so we skip this.
if [ -z "$CI" ]; then
  if ! docker buildx inspect toolbox-builder > /dev/null 2>&1; then
    echo "Creating new buildx builder 'toolbox-builder'..."
    # Use docker-container driver to support multi-arch
    docker buildx create --name toolbox-builder --use --driver docker-container
    docker buildx inspect --bootstrap
  else
    docker buildx use toolbox-builder
  fi
fi

if [ "$TEST_MODE" = "true" ]; then
    echo "Running in TEST mode..."
    
    # Detect local architecture for single-platform build
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) PLATFORM="linux/amd64" ;;
        aarch64|arm64) PLATFORM="linux/arm64" ;;
        *) echo "Could not detect platform for $ARCH, defaulting to linux/amd64"; PLATFORM="linux/amd64" ;;
    esac
    echo "Detected architecture: $ARCH, using platform: $PLATFORM"

    # Build 'common' only, single platform, load to docker
    DATE_TAG=$TODAY docker buildx bake common \
        --load \
        --set "*.platform=$PLATFORM" \
        --set "*.tags=${REGISTRY:-ghcr.io/jessegoodier}/toolbox-common:test"
        
    echo "Test build complete. Image loaded to local Docker daemon with tag: toolbox-common:test"
    echo "Run: docker run -it --rm ${REGISTRY:-ghcr.io/jessegoodier}/toolbox-common:test"
else
    # Build arguments
    ARGS=""
    if [ "$PUSH" = "true" ]; then
        ARGS="--push"
    fi
    
    # Platform override
    if [ -n "$PLATFORM" ]; then
        ARGS="$ARGS --set *.platform=$PLATFORM"
    fi

    # Metadata file argument
    if [ -n "$METADATA_FILE" ]; then
        ARGS="$ARGS --metadata-file $METADATA_FILE"
    fi

    # Run bake
    # Use DATE_TAG from env or default to today
    DATE_TAG=${DATE_TAG:-$TODAY} docker buildx bake $ARGS $TARGET_IMAGE

    echo "Build complete."
fi
