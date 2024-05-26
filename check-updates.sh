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

CPU_LOAD_INFO=$(top -bn1 | grep "load avg: " | awk '{print $12 $13 $14}')

MEMORY_INFO=$(free -h | awk '
BEGIN {
    OFS="</td><td>"
    print "<table border=\"1\">"
}
NR==2 {
    print "<tr><th>" $1 "</th><th>" $2 "</th><th>" $3 "</th><th>" $4 "</th><th>" $5 "</th></tr>"
}
NR>2 {
    print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td><td>" $4 "</td><td>" $5 "</td></tr>"
}
END {
    print "</table>"
}')

LOGGED_IN_USERS=$(who | awk '
BEGIN {
    print "<table border=\"1\"><tr><th>User</th><th>Terminal</th><th>Login Time</th><th>IP Address</th></tr>"
}
{
        print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 " " $4 "</td><td>" $5 "</td></tr>"
}
END {
    print "</table>"
}')

NETWORK_INFO=$(ip -brief addr show | awk '
BEGIN {
    print "<table border=\"1\"><tr><th>Interface</th><th>State</th><th>IP Address</th></tr>"
}
{
    print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td></tr>"
}
END {
    print "</table>"
}')

# Collect server time
SERVER_TIME=$(date)

# Collect uptime
UPTIME_INFO=$(uptime -p)

# Extract and format CrowdSec alerts
CSCLI_ALERTS=$(cscli alerts list -o raw | tail -n +2 | csvtool format '<tr><td>%1</td><td>%2</td><td>%3</td><td>%4</td><td>%5</td><td>%6</td><td>%7</td><td>%8</td></tr>\n' - | {
    echo "<table border=\"1\"><tr><th>ID</th><th>Scope</th><th>Value</th><th>Reason</th><th>Country</th><th>AS</th><th>Decisions</th><th>Created At</th></tr>"
    cat
    echo "</table>"
})

# Extract and format CrowdSec decisions
CSCLI_DECISIONS=$(cscli decisions list -o raw | tail -n +2 | csvtool format '<tr><td>%1</td><td>%2</td><td>%3</td><td>%4</td><td>%5</td><td>%6</td><td>%7</td><td>%8</td><td>%9</td><td>%10</td><td>%11</td></tr>\n' - | {
    echo "<table border=\"1\"><tr><th>ID</th><th>Source</th><th>IP</th><th>Reason</th><th>Action</th><th>Country</th><th>AS</th><th>Events Count</th><th>Expiration</th><th>Simulated</th><th>Alert ID</th></tr>"
    cat
    echo "</table>"
})

# Combine all information into one message
EMAIL_BODY=$(cat << EOF
<html>
<body>
<h2>Available Package Updates:</h2>
<p>$FORMATTED_UPGRADE_LIST</p>
<h2>Available Distribution Upgrades:</h2>
<p>$FORMATTED_DIST_UPGRADE_LIST</p>
<h2>Disk Information:</h2>
<p>$FORMATTED_DISK_INFO</p>
<h2>Memory Usage:</h2>
<p>$MEMORY_INFO</p>
<h2>CPU Load:</h2>
<p>$CPU_LOAD</p>
<h2>Logged-in Users:</h2>
<p>$LOGGED_IN_USERS</p>
<h2>Network Information:</h2>
<p>$NETWORK_INFO</p>
<h2>Server Time:</h2>
<p>$SERVER_TIME</p>
<h2>Uptime:</h2>
<p>$UPTIME_INFO</p>
<h2>CrowdSec Alerts:</h2>
<p>$CSCLI_ALERTS</p>
<h2>CrowdSec Decisions:</h2>
<p>$CSCLI_DECISIONS</p>
</body>
</html>
EOF
)

TODAYS_DATE=$(date +"%Y-%m-%d")

# Send the email
echo "$EMAIL_BODY" | mail -s "Daily System Report, $TODAYS_DATE" -a "From: Lightsail Server Daemon <lightsail-apt-updates@thecollectivegc.com>" -a "Content-Type: text/html" webmaster@timothywb.com
