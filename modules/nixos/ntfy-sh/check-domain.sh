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
  curl -s -w "%{http_code} %{url_effective}\n" -I "$FQDN" > /dev/null && return 0 || return 1
}

# send notification via ntfy
send_notification() {
  ntfy "$NTFY_TOPIC" "$1" && return 0 || return 1
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
