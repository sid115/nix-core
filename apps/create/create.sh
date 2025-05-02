# Default values
GIT_NAME=""
GIT_EMAIL=""
DIRECTORY=""
TEMPLATE=""
USERNAME=""
HOSTNAME=""

# Templates with Home Manager configurations
HM_CONFIGS=("hyprland")

# Print usage information
usage() {
    cat <<EOF
Usage: $0 -u|--user USERNAME -H|--host HOSTNAME -d|--directory PATH/TO/EMPTY/DIRECTORY -t|--template TEMPLATE [--git-name GIT_NAME] [--git-email GIT_EMAIL]

Options:
    -u, --user USERNAME        Specify the username (mandatory)
    -H, --host HOSTNAME        Specify the hostname (mandatory)
    -d, --directory DIRECTORY  Path to an empty directory (mandatory)
    -t, --template TEMPLATE    Template to use for nix flake init (mandatory)
    --git-name GIT_NAME        Specify the git name (optional, default: USERNAME)
    --git-email GIT_EMAIL      Specify the git email (optional, default: USERNAME@HOSTNAME)
    -h, --help                 Show this help message
EOF
}

# Replace placeholder strings in files
recursive_replace() {
    local search=$1
    local replace=$2
    local dir=$3

    # Recursively replace in all files in the directory
    find "$dir" -type f -exec sed -i "s/$search/$replace/g" {} +
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
        -d|--directory)
            DIRECTORY=$2
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
if [[ -z $USERNAME ]] || [[ -z $HOSTNAME ]] || [[ -z $DIRECTORY ]] || [[ -z $TEMPLATE ]]; then
    echo "Error: Missing mandatory arguments."
    usage
    exit 1
fi

# Assign default values for optional arguments
GIT_NAME=${GIT_NAME:-$USERNAME}
GIT_EMAIL=${GIT_EMAIL:-"$USERNAME@$HOSTNAME"}

# Check if the directory exists and is empty
if [[ ! -d $DIRECTORY ]]; then
    echo "Directory does not exist. Creating: $DIRECTORY"
    mkdir -p "$DIRECTORY"
elif [[ "$(ls -A "$DIRECTORY" 2>/dev/null)" ]]; then
    echo "Error: Directory is not empty."
    exit 1
fi

# Change to the directory
cd "$DIRECTORY" || exit 1

# Run nix flake init
nix flake init -t "github:sid115/nix-core#templates.$TEMPLATE"

# Move generated files
if [[ -d "hosts/HOSTNAME" ]]; then
    mv "hosts/HOSTNAME" "hosts/$HOSTNAME"
else
    echo "Error: Directory hosts/HOSTNAME not found."
    exit 1
fi

if [[ -d "users/USERNAME" ]]; then
    mv "users/USERNAME" "users/$USERNAME"
else
    echo "Error: Directory users/USERNAME not found."
    exit 1
fi

# Only check for HM config if the template has one
for hm_cfg in "${HM_CONFIGS[@]}"; do
  if [[ "$TEMPLATE" = "$hm_cfg" ]]; then
    if [[ -d "users/$USERNAME/home/hosts/HOSTNAME" ]]; then
        mv "users/$USERNAME/home/hosts/HOSTNAME" "users/$USERNAME/home/hosts/$HOSTNAME"
    else
        echo "Error: Directory users/$USERNAME/home/hosts/HOSTNAME not found."
        exit 1
    fi
    break
  fi
done

# Replace placeholders recursively
recursive_replace "USERNAME" "$USERNAME" "."
recursive_replace "HOSTNAME" "$HOSTNAME" "."
recursive_replace "GIT_NAME" "$GIT_NAME" "."
recursive_replace "GIT_EMAIL" "$GIT_EMAIL" "."

echo "Setup completed successfully."
