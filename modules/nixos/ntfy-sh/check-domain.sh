#!/usr/bin/env bash

# Check if a domain is up. If not, send a notification via ntfy.

if [ $# -ne 2 ]; then
  echo "Usage: $0 <fqdn> <ntfy_topic>"
  exit 1
fi

FQDN="$1"
NTFY_TOPIC="$2"
FAIL_MESSAGE="$FQDN is down."
FAIL_COUNT=0
SLEEP_SEC=5
MAX_ATTEMPTS=3

# check if website is up
check_website() {
  local http_code
  http_code=$(curl -s -w "%{http_code}" -o /dev/null -I "https://$FQDN" 2>/dev/null)

  [ -n "$http_code" ] || return 1
  [ "$http_code" == "000" ] && return 1
  [[ $http_code =~ ^[45] ]] && return 1

  [[ $http_code =~ ^[23] ]] && return 0

  return 1
}

# send notification via ntfy
send_notification() {
  if curl -s -d "$1" http://127.0.0.1:2586/"$NTFY_TOPIC"; then
    return 0
  else
    return 1
  fi
}

# perform checks
ATTEMPTS=1
while [ $ATTEMPTS -le $MAX_ATTEMPTS ]; do
  if check_website; then
    FAIL_COUNT=0
    break
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    if [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; then
      sleep $SLEEP_SEC
    fi
  fi
  ATTEMPTS=$((ATTEMPTS + 1))
done

# send notification if all checks failed
if [ $FAIL_COUNT -eq $MAX_ATTEMPTS ]; then
  send_notification "$FAIL_MESSAGE" || exit 1
fi

exit 0
