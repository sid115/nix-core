SYSTEM="x86_64-linux"
IGNORE_PACKAGES=(
  "pyman"
  "synapse_change_display_name"
)

error() {
  echo "Error: $1" >&2
  exit 1
}

if [[ "$#" -gt 0 ]]; then
  error "This script does not accept arguments."
fi

TEMP_PACKAGE_LIST="/tmp/nix_flake_packages.$$"

nix eval .#packages."$SYSTEM" --apply 'pkgs: builtins.attrNames pkgs' --json > "$TEMP_PACKAGE_LIST" 2>/dev/null || \
error "Could not determine flake package attributes."

PACKAGES=$(jq -r '.[]' "$TEMP_PACKAGE_LIST")

if [ -z "$PACKAGES" ]; then
  echo "No packages found in the flake outputs. Exiting."
  rm -f "$TEMP_PACKAGE_LIST"
  exit 0
fi

IGNORE_PATTERNS=$(printf "%s\n" "${IGNORE_PACKAGES[@]}")
PACKAGES=$(echo "$PACKAGES" | grep -v -F -f <(echo "$IGNORE_PATTERNS"))

echo "Found the following packages to consider for update:"
echo "$PACKAGES"

UPDATED_COUNT=0
FAILED_UPDATES=()
for PACKAGE_NAME in $PACKAGES; do
  echo "Attempting to update package: $PACKAGE_NAME"
  
  if nix-update "$PACKAGE_NAME" --flake --format; then
    echo "Successfully updated $PACKAGE_NAME."
    UPDATED_COUNT=$((UPDATED_COUNT + 1))
  else
    echo "Failed to update $PACKAGE_NAME." >&2
    FAILED_UPDATES+=("$PACKAGE_NAME")
  fi
done

if [ -f "$TEMP_PACKAGE_LIST" ]; then
  rm "$TEMP_PACKAGE_LIST"
fi

echo
echo "Summary:"
echo "Packages scanned: $(echo "$PACKAGES" | wc -l)"
echo "Packages updated: $UPDATED_COUNT"

if [ ${#FAILED_UPDATES[@]} -gt 0 ]; then
  echo "Packages that failed to update:" >&2
  echo "${FAILED_UPDATES[@]}"
  exit 1
else
  echo "All packages processed successfully."
  exit 0
fi
