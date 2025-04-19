#!/bin/bash

# === CONFIG ===
EMAIL_RECIPIENT="12302080601010@adit.ac.in"
LOG_DIR="logs"
ARCHIVE_DIR="$LOG_DIR/archive"
REPORT_DIR="reports"
MAIL_CONFIG="~/.mailrc"  # Adjust if needed

# === SETUP ===
mkdir -p "$LOG_DIR" "$ARCHIVE_DIR" "$REPORT_DIR"

# === INPUT VALIDATION ===
if [ -z "$1" ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

LOG_FILE="$1"
BASENAME=$(basename "$LOG_FILE" | cut -d. -f1)
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
HTML_FILE="$REPORT_DIR/${BASENAME}_report.html"
ARCHIVE_FILE="$ARCHIVE_DIR/${BASENAME}.txt.bak"

# === FILTERING LOGS ===
FILTERED_LOG=$(mktemp)
grep -iE "error|fail|unauthorized|warning" "$LOG_FILE" > "$FILTERED_LOG"

# === COUNTING ===
ERRORS=$(grep -ci "error" "$FILTERED_LOG")
WARNINGS=$(grep -ci "warning" "$FILTERED_LOG")
FAILED_LOGINS=$(grep -ci "failed password" "$FILTERED_LOG")
UNAUTHORIZED=$(grep -ci "unauthorized" "$FILTERED_LOG")
CRASHES=$(grep -ci "crash" "$FILTERED_LOG")

# === FREQUENT LOG MESSAGES ===
TOP_LOGS=$(awk '{ $1=$2=$3=""; print $0 }' "$FILTERED_LOG" | sort | uniq -c | sort -nr | head -5)

# === TERMINAL REPORT ===
echo -e "\n==== \e[1;36mLog Analysis Report\e[0m ===="
echo -e "📅 Date: $(date)"
echo -e "📁 File Analyzed: $LOG_FILE"
echo "-------------------------------"
echo -e "🔴 Errors: $ERRORS"
echo -e "🟠 Warnings: $WARNINGS"
echo -e "🔐 Failed Logins: $FAILED_LOGINS"
echo -e "⛔ Unauthorized Access: $UNAUTHORIZED"
echo -e "💥 Crashes: $CRASHES"

echo -e "\n📊 \e[1;35mTop 5 Frequent Log Messages:\e[0m"
echo "$TOP_LOGS"

echo -e "\n🔍 \e[1;34mDetailed Matching Log Entries:\e[0m"
cat "$FILTERED_LOG" | head -10
echo "..."

# === SAVE HTML REPORT ===
cat <<EOF > "$HTML_FILE"
<html>
<head><title>Log Report - $LOG_FILE</title></head>
<body style="font-family: Arial; background:#111; color:#eee;">
<h2>📝 Log Analysis Report</h2>
<p><strong>Date:</strong> $(date)</p>
<p><strong>File:</strong> $LOG_FILE</p>
<hr>
<ul>
  <li>🔴 Errors: $ERRORS</li>
  <li>🟠 Warnings: $WARNINGS</li>
  <li>🔐 Failed Logins: $FAILED_LOGINS</li>
  <li>⛔ Unauthorized: $UNAUTHORIZED</li>
  <li>💥 Crashes: $CRASHES</li>
</ul>
<h3>📊 Top 5 Frequent Log Messages:</h3>
<pre>$TOP_LOGS</pre>
<h3>🔍 Detailed Matching Entries (First 10):</h3>
<pre>$(head -10 "$FILTERED_LOG")</pre>
</body></html>
EOF

echo -e "📄 HTML report saved to: $HTML_FILE"

# === ARCHIVE LOG FILE ===
cp "$LOG_FILE" "$ARCHIVE_FILE"
echo -e "🗃 Archived log to: $ARCHIVE_FILE"

# === SEND EMAIL ===
EMAIL_SUBJECT="Log Report for $LOG_FILE"
EMAIL_BODY="Hi,\n\nPlease find attached the HTML report for analyzed log: $LOG_FILE\n\nRegards,\nLog Analyzer Script"
echo -e "$EMAIL_BODY" | mailx -a "$HTML_FILE" -s "$EMAIL_SUBJECT" "$EMAIL_RECIPIENT"

echo -e "📧 Email sent to: $EMAIL_RECIPIENT"
