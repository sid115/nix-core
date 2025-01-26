{ config, pkgs, ... }:

let
  cfg = config.services.tt-rss;
  php = "${cfg.phpPackage}/bin/php";
in
(pkgs.writeShellScriptBin "tt-rss-users" ''
  # Path to the TT-RSS update.php script
  UPDATE_SCRIPT="${cfg.root}/www/update.php"

  # Function to display help message
  help() {
      echo "TT-RSS User Management Script"
      echo "Usage:"
      echo "  $0 add <username> <password> [access_level]"
      echo "      Adds a new user with the specified username, password,"
      echo "      and optional access level (default is 0)."
      echo
      echo "  $0 remove <username>"
      echo "      Removes the specified user."
      echo
      echo "Options:"
      echo "  <username>        The username of the user."
      echo "  <password>        The password for the user."
      echo "  [access_level]    Optional access level (default is 0)."
  }

  # Function to add a user
  add_user() {
      local username="$1"
      local password="$2"
      local access_level="$3"

      # Set default access level if not specified
      if [ -z "$access_level" ]; then
          access_level=0
      fi

      if [ -z "$username" ] || [ -z "$password" ]; then
          help && exit 1
      fi

      ${php} "$UPDATE_SCRIPT" --user-add="$username:$password:$access_level"
      if [ $? -eq 0 ]; then
          echo "User '$username' added successfully."
      else
          echo "Failed to add user '$username'."
      fi
  }

  # Function to remove a user
  remove_user() {
      local username="$1"

      if [ -z "$username" ]; then
          help && exit 1
      fi

      # Use --force-yes to assume 'yes' to all confirmation prompts
      ${php} "$UPDATE_SCRIPT" --user-remove="$username" --force-yes
      if [ $? -eq 0 ]; then
          echo "User '$username' removed successfully."
      else
          echo "Failed to remove user '$username'."
      fi
  }

  # Check script usage and print help if incorrect
  if [ "$#" -lt 2 ]; then
      echo "Not enough arguments."
      help && exit 1
  fi

  # Parse command and arguments
  case "$1" in
      add)
          add_user "$2" "$3" "$4"
          ;;
      remove)
          remove_user "$2"
          ;;
      *)
          help && exit 0
          ;;
  esac
'')
