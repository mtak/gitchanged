#!/bin/bash

REPO_HASH=$(echo "${REPO_URL}${WATCH_FILE}" | md5sum | cut -d ' ' -f 1)
REPO_DIR="/app/data/repo_${REPO_HASH}"
DATA_DIR="/app/data"
TRACK_FILE="${DATA_DIR}/last_commit_${REPO_HASH}"

exec > $DATA_DIR/last_run_${REPO_HASH}.log 2>&1

echo "Run started at `date`"
cat <<EOF
REPO_URL=$REPO_URL
WATCH_FILE=$WATCH_FILE
REPO_HASH=$(echo "${REPO_URL}${WATCH_FILE}" | md5sum | cut -d ' ' -f 1)
REPO_DIR="/app/data/repo_${REPO_HASH}"
DATA_DIR="/app/data"
TRACK_FILE="${DATA_DIR}/.last_commit_${REPO_HASH}"
EOF

# Clone or update repo
if [ ! -d "$REPO_DIR/.git" ]; then
    git clone --quiet "$REPO_URL" "$REPO_DIR"
else
    git -C "$REPO_DIR" pull --quiet
fi

cd "$REPO_DIR" || exit 1

# Get latest commit hash for the watched file
LATEST_HASH=$(git log -n 1 --pretty=format:"%H" -- "$WATCH_FILE" 2>/dev/null)

if [ -z "$LATEST_HASH" ]; then
    echo "File not found in repo: $WATCH_FILE"
    exit 1
fi

# Load previous hash
if [ -f "$TRACK_FILE" ]; then
    PREV_HASH=$(cat "$TRACK_FILE")
else
    echo "No previous hash file found, exiting."
    echo "$LATEST_HASH" > "$TRACK_FILE"
    exit 1
fi

# Compare and notify
if [ "$LATEST_HASH" != "$PREV_HASH" ]; then
    COMMIT_MSG=$(git log -n 1 --pretty=format:"%s" -- "$WATCH_FILE")
    COMMIT_AUTHOR=$(git log -n 1 --pretty=format:"%an <%ae>" -- "$WATCH_FILE")
    COMMIT_DATE=$(git log -n 1 --pretty=format:"%ad" --date=short -- "$WATCH_FILE")

    echo "Found different hash, emailing..."

    echo "Subject: Change detected in $WATCH_FILE
To: $RECIPIENT
From: $SMTP_FROM

The file '$WATCH_FILE' in repo '$REPO_URL' has changed.

Last Commit:
$COMMIT_MSG
Author: $COMMIT_AUTHOR
Date: $COMMIT_DATE

Commit Hash: $LATEST_HASH

-- 
Sent by gitchanged" | msmtp \
        --host="$SMTP_SERVER" \
        --port="$SMTP_PORT" \
        --from="$SMTP_FROM" \
        --auth=on --tls=on --tls-starttls=on \
        --user="$SMTP_USER" \
        --passwordeval="echo $SMTP_PASS" \
        "$RECIPIENT"

    echo "$LATEST_HASH" > "$TRACK_FILE"
else
    echo "Hash is same as before (${LATEST_HASH}), exiting..."
    exit 0
fi

