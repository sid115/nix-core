#!/usr/bin/env bash

# Default values
GIT_NAME=""
GIT_EMAIL=""
FLAKE="$HOME/.config/nixos"
TEMPLATE=""
USERNAME=""
HOSTNAME=""

# Templates with Home Manager configurations
HM_CONFIGS=("hyprland")

# This will get overwritten by the derivation
TEMPLATES_DIR=""

# Print usage information
usage() {
    cat <<EOF
Usage: $0 -t|--template TEMPLATE -u|--user USERNAME -H|--host HOSTNAME [-f|--flake PATH/TO/YOUR/NIX-CONFIG] [--git-name GIT_NAME] [--git-email GIT_EMAIL]

Options:
    -t, --template TEMPLATE    Configuration template to use (mandatory)
    -u, --user USERNAME        Specify the username (mandatory)
    -H, --host HOSTNAME        Specify the hostname (mandatory)
    -f, --flake FLAKE          Path to your flake directory (optional, default: $FLAKE)
    --git-name GIT_NAME        Specify the git name (optional, default: USERNAME)
    --git-email GIT_EMAIL      Specify the git email (optional, default: USERNAME@HOSTNAME)
    -h, --help                 Show this help message

Available configuration templates:
    hetzner-amd
    hyprland
    pi4
    server
    vm-uefi
EOF
}

# Replace placeholder strings in files
recursive_replace() {
    local search=$1
    local replace=$2
    local dir=$3

    find "$dir" -type f -exec sed -i "s/$search/$replace/g" {} +
}

# mv wrapper
rename_files() {
    local from=$1
    local to=$2

    if [[ -d "$from" ]]; then
        mv "$from" "$to"
    else
        echo "Error: Directory $from not found."
        exit 1
    fi
}

# Returns true if template uses Home Manager 
has_hm() {
  local template="$1"

  for hm_config in "${HM_CONFIGS[@]}"; do
    if [[ "$template" == "$hm_config" ]]; then
      return 0
    fi
  done

  return 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--user)
            USERNAME=$2
            shift; shift ;;
        -H|--host)
            HOSTNAME=$2
            shift; shift ;;
        -f|--flake)
            FLAKE=$2
            shift; shift ;;
        -t|--template)
            TEMPLATE=$2
            shift; shift ;;
        --git-name)
            GIT_NAME=$2
            shift; shift ;;
        --git-email)
            GIT_EMAIL=$2
            shift; shift ;;
        -h|--help)
            usage
            exit 0 ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1 ;;
    esac
done

# Validate mandatory arguments
if [[ -z $USERNAME ]] || [[ -z $HOSTNAME ]] || [[ -z $TEMPLATE ]]; then
    echo "Error: Missing mandatory arguments."
    usage
    exit 1
fi

# Assign default values for optional arguments
GIT_NAME=${GIT_NAME:-$USERNAME}
GIT_EMAIL=${GIT_EMAIL:-"$USERNAME@$HOSTNAME"}

# Apply template to flake directory
mkdir -p "$FLAKE"
cd "$FLAKE" || { echo "Error: Cannot change directory to $FLAKE"; exit 1; }
nix flake init -t "github:sid115/nix-core#templates.$TEMPLATE"

# Move generated files
rename_files "$FLAKE/hosts/HOSTNAME" "$FLAKE/hosts/$HOSTNAME"
rename_files "$FLAKE/users/USERNAME" "$FLAKE/users/$USERNAME"

# Only check for HM config if the template has one
has_hm "$TEMPLATE" && rename_files "$FLAKE/users/$USERNAME/home/hosts/HOSTNAME" "$FLAKE/users/$USERNAME/home/hosts/$HOSTNAME"

# Replace placeholders recursively
recursive_replace "USERNAME" "$USERNAME" "$FLAKE"
recursive_replace "HOSTNAME" "$HOSTNAME" "$FLAKE"
recursive_replace "GIT_NAME" "$GIT_NAME" "$FLAKE"
recursive_replace "GIT_EMAIL" "$GIT_EMAIL" "$FLAKE"

echo "Template $TEMPLATE successfully applied to $FLAKE."
