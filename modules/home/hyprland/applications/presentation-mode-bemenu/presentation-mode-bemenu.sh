# Variables
DISPLAYS=( $(hyprctl monitors | grep -E '^Monitor' | awk '{print $2}') )
EXTEND_RIGHT="Extend to right of main"
EXTEND_LEFT="Extend to left of main"
MIRROR="Mirror main"
DISABLE="Disable main"

# Exit if only one display is available
[[ "${#DISPLAYS[@]}" -eq 1 ]] && echo "Only one display available." && exit 0

MAIN_DISPLAY=${DISPLAYS[0]}
SECOND_DISPLAY=${DISPLAYS[1]} # TODO: Add support for more than two displays

# Select action
ACTIONS="$EXTEND_RIGHT\n$EXTEND_LEFT\n$MIRROR\n$DISABLE"
ACTIONS_CHOICE=$(echo -e "$ACTIONS" | bemenu -p "Select action")

# Handle actions that do not need a mode
case "$ACTIONS_CHOICE" in
  "$MIRROR") hyprctl keyword monitor "$SECOND_DISPLAY", preferred, auto, 1, mirror, "$MAIN_DISPLAY" && exit 0;;
  "$DISABLE") hyprctl keyword monitor "$MAIN_DISPLAY", disable && exit 0;;
esac

# Select mode
MODES=$( hyprctl monitors | awk '/^Monitor/{flag=1; next} /^$/{flag=0} flag' | awk -F "availableModes: " '{print $2}' | sed 's/ /\\n/g' | awk NF )
MODES_CHOICE=$(echo -e "$MODES" | bemenu -p "Select mode")

# Handle actions that need a mode
case "$ACTIONS_CHOICE" in
  "$EXTEND_RIGHT") hyprctl keyword monitor "$SECOND_DISPLAY", "$MODES_CHOICE", auto-right, 1 ;;
  "$EXTEND_LEFT") hyprctl keyword monitor "$SECOND_DISPLAY", "$MODES_CHOICE", auto-left, 1 ;;
esac
