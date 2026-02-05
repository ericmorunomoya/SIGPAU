#!/bin/bash

TOKEN="8509333409:AAGQEv_Q2P7L2H_BJw5iFDYxOYkll9iiX1A"
CHAT_ID="$1"
SUBJECT="$2"
MESSAGE="$3"

URL="https://api.telegram.org/bot$TOKEN/sendMessage"

curl -s -X POST "$URL" \
  --data-urlencode "chat_id=$CHAT_ID" \
  --data-urlencode "text=$SUBJECT
$MESSAGE"
