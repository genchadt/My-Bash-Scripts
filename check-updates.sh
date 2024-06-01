#!/bin/bash

SERVER_HOSTNAME="Lightsail Web"
SERVER_TIME=$(date)
UPTIME_INFO=$(uptime -p)

# Collect and format package and distribution updates
apt-get update -y
UPGRADE_LIST=$(apt list --upgradable 2>/dev/null | grep -E 'upgradable from' | awk -F'[][]' '{print $1 " " $2}' | awk -F' ' '{print $1 " " $2 " " $NF}')

if [ -z "$UPGRADE_LIST" ]; then
    FORMATTED_UPGRADE_LIST="<p>All packages are up to date.</p>"
else
    FORMATTED_UPGRADE_LIST="<table border='1'><tr><th>Package</th><th>Current Version</th><th>New Version</th></tr>"
    while read -r line; do
        PACKAGE=$(echo "$line" | awk -F'/' '{print $1}')
        CURRENT_VERSION=$(echo "$line" | awk '{print $NF}')
        NEW_VERSION=$(echo "$line" | awk '{print $(NF-2)}')
        FORMATTED_UPGRADE_LIST="${FORMATTED_UPGRADE_LIST}<tr><td>${PACKAGE}</td><td>${CURRENT_VERSION}</td><td>${NEW_VERSION}</td></tr>"
    done <<EOF
$UPGRADE_LIST
EOF
    FORMATTED_UPGRADE_LIST="${FORMATTED_UPGRADE_LIST}</table>"
fi

# Collect and format disk information
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

# Collect and format CPU load information
CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | xargs | sed 's/,//g')
FORMATTED_CPU_LOAD_INFO=$(echo "$CPU_LOAD" | awk '
BEGIN {
    print "<table border=\"1\"><tr><th>1 Minute Load</th><th>5 Minute Load</th><th>15 Minute Load</th></tr>"
}
{
    print "<tr><td style=\"text-align:center\">" $1 " %</td><td style=\"text-align:center\">" $2 " %</td><td style=\"text-align:center\">" $3 " %</td></tr>"
}
END {
    print "</table>"
}')

# Collect memory usage
MEMORY_INFO=$(free -h | awk '
BEGIN {
    OFS="</td><td>"
    print "<table border=\"1\"><tr><th>Type</th><th>Total</th><th>Used</th><th>Free</th><th>Shared</th><th>Buff/Cache</th><th>Available</th></tr>"
}
NR==2 {
    print "<tr><td>Memory</td><td>" $2 "</td><td>" $3 "</td><td>" $4 "</td><td>" $5 "</td><td>" $6 "</td><td>" $7 "</td></tr>"
}
NR==3 {
    print "<tr><td>Swap</td><td>" $2 "</td><td>" $3 "</td><td>" $4 "</td><td>-</td><td>-</td><td>-</td></tr>"
}
END {
    print "</table>"
}')

ACTIVE_SSH_SESSIONS=$(who | awk '
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

# Extract and format CrowdSec alerts
CSCLI_ALERTS=$(cscli alerts list -o raw | tail -n +2 | csvtool format '<tr><td><span style="pointer-events:none;">%1</span></td><td><span style="pointer-events:none;">%2</span></td><td><span style="pointer-events:none;">%3</span></td><td><span style="pointer-events:none;">%4</span></td><td><span style="pointer-events:none;">%5</span></td><td><span style="pointer-events:none;">%6</span></td><td><span style="pointer-events:none;">%7</span></td><td><span style="pointer-events:none;">%8</span></td></tr>\n' - | {
    echo "<table border=\"1\"><tr><th>ID</th><th>Scope</th><th>Value</th><th>Reason</th><th>Country</th><th>AS</th><th>Decisions</th><th>Created At</th></tr>"
    cat
    echo "</table>"
})

# Extract and format CrowdSec decisions
CSCLI_DECISIONS=$(cscli decisions list -o raw | tail -n +2 | csvtool format '<tr><td><span style="pointer-events:none;">%1</span></td><td><span style="pointer-events:none;">%2</span></td><td><span style="pointer-events:none;">%3</span></td><td><span style="pointer-events:none;">%4</span></td><td><span style="pointer-events:none;">%5</span></td><td><span style="pointer-events:none;">%6</span></td><td><span style="pointer-events:none;">%7</span></td><td><span style="pointer-events:none;">%8</span></td><td><span style="pointer-events:none;">%9</span></td><td><span style="pointer-events:none;">%10</span></td><td><span style="pointer-events:none;">%11</span></td></tr>\n' - | {
    echo "<table border=\"1\"><tr><th>ID</th><th>Source</th><th>IP</th><th>Reason</th><th>Action</th><th>Country</th><th>AS</th><th>Events Count</th><th>Expiration</th><th>Simulated</th><th>Alert ID</th></tr>"
    cat
    echo "</table>"
})

EMAIL_BODY=$(cat << EOF
<html>
<head>
<style>
body {
    font-family: Arial, sans-serif;
}
h1 {
    font-size: 24px;
    color: #333333;
}
h2 {
    font-size: 20px;
    color: #555555;
}
table {
    width: 100%;
    border-collapse: collapse;
}
table, th, td {
    border: 1px solid #dddddd;
}
th, td {
    padding: 8px;
    text-align: left;
}
th {
    background-color: #f2f2f2;
    color: #333333;
}
tr:nth-child(even) {
    background-color: #f9f9f9;
}
.spoiler {
    #color: #333333;
    #background-color: #f2f2f2;
    border: 1px solid #ddd;
    padding: 5px;
    cursor: pointer;
    display: inline-block;
}
</style>
<script>
function toggleSpoiler(id) {
    var element = document.getElementById(id);
    if (element.style.color === "rgb(255, 255, 255)") {
        element.style.color = "black";
        element.style.backgroundColor = "white";
    } else {
        element.style.color = "white";
        element.style.backgroundColor = "#555555";
    }
}
</script>
</head>
<body>
<h1>Server Status Report: $SERVER_HOSTNAME</h1>
<h2>Server Time:</h2>
<p>$SERVER_TIME</p>
<h2>Uptime:</h2>
<p>$UPTIME_INFO</p>
<h2>Available Package Updates:</h2>
<p>$FORMATTED_UPGRADE_LIST</p>
<h2>Available Distribution Upgrades:</h2>
<p>$FORMATTED_DIST_UPGRADE_LIST</p>
<h2>Disk Information:</h2>
<p>$FORMATTED_DISK_INFO</p>
<h2>Memory Usage:</h2>
<p>$MEMORY_INFO</p>
<h2>CPU Load:</h2>
<p>$FORMATTED_CPU_LOAD_INFO</p>
<h2>Active SSH Sessions:</h2>
<p>$ACTIVE_SSH_SESSIONS</p>
<h2>Network Information:</h2>
<p>$NETWORK_INFO</p>
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
echo "$EMAIL_BODY" | mail -s "Daily System Report, $TODAYS_DATE" -a "From: Lightsail Web Updates <lightsail-updates@thecollectivegc.com>" -a "Content-Type: text/html" webmaster@timothywb.com
