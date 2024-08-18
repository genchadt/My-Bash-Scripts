#!/bin/bash

# Server details && time
SERVER_HOSTNAME="Lightsail Web"
SERVER_TIME=$(date)
SERVER_UPTIME=$(uptime -p)

# Package update details
# <table border="1">
#     <tr>
#         <th>Package</th>
#         <th>Current Version</th>
#         <th>New Version</th>
#     </tr>
# </table>apt-get update -y
APT_UPGRADE_LIST=$(apt list --upgradable 2>/dev/null | grep -E 'upgradable from' | awk '
BEGIN {
    list_count = 0
}
{
    if (list_count == 0) {
        print "<table border=\"1\"><tr><th>Package</th><th>Current Version</th><th>New Version</th></tr>"
    }
    list_count++
    split($1, package, "/")
    new_version = $2
    current_version = $NF
    gsub(/[\[\]]/, "", current_version)
    print "<tr><td>" package[1] "</td><td>" current_version "</td><td>" new_version "</td></tr>"
}
END {
    if (list_count == 0) {
        print "<p>All packages are up to date.</p>"
    } else {
        print "</table>"
    }
}')

# Memory details
# Disk details
# <table border="1">
#     <tr>
#         <th>Filesystem</th>
#         <th>Size</th>
#         <th>Used</th>
#         <th>Available</th>
#         <th>Use%</th>
#         <th>Mounted on</th>
#     </tr>
# </table>
DISK_DETAILS=$(df -h | awk '
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

# CPU details
# <table border="1">
#     <tr>
#         <th>1 Minute Load</th>
#         <th>5 Minute Load</th>
#         <th>15 Minute Load</th>
#     </tr>
# </table>
CPU_LOAD_DETAILS=$(uptime | awk -F'load average: ' '{print $2}' | tr -d ',' | awk '
BEGIN {
    print "<table border=\"1\"><tr><th>1 Minute Load</th><th>5 Minute Load</th><th>15 Minute Load</th></tr>"
}
{
    split($0, loads)
    print "<tr><td style=\"text-align:center\">" loads[1] " %</td><td style=\"text-align:center\">" loads[2] " %</td><td style=\"text-align:center\">" loads[3] " %</td></tr>"
}
END {
    print "</table>"
}')

# Memory details
# <table border="1">
#     <tr>
#         <th>Type</th>
#         <th>Total</th>
#         <th>Used</th>
#         <th>Free</th>
#         <th>Shared</th>
#         <th>Buff/Cache</th>
#         <th>Available</th>
#     </tr>
# </table>
MEMORY_DETAILS=$(free -h | awk '
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

# Active SSH sessions
# <table border="1">
#     <tr>
#         <th>User</th>
#         <th>Terminal</th>
#         <th>Login Time</th>
#         <th>IP Address</th>
#     </tr>
# </table>
ACTIVE_SSH_SESSIONS=$(who | awk '
BEGIN {
    session_count = 0
}
{
    if (session_count == 0) {
        print "<table border=\"1\"><tr><th>User</th><th>Terminal</th><th>Login Time</th><th>IP Address</th></tr>"
    }
    session_count++
    print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 " " $4 "</td><td>" $5 "</td></tr>"
}
END {
    if (session_count == 0) {
        print "<p>No active SSH sessions found.</p>"
    } else {
        print "</table>"
    }
}')

# Previous SSH sessions
# <table border="1">
#     <tr>
#         <th>User</th>
#         <th>Terminal</th>
#         <th>Login Time</th>
#         <th>IP Address</th>
#     </tr>
# </table>
PREVIOUS_SSH_SESSIONS=$(last -n 10 | awk '
BEGIN {
    login_count = 0
    print "<table border=\"1\"><tr><th>User</th><th>Terminal</th><th>Login Time</th><th>IP Address</th></tr>"
}
{
    login_count++
    split($1, user, "pts/")
    print "<tr><td>" user[1] "</td><td>" $2 "</td><td>" $3 " " $4 "</td><td>" $5 "</td></tr>"
}
END {
    if (login_count == 0) {
        print "<p>No recent SSH logins found.</p>"
    } else {
        print "</table>"
    }
}')

# Network details
# <table border="1">
#     <tr>
#         <th>Interface</th>
#         <th>State</th>
#         <th>IP Address</th>
#     </tr>
# </table>
NETWORK_DETAILS=$(ip -brief addr show | awk '
BEGIN {
    print "<table border=\"1\"><tr><th>Interface</th><th>State</th><th>IP Address</th></tr>"
}
{
    print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td></tr>"
}
END {
    print "</table>"
}')

# CrowdSec alerts
# <table border="1">
#     <tr>
#         <th>ID</th>
#         <th>Scope</th>
#         <th>Value</th>
#         <th>Reason</th>
#         <th>Country</th>
#         <th>AS</th>
#         <th>Decisions</th>
#         <th>Created At</th>
#     </tr>
# </table>
CSCLI_ALERTS=$(cscli alerts list -o raw)
if [ "$(echo "$CSCLI_ALERTS" | wc -l)" -le 1 ]; then # no alerts
    CSCLI_ALERTS="<p>No alerts available.</p>"
else # alerts
    CSCLI_ALERTS=$(echo "$CSCLI_ALERTS" | tail -n +2 | csvtool format "<tr><td><span style='pointer-events:none;'>%1</span></td><td><span style='pointer-events:none;'>%2</span></td><td><span style='pointer-events:none;'>$(echo %3 | sed 's/\./-/g')</span></td><td><span style='pointer-events:none;'>%4</span></td><td><span style='pointer-events:none;'>%5</span></td><td><span style='pointer-events:none;'>%6</span></td><td><span style='pointer-events:none;'>%7</span></td><td><span style='pointer-events:none;'>%8</span></td></tr>\n" - | {
        echo "<table border=\"1\"><tr><th>ID</th><th>Scope</th><th>Value</th><th>Reason</th><th>Country</th><th>AS</th><th>Decisions</th><th>Created At</th></tr>"
        cat
        echo "</table>"
    })
fi

# CrowdSec decisions
# <table border="1">
#     <tr>
#         <th>ID</th>
#         <th>Source</th>
#         <th>IP</th>
#         <th>Reason</th>
#         <th>Action</th>
#         <th>Country</th>
#         <th>AS</th>
#         <th>Events Count</th>
#         <th>Expiration</th>
#         <th>Simulated</th>
#         <th>Alert ID</th>
#     </tr>
# </table>
CSCLI_DECISIONS=$(cscli decisions list -o raw)
if [ "$(echo "$CSCLI_DECISIONS" | wc -l)" -le 1 ]; then # no decisions
    CSCLI_DECISIONS="<p>No decisions available.</p>"
else # decisions
    CSCLI_DECISIONS=$(echo "$CSCLI_DECISIONS" | tail -n +2 | csvtool format "<tr><td><span style='pointer-events:none;'>%1</span></td><td><span style='pointer-events:none;'>%2</span></td><td><span style='pointer-events:none;'>$(echo %3 | sed 's/\./-/g')</span></td><td><span style='pointer-events:none;'>%4</span></td><td><span style='pointer-events:none;'>%5</span></td><td><span style='pointer-events:none;'>%6</span></td><td><span style='pointer-events:none;'>%7</span></td><td><span style='pointer-events:none;'>%8</span></td><td><span style='pointer-events:none;'>%9</span></td><td><span style='pointer-events:none;'>%10</span></td><td><span style='pointer-events:none;'>%11</span></td></tr>\n" - | {
        echo "<table border=\"1\"><tr><th>ID</th><th>Source</th><th>IP</th><th>Reason</th><th>Action</th><th>Country</th><th>AS</th><th>Events Count</th><th>Expiration</th><th>Simulated</th><th>Alert ID</th></tr>"
        cat
        echo "</table>"
    })
fi

# E-mail body construction
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
    </head>
    <body>
        <h1>Server Status Report: $SERVER_HOSTNAME</h1>
        <h2>Server Time:</h2>
            <p>$SERVER_TIME</p>
        <h2>Uptime:</h2>
            <p>$SERVER_UPTIME</p>
        <h2>Available Package Updates:</h2>
            <p>$APT_UPGRADE_LIST</p>
        <h2>Disk Information:</h2>
            <p>$DISK_DETAILS</p>
        <h2>Memory Usage:</h2>
            <p>$MEMORY_DETAILS</p>
        <h2>CPU Load:</h2>
            <p>$CPU_LOAD_DETAILS</p>
        <h2>Active SSH Sessions:</h2>
            <p>$ACTIVE_SSH_SESSIONS</p>
        <h2>Previous SSH Sessions:</h2>
            <p>$PREVIOUS_SSH_SESSIONS</p>
        <h2>Network Information:</h2>
            <p>$NETWORK_DETAILS</p>
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
