TIMER_FILE="/tmp/timer" # file to store the current time
SIGNAL=11 # signal number to send to status bar
STATUS_BAR="waybar" # Support for more status bars?

help() {
  echo "Usage: $0 {start -h H -m M -s S|stop|print}"
}

start_timer() {
  local hours=$1
  local minutes=$2
  local seconds=$3
  local total_seconds=$((hours * 3600 + minutes * 60 + seconds))

  ( 
    notify-send "Timer Started" "Your countdown timer has been started."

    trap "exit" INT TERM
    trap "rm -f -- '$TIMER_FILE'" EXIT

    while [ $total_seconds -gt 0 ]; do
      hours=$(( total_seconds / 3600 ))
      minutes=$(( (total_seconds % 3600) / 60 ))
      seconds=$(( total_seconds % 60 ))

      printf "%02d:%02d:%02d\n" $hours $minutes $seconds > $TIMER_FILE
      pkill -RTMIN+$SIGNAL $STATUS_BAR
      sleep 1
      total_seconds=$(( total_seconds - 1 ))
    done
    
    notify-send "Timer Finished" "Your countdown timer has ended."
    stop_timer
  ) &
}

stop_timer() {
  rm -f $TIMER_FILE
  pkill -RTMIN+$SIGNAL $STATUS_BAR
  exit 0
}

print_time() {
  if [[ -f $TIMER_FILE ]]; then
    printf " %s" "$(cat $TIMER_FILE)"
  else
    echo "" # waybar widget will be hidden if stdout is empty
  fi
}

if [ "$1" = "start" ]; then
  shift
  while getopts "h:m:s:" opt; do
    case $opt in
      h) HOURS=$OPTARG ;;
      m) MINUTES=$OPTARG ;;
      s) SECONDS=$OPTARG ;;
      *) echo "Invalid option"; exit 1 ;;
    esac
  done
  HOURS=${HOURS:-0}
  MINUTES=${MINUTES:-0}
  SECONDS=${SECONDS:-0}

  start_timer $HOURS $MINUTES $SECONDS

elif [ "$1" = "stop" ]; then
  notify-send "Timer Stopped" "Your countdown timer has been stopped."
  stop_timer

elif [ "$1" = "print" ]; then
  print_time

else
  echo "Invalid command $1"
  help
  exit 1
fi
