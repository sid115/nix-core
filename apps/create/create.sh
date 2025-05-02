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
    hyprland
    server
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

# Find and apply diff files
apply_diffs() {
    find "$FLAKE" -type f -name '*.diff' | while read -r diff_file; do
        original_file="${diff_file%.diff}"
        dirpath=$(dirname "$diff_file")
        echo "Applying patch $diff_file to $original_file"
        patch --directory "$dirpath" --input "$diff_file" "$(basename "$original_file")"
        rm "$diff_file"
    done
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

# Check if the flake exists
if [[ ! -d $FLAKE ]]; then
    echo "Flake directory does not exist: $FLAKE"
    exit 1
fi

# Assign default values for optional arguments
GIT_NAME=${GIT_NAME:-$USERNAME}
GIT_EMAIL=${GIT_EMAIL:-"$USERNAME@$HOSTNAME"}

# Copy template to flake directory and fix permissions
cp -n -r "$TEMPLATES_DIR"/"$TEMPLATE"/* "$FLAKE" || exit 1
find "$FLAKE" -print0 | while IFS= read -r -d $'\0' file; do
    chmod u+w "$file"
done

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

# Apply diff files
apply_diffs

echo "Template $TEMPLATE successfully applied to $FLAKE."
