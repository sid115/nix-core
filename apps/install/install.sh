# NixOS install script

### VARIABLES ###

ASK_VERIFICATION=1 # Default to ask for verification
CLONE_DIR="/tmp/nixos" # directory where NixOS configuration is cloned into
GIT_BRANCH="master" # Default Git branch
GIT_REPO="" # Git repository URL
HOSTNAME="" # Hostname
MNT="/mnt" # root mount point
SEPARATOR="________________________________________" # line separator

### FUNCTIONS ###

# Function to display help information
Show_help() {
  echo "Usage: $0 -r REPO -n HOSTNAME [-b BRANCH] [-y] [-h]"
  echo
  echo "Options:"
  echo "  -r, --repo REPO           Your NixOS configuration Git repository URL (mandatory)"
  echo "  -n, --hostname HOSTNAME   Specify the hostname for the NixOS configuration (mandatory)"
  echo "  -b, --branch BRANCH       Specify the Git branch to use (default: $GIT_BRANCH)"
  echo "  -y, --yes                 Do not ask for user verification before proceeding"
  echo "  -h, --help                Show this help message and exit"
}

# Function to format, partition, and mount disks for $HOSTNAME using disko
Run_disko() {
  echo "$SEPARATOR"
  echo "Running disko..."
  nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko "$CLONE_DIR"/hosts/"$HOSTNAME"/disks.nix
}

# Function to format, partition, and mount disks for $HOSTNAME using a partitioning script
Run_script() {
  echo "$SEPARATOR"
  echo "Running partitioning script..."
  bash "$CLONE_DIR"/hosts/"$HOSTNAME"/disks.sh
}

# Function to check mount points and partitioning
Check_partitioning() {
  echo "$SEPARATOR"
  echo "Printing mount points and partitioning..."
  mount | grep "$MNT"
  lsblk -f
  [[ "$ASK_VERIFICATION" == 1 ]] && read -rp "Verify the mount points and partitioning. Press Ctrl+c to cancel or Enter to continue..."
}

# Function to generate hardware configuration
Generate_hardware_config() {
  [[ "$ASK_VERIFICATION" == 1 ]] && read -rp "No hardware configuration found. Press Ctrl+c to cancel or Enter to generate one..."

  echo "$SEPARATOR"
  echo "Generating hardware configuration..."
  nixos-generate-config --root "$MNT" --show-hardware-config > "$CLONE_DIR"/hosts/"$HOSTNAME"/hardware.nix

  # Check if hardware configuration has been generated
  if [[ ! -f "$CLONE_DIR"/hosts/"$HOSTNAME"/hardware.nix ]]; then
    echo "Error: Hardware configuration cannot be generated."
    exit 1
  fi

  # Add configuration to git
  # TODO: get rid of cd
  cd "$CLONE_DIR"/hosts/"$HOSTNAME" || exit 1
  git add "$CLONE_DIR"/hosts/"$HOSTNAME"/hardware.nix
  cd || exit 1

  echo "Hardware configuration generated successfully."
};

# Function to install configuration for $HOSTNAME
Install() {
  # Check if hardware configuration exists
  [[ ! -f "$CLONE_DIR"/hosts/"$HOSTNAME"/hardware.nix ]] && Generate_hardware_config

  echo "$SEPARATOR"
  echo "Installing NixOS..."
  nixos-install --root "$MNT" --no-root-password --flake "$CLONE_DIR"#"$HOSTNAME" && echo "You can reboot the system now."
}

### PARSE ARGUMENTS ###

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -r|--repo) GIT_REPO="$2"; shift ;;
    -b|--branch) GIT_BRANCH="$2"; shift ;;
    -y|--yes) ASK_VERIFICATION=0 ;;
    -h|--help) Show_help; exit 0 ;;
    -n|--hostname) HOSTNAME="$2"; shift ;;
    *) echo "Unknown option: $1"; Show_help; exit 1 ;;
  esac
  shift
done

### PREREQUISITES ###

# Neither Git repository nor hostname can be empty
if [[ -z "$GIT_REPO" ]]; then
  echo "Error: Git repository URL cannot be empty."
  exit 1
fi
if [[ -z "$HOSTNAME" ]]; then
  echo "Error: Hostname cannot be empty."
  exit 1
fi

# Install git if not already installed
if ! command -v git &> /dev/null; then
  echo "Git is not installed. Installing..."
  nix-env -iA nixos.git
fi

# Clone NixOS configuration to $CLONE_DIR
mkdir -p "$CLONE_DIR"
echo "$SEPARATOR"
echo "Cloning NixOS configuration repo..."
git clone --depth 1 -b "$GIT_BRANCH" "$GIT_REPO" "$CLONE_DIR"

# Check if git repository has been cloned
if [[ ! -d "$CLONE_DIR"/.git ]]; then
  echo "Error: Git repository is not in $CLONE_DIR."
  exit 1
fi

### CHOOSE CONFIG ###

# If hostname is not provided via options, prompt the user
if [[ -z "$HOSTNAME" ]]; then
  # Get list of available hostnames
  HOSTNAMES=$(ls "$CLONE_DIR"/hosts)

  echo "$SEPARATOR"
  echo "Please choose a hostname to install its NixOS configuration."
  echo "$HOSTNAMES"
  read -rp "Enter hostname: " HOSTNAME

  # Check if hostname is empty
  if [[ -z "$HOSTNAME" ]]; then
    echo "Error: Hostname cannot be empty."
    exit 1
  fi
fi

### INSTALLATION ###

# Check if NixOS configuration exists
if [[ -d "$CLONE_DIR"/hosts/"$HOSTNAME" ]]; then

  # Check for existing disko configuration
  if [[ -f "$CLONE_DIR"/hosts/"$HOSTNAME"/disks.nix ]]; then
    Run_disko || ( echo "Error: disko failed." && exit 1 )
  # Check for partitioning script
  elif [[ -f "$CLONE_DIR"/hosts/"$HOSTNAME"/disks.sh ]]; then
    Run_script || ( echo "Error: Partitioning script failed." && exit 1 )
  else
    echo "Error: No disko configuration (disks.nix) or partitioning script (disks.sh) found for host '$HOSTNAME'."
    exit 1
  fi 

  Check_partitioning || ( echo "Error: Partitioning check failed." && exit 1 )
  Install || ( echo "Error: Installation failed." && exit 1 )
else
  echo "Error: Configuration for host '$HOSTNAME' does not exist."
  exit 1
fi
