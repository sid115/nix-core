# NixOS and standalone Home Manager rebuild script

# Defaults
FLAKE_PATH="$HOME/.config/nixos" # Default flake path
HOME_USER="$(whoami)"            # Default username. Used to identify the Home Manager configuration
NIXOS_HOST="$(hostname)"         # Default hostname. Used to identify the NixOS and Home Manager configuration
BUILD_HOST=""                    # Default build host. Empty means localhost
TARGET_HOST=""                   # Default target host. Empty means localhost
UPDATE=0                         # Default to not update flake repositories
UPDATE_INPUTS=""                 # Default list of inputs to update. Empty means all
ROLLBACK=0                       # Default to not rollback
SHOW_TRACE=0                     # Default to not show detailed error messages

# Function to display the help message
Help() {
  echo "Wrapper script for 'nixos-rebuild switch' and 'home-manager switch' commands."
  echo "Usage: rebuild <command> [OPTIONS]"
  echo
  echo "Commands:"
  echo "  nixos                  Rebuild NixOS configuration"
  echo "  home                   Rebuild Home Manager configuration"
  echo "  all                    Rebuild both NixOS and Home Manager configurations"
  echo "  help                   Show this help message"
  echo
  echo "Options (for NixOS and Home Manager):"
  echo "  -H, --host <host>      Specify the hostname (as in 'nixosConfiguraions.<host>'). Default: $NIXOS_HOST"
  echo "  -p, --path <path>      Set the path to the flake directory. Default: $FLAKE_PATH"
  echo "  -U, --update [inputs]  Update all flake inputs. Optionally provide comma-separated list of inputs to update instead."

  echo "  -r, --rollback         Don't build the new configuration, but use the previous generation instead"
  echo "  -t, --show-trace       Show detailed error messages"
  echo
  echo "NixOS only options:"
  echo "  -B, --build-host <user@example.com>   Use a remote host for building the configuration via SSH"
  echo "  -T, --target-host <user@example.com>  Deploy the configuration to a remote host via SSH. If '--host' is specified, it will be used as the target host."
  echo
  echo "Home Manager only options:"
  echo "  -u, --user <user>      Specify the username (as in 'homeConfigurations.<user>@<host>'). Default: $HOME_USER"
}

# Function to handle errors
error() {
  echo "Error: $1"
  exit 1
}

# Function to rebuild NixOS configuration
Rebuild_nixos() {
  local FLAKE="$FLAKE_PATH#$NIXOS_HOST"

  # Construct rebuild command
  CMD="nixos-rebuild switch --sudo --flake $FLAKE"
  [ "$ROLLBACK" = 1 ] && CMD="$CMD --rollback"
  [ "$SHOW_TRACE" = 1 ] && CMD="$CMD --show-trace"
  [ -n "$BUILD_HOST" ] && CMD="$CMD --build-host $BUILD_HOST"
  if [ "$NIXOS_HOST" != "$(hostname)" ] && [ -z "$TARGET_HOST" ]; then
    TARGET_HOST="$NIXOS_HOST"
    echo "Using '$TARGET_HOST' as target host."
  fi
  [ -n "$TARGET_HOST" ] && CMD="$CMD --target-host $TARGET_HOST --ask-sudo-password"

  # Rebuild NixOS configuration
  if [ "$ROLLBACK" = 0 ]; then 
    echo "Rebuilding NixOS configuration '$FLAKE'..." 
  else
    echo "Rolling back to last NixOS generation..."
  fi

  echo "Executing command: $CMD"
  $CMD || error "NixOS rebuild failed"
  echo "NixOS rebuild completed successfully."
}

# Function to rebuild Home Manager configuration
Rebuild_home() {
  local FLAKE="$FLAKE_PATH#$HOME_USER@$NIXOS_HOST"

  if [ -n "$BUILD_HOST" ] || [ -n "$TARGET_HOST" ]; then
    error "Remote building is not supported for Home Manager."
  fi

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

  echo "Executing command: $CMD"
  $CMD || error "Home Manager rebuild failed"
  echo "Home Manager rebuild completed successfully."
}

# Function to Update flake repositories
Update() {
  echo "Updating flake inputs..."

  # Construct update command
  CMD="nix flake update --flake $FLAKE_PATH"
  if [ -n "$UPDATE_INPUTS" ]; then
    # Split comma-separated inputs and pass them to nix flake update
    IFS=',' read -ra INPUTS <<< "$UPDATE_INPUTS"
    for input in "${INPUTS[@]}"; do
      CMD="$CMD $input"
    done
  fi

  echo "Executing command: $CMD"
  $CMD || error "Failed to update flake repositories"
  echo "Flake repositories updated successfully."
}

# Parse command-line options
COMMAND=$1
shift

# Handle help command early
[ "$COMMAND" = "help" ] && { Help; exit 0; }

while [ $# -gt 0 ]; do
  case "$1" in
    -H|--host)
      if [ -n "$2" ]; then
        NIXOS_HOST="$2"
        shift 2
      else
        error "-H|--host option requires an argument"
      fi
      ;;
    -u|--user)
      if [ -n "$2" ]; then
        HOME_USER="$2"
        shift 2
      else
        error "-u|--user option requires an argument"
      fi
      ;;
    -p|--path)
      if [ -n "$2" ]; then
        FLAKE_PATH="$2"
        shift 2
      else
        error "-p|--path option requires an argument"
      fi
      ;;
    -U|--update)
      UPDATE=1
      # Check if next argument is a non-option
      if [ $# -gt 1 ] && [ "${2#-}" = "$2" ]; then
        UPDATE_INPUTS="$2"
        shift 2
      else
        shift
      fi
      ;;
    -r|--rollback)
      ROLLBACK=1
      shift
      ;;
    -t|--show-trace)
      SHOW_TRACE=1
      shift
      ;;
    -B|--build-host)
      if [ -n "$2" ]; then
        BUILD_HOST="$2"
        shift 2
      else
        error "-B|--build-host option requires an argument"
      fi
      ;;
    -T|--target-host)
      if [ -n "$2" ]; then
        TARGET_HOST="$2"
        shift 2
      else
        error "-T|--target-host option requires an argument"
      fi
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
  error "Do not run this script with sudo."
fi

# Check if flake path exists
if [ ! -d "$FLAKE_PATH" ]; then
  error "Flake path '$FLAKE_PATH' does not exist"
fi

# Ignore trailing slash in flake path
FLAKE_PATH="${FLAKE_PATH%/}"

# Check if flake.nix exists
if [ ! -f "$FLAKE_PATH/flake.nix" ]; then
  error "flake.nix does not exist in '$FLAKE_PATH'"
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
    echo "Printing help page:"
    Help
    exit 1
    ;;
esac
