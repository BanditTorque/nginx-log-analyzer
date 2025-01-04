#!/bin/bash

# Check if the log file is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <logfile>"
    exit 1
fi

LOGFILE=$1

# Check if the log file exists and is readable
if [ ! -f "$LOGFILE" ]; then
    echo "Error: Log file $LOGFILE not found."
    exit 1
fi

# Create temporary files for counts
IP_COUNT=$(mktemp)
PATH_COUNT=$(mktemp)
STATUS_COUNT=$(mktemp)
USER_AGENT_COUNT=$(mktemp)

# Count and sort IP addresses
awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -nr > "$IP_COUNT"

# Count and sort requested paths
awk 'BEGIN { FS="\"" } ; { split($2, a, " "); print a[2] }' "$LOGFILE" | sort | uniq -c | sort -nr > "$PATH_COUNT"

# Count and sort status codes
awk '{print $6}' "$LOGFILE" | sort | uniq -c | sort -nr > "$STATUS_COUNT"

# Count and sort user agents
awk 'BEGIN { FS="\"" } ; { print $5 }' "$LOGFILE" | sort | uniq -c | sort -nr > "$USER_AGENT_COUNT"

# Display top 5 IP addresses
echo "Top 5 IP addresses with the most requests:"
head -n 5 "$IP_COUNT" | awk '{print $2 " - " $1 " requests"}'
echo

# Display top 5 most requested paths
echo "Top 5 most requested paths:"
head -n 5 "$PATH_COUNT" | awk '{print $2 " - " $1 " requests"}'
echo

# Display top 5 response status codes
echo "Top 5 response status codes:"
head -n 5 "$STATUS_COUNT" | awk '{print $2 " - " $1 " occurrences"}'
echo

# Display top 5 user agents
echo "Top 5 user agents:"
head -n 5 "$USER_AGENT_COUNT" | awk '{print $2 " - " $1 " occurrences"}'
echo

# Clean up temporary files
rm "$IP_COUNT" "$PATH_COUNT" "$STATUS_COUNT" "$USER_AGENT_COUNT"
