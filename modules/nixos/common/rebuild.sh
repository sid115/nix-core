# NixOS and standalone Home Manager rebuild script

# Defaults
FLAKE_PATH="$HOME/.config/nixos" # Default flake path
HOME_USER="$(whoami)"            # Default user for Home Manager
NIXOS_HOST="$(hostname)"         # Default host for NixOS
UPDATE=0                         # Default to not update flake repositories
ROLLBACK=0                       # Default to not rollback
SHOW_TRACE=0                     # Default to not show detailed error messages

# Function to display the help message
Help() {
  echo "Usage: rebuild <command> [OPTIONS]"
  echo
  echo "Commands:"
  echo "  nixos                Rebuild NixOS configuration"
  echo "  home                 Rebuild Home Manager configuration"
  echo "  all                  Rebuild both NixOS and Home Manager configurations"
  echo
  echo "Options:"
  echo "  -H, --host <host>    Specify the host (for NixOS and Home Manager). Default: $NIXOS_HOST"
  echo "  -u, --user <user>    Specify the user (for Home Manager only). Default: $HOME_USER"
  echo "  -p, --path <path>    Set the path to the flake directory. Default: $FLAKE_PATH"
  echo "  -U, --update         Update flake inputs"
  echo "  -r, --rollback       Don't build the new configuration, but use the previous generation instead"
  echo "  -t, --show-trace     Show detailed error messages"
  echo "  -h, --help           Show this help message"
}

# Function to rebuild NixOS configuration
Rebuild_nixos() {
  local FLAKE="$FLAKE_PATH#$NIXOS_HOST"

  # Construct rebuild command
  CMD="sudo nixos-rebuild switch --flake $FLAKE"
  [ "$ROLLBACK" = 1 ] && CMD="$CMD --rollback"
  [ "$SHOW_TRACE" = 1 ] && CMD="$CMD --show-trace"

  # Rebuild NixOS configuration
  if [ "$ROLLBACK" = 0 ]; then 
    echo "Rebuilding NixOS configuration '$FLAKE'..." 
  else
    echo "Rolling back to last NixOS generation..."
  fi

  $CMD || { echo "NixOS rebuild failed"; exit 1; }
  echo "NixOS rebuild completed successfully."
}

# Function to rebuild Home Manager configuration
Rebuild_home() {
  local FLAKE="$FLAKE_PATH#$HOME_USER@$NIXOS_HOST"

  if [ "$ROLLBACK" = 1 ]; then
    # Construct rebuild command
    CMD=$(home-manager generations | sed -n '2p' | grep -o '/nix/store[^ ]*')
    CMD="$CMD/activate"
  else
    # Construct rebuild command
    CMD="home-manager switch --flake $FLAKE"
    [ "$SHOW_TRACE" = 1 ] && CMD="$CMD --show-trace"
  fi

  # Rebuild Home Manager configuration
  if [ "$ROLLBACK" = 0 ]; then 
    echo "Rebuilding Home Manager configuration '$FLAKE'..." 
  else
    echo "Rolling back to last Home Manager generation..."
  fi
  $CMD || { echo "Home Manager rebuild failed"; exit 1; }
  echo "Home Manager rebuild completed successfully."
}

# Function to Update flake repositories
Update() {
  echo "Updating flake repositories..."
  nix flake update --flake "$FLAKE_PATH" || { echo "Failed to update flake repositories"; exit 1; }
  echo "Flake repositories updated successfully."
}

# Parse command-line options
COMMAND=$1
shift

while [ $# -gt 0 ]; do
  case "$1" in
    -H|--host)
      if [ -n "$2" ]; then
        NIXOS_HOST="$2"
        shift 2
      else
        echo "Error: -H|--host option requires an argument"
        exit 1
      fi
      ;;
    -u|--user)
      if [ -n "$2" ]; then
        HOME_USER="$2"
        shift 2
      else
        echo "Error: -u|--user option requires an argument"
        exit 1
      fi
      ;;
    -p|--path)
      if [ -n "$2" ]; then
        FLAKE_PATH="$2"
        shift 2
      else
        echo "Error: -p|--path option requires an argument"
        exit 1
      fi
      ;;
    -U|--update)
      UPDATE=1
      shift
      ;;
    -r|--rollback)
      ROLLBACK=1
      shift
      ;;
    -t|--show-trace)
      SHOW_TRACE=1
      shift
      ;;
    -h|--help)
      Help
      exit 0
      ;;
    *)
      echo "Error: Unknown option '$1'"
      Help
      exit 1
      ;;
  esac
done

# Check if script is run with sudo
if [ "$EUID" -eq 0 ]; then
  echo "Error: Do not run this script with sudo."
  exit 1
fi

# Check if flake path exists
if [ ! -d "$FLAKE_PATH" ]; then
  echo "Error: Flake path '$FLAKE_PATH' does not exist"
  exit 1
fi

# Ignore trailing slash in flake path
FLAKE_PATH="${FLAKE_PATH%/}"

# Check if flake.nix exists
if [ ! -f "$FLAKE_PATH/flake.nix" ]; then
  echo "Error: flake.nix does not exist in '$FLAKE_PATH'"
  exit 1
fi

# Execute updates and rebuilds based on the command
[ "$UPDATE" = 1 ] && Update

case "$COMMAND" in
  nixos)
    Rebuild_nixos
    ;;
  home)
    Rebuild_home
    ;;
  all)
    Rebuild_nixos
    Rebuild_home
    ;;
  *)
    echo "Error: Unknown command '$COMMAND'"
    Help
    exit 1
    ;;
esac
