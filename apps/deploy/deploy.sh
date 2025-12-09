#!/usr/bin/env bash

# defaults
FLAKE_URI="."
CONFIG_FILE="./deploy.json"
ACTION="switch"
USE_SUDO=true
DO_BUILD=true

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [ACTION]

Arguments:
  ACTION                 switch | boot | test (Default: switch)

Options:
  -f, --flake URI        URI of the flake (Default: $FLAKE_URI)
  -c, --config FILE      Deployment config file (Default: $CONFIG_FILE)
  --no-sudo              Do not pass sudo-related flags to nixos-rebuild.
  --skip-build           Skip the explicit 'build' step before deployment.
  -h, --help             Show this help.
EOF
}

_status() { echo -e "\033[0;34m> $1\033[0m"; }
success() { echo -e "\033[0;32m$1\033[0m"; }
error()   { echo -e "\033[0;31mError: $1\033[0m" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    switch|boot|test)  ACTION="$1"; shift ;;
    -f|--flake)        FLAKE_URI="$2"; shift 2 ;;
    -c|--config)       CONFIG_FILE="$2"; shift 2 ;;
    --no-sudo)         USE_SUDO=false; shift ;;
    --skip-build)      DO_BUILD=false; shift ;;
    -h|--help)         usage; exit 0 ;;
    *)                 error "Invalid argument '$1'" ;;
  esac
done

command -v jq &> /dev/null || error "jq is not installed."
[ -f "$CONFIG_FILE" ] || error "Config '$CONFIG_FILE' not found."

BUILD_HOST=$(jq -r '.buildHost // "localhost"' "$CONFIG_FILE")
[[ "$BUILD_HOST" =~ ^(127\.0\.0\.1|::1)$ ]] && BUILD_HOST="localhost"

mapfile -t HOSTS < <(jq -r '.hosts[]' "$CONFIG_FILE")
[ ${#HOSTS[@]} -eq 0 ] && error "No hosts defined in $CONFIG_FILE"

echo "Action:      $ACTION"
echo "Flake:       $FLAKE_URI"
echo "Builder:     $BUILD_HOST"
echo "Targets:     ${HOSTS[*]}"

if [ "$DO_BUILD" = true ]; then
  _status "Building configurations..."
  for host in "${HOSTS[@]}"; do
    echo "------------------------------------------------"
    echo "Building host '$host':"
    
    CMD=("nixos-rebuild" "build" "--flake" "${FLAKE_URI}#${host}")
    [[ "$BUILD_HOST" != "localhost" ]] && CMD+=("--build-host" "$BUILD_HOST")

    "${CMD[@]}" || error "Build failed for $host"
    success "Build for host '$host' successful."
  done
fi

_status "Deploying to targets..."
for host in "${HOSTS[@]}"; do
  echo "------------------------------------------------"
  echo "Deploying to host '$host':"

  CMD=("nixos-rebuild" "$ACTION" "--flake" "${FLAKE_URI}#${host}" "--target-host" "$host")
  [[ "$BUILD_HOST" != "localhost" ]] && CMD+=("--build-host" "$BUILD_HOST")
  [[ "$USE_SUDO" = true ]] && CMD+=("--sudo" "--ask-sudo-password")

  "${CMD[@]}" || error "Activation failed for $host"
  success "Host '$host' updated."
done

success "Deployment complete."
