#!/usr/bin/env bash
set -euo pipefail

# Builds a local Docker image with pebble-tool and runs `pebble build` inside it
# Usage: ./scripts/docker-build-run.sh

IMAGE=pebble-tool:local

echo "Building Docker image $IMAGE (this may take a few minutes)..."
docker build -t "$IMAGE" .

echo "Running pebble build inside container (mounted to current directory)..."
docker run --rm -v "$(pwd)":/src -w /src "$IMAGE" /bin/bash -lc ". /opt/venv/bin/activate && pebble build"

echo "Done."
