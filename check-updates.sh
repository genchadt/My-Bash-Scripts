#!/bin/bash

# Update package list
apt-get update -y

# Collect package updates
UPGRADE_LIST=$(apt list --upgradable 2>/dev/null | grep -E 'upgradable from' | awk -F'[][]' '{print $2 " " $3}')

if [ -z "$UPGRADE_LIST" ]; then
    FORMATTED_UPGRADE_LIST="<p>No package updates available.</p>"
else
    FORMATTED_UPGRADE_LIST="<table border='1'><tr><th>Package</th><th>Current Version</th><th>New Version</th></tr>"
    while read -r line; do
        PACKAGE=$(echo "$line" | awk '{print $1}')
        VERSIONS=$(echo "$line" | awk '{print $2}')
        CURRENT_VERSION=$(echo "$VERSIONS" | awk -F'/' '{print $1}')
        NEW_VERSION=$(echo "$VERSIONS" | awk -F'/' '{print $2}')
        FORMATTED_UPGRADE_LIST+="<tr><td>${PACKAGE}</td><td>${CURRENT_VERSION}</td><td>${NEW_VERSION}</td></tr>"
    done <<EOF
$UPGRADE_LIST
EOF
    FORMATTED_UPGRADE_LIST+="</table>"
fi

# Collect distribution upgrades
DIST_UPGRADE_LIST=$(apt-get -s dist-upgrade | grep "^Inst" | awk '{print $2}')

if [ -z "$DIST_UPGRADE_LIST" ]; then
    FORMATTED_DIST_UPGRADE_LIST="<p>No distribution upgrades available.</p>"
else
    FORMATTED_DIST_UPGRADE_LIST="<table border='1'><tr><th>Package</th></tr>"
    while read -r line; do
        FORMATTED_DIST_UPGRADE_LIST+="<tr><td>$line</td></tr>"
    done <<EOF
$DIST_UPGRADE_LIST
EOF
    FORMATTED_DIST_UPGRADE_LIST+="</table>"
fi

# Collect disk information
DISK_INFO=$(df -h | awk '
BEGIN {
    OFS="</td><td>"
    print "<table border=\"1\">"
}
NR==1 {
    print "<tr><th>" $1 "</th><th>" $2 "</th><th>" $3 "</th><th>" $4 "</th><th>" $5 "</th><th>Mounted on</th></tr>"
}
NR>1 {
    print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td><td>" $4 "</td><td>" $5 "</td><td>" $6 "</td></tr>"
}
END {
    print "</table>"
}')

FORMATTED_DISK_INFO="<table border='1'>$DISK_INFO</table>"

# Collect server time
SERVER_TIME=$(date)

# Collect uptime
UPTIME_INFO=$(uptime -p)

# Fetch raw data from cscli commands
ALERTS_RAW=$(cscli alerts list -o raw)
DECISIONS_RAW=$(cscli decisions list -o raw)

# Function to convert CSV to HTML table
csv_to_html_table() {
    local csv_data="$1"
    local html_table="<table border=\"1\"><tr>"

    # Read the header and create table headers
    IFS=',' read -ra headers <<< "$(echo "$csv_data" | head -n 1)"
    for header in "${headers[@]}"; do
        html_table+="<th>${header}</th>"
    done
    html_table+="</tr>"

    # Read each line and create table rows
    while IFS=',' read -ra line; do
        html_table+="<tr>"
        for field in "${line[@]}"; do
            html_table+="<td>${field}</td>"
        done
        html_table+="</tr>"
    done < <(echo "$csv_data" | tail -n +2)

    html_table+="</table>"
    echo "$html_table"
}

# Convert raw CSV data to HTML tables
CSCLI_ALERTS=$(csv_to_html_table "$ALERTS_RAW")
CSCLI_DECISIONS=$(csv_to_html_table "$DECISIONS_RAW")

# Combine all information into one message
EMAIL_BODY=$(cat << EOF
<html>
<body>
<h2>Available Package Updates:</h2>
$FORMATTED_UPGRADE_LIST
<h2>Available Distribution Upgrades:</h2>
$FORMATTED_DIST_UPGRADE_LIST
<h2>Disk Information:</h2>
$FORMATTED_DISK_INFO
<h2>Server Time:</h2>
<p>$SERVER_TIME</p>
<h2>Uptime:</h2>
<p>$UPTIME_INFO</p>
<h2>CrowdSec Alerts:</h2>
$CSCLI_ALERTS
<h2>CrowdSec Decisions:</h2>
$CSCLI_DECISIONS
</body>
</html>
EOF
)

TODAYS_DATE=$(date +"%Y-%m-%d")

# Send the email
echo "$EMAIL_BODY" | mail -s "Daily System Report, $TODAYS_DATE" -a "From: Lightsail Server Daemon <lightsail-apt-updates@thecollectivegc.com>" -a "Content-Type: text/html" webmaster@timothywb.com
