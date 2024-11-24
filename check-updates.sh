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
APT_UPGRADE_LIST=$(apt list --upgradable 2>/dev/null | awk '
BEGIN {
    count = 0
}
/\[upgradable from:/ {
    if (count == 0) {
        print "<table border=\"1\"><tr><th>Package</th><th>Current Version</th><th>New Version</th></tr>"
    }
    count++
    split($1, pkg, "/")
    current=$NF
    gsub(/[\[\]]/, "", current)
    gsub(/from: /, "", current)
    print "<tr><td>" pkg[1] "</td><td>" current "</td><td>" $2 "</td></tr>"
}
END {
    if (count == 0) {
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
    print "<table border=\"1\"><tr><th>User</th><th>Terminal</th><th>IP Address</th><th>Login Time</th><th>Duration</th></tr>"
}
/^$/ { next }
/^wtmp/ { next }
/^reboot/ { next }
{
    duration = $6
    if (duration > 1440) {
        days = int(duration / 1440)
        hours = int((duration % 1440) / 60)
        minutes = duration % 60
        duration_str = days "d " hours "h " minutes "m"
    } else if (duration > 60) {
        hours = int(duration / 60)
        minutes = duration % 60
        duration_str = hours "h " minutes "m"
    } else {
        duration_str = duration "m"
    }
    print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td><td>" $4 " " $5 "</td><td>" duration_str "</td></tr>"
    login_count++
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
    if ($1 == "lo") {
        next
    }
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
if [ "$(echo "$CSCLI_ALERTS" | wc -l)" -le 1 ]; then # No alerts
    CSCLI_ALERTS="<p>No alerts available.</p>"
else # Alerts exist
    CSCLI_ALERTS=$(echo "$CSCLI_ALERTS" | tail -n +2 | awk -F',' '
    BEGIN {
        print "<table border=\"1\"><tr><th>ID</th><th>Scope</th><th>Value</th><th>Reason</th><th>Country</th><th>AS</th><th>Decisions</th><th>Created At</th></tr>"
    }
    {
        gsub(/^Ip:/, "", $3)      # Remove "Ip:" prefix from Value if present
        gsub(/\./, "-", $3)       # Replace periods with hyphens in Value
        print "<tr>"
        for (i = 1; i <= NF; i++) {
            print "<td><span style=\"pointer-events:none;\">" $i "</span></td>"
        }
        print "</tr>"
    }
    END {
        print "</table>"
    }')
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
if [ "$(echo "$CSCLI_DECISIONS" | wc -l)" -le 1 ]; then # No decisions
    CSCLI_DECISIONS="<p>No decisions available.</p>"
else # Decisions exist
    CSCLI_DECISIONS=$(echo "$CSCLI_DECISIONS" | tail -n +2 | awk -F',' '
    BEGIN {
        print "<table border=\"1\"><tr><th>ID</th><th>Source</th><th>IP</th><th>Reason</th><th>Action</th><th>Country</th><th>AS</th><th>Events Count</th><th>Expiration</th><th>Simulated</th><th>Alert ID</th></tr>"
    }
    {
        gsub(/^Ip:/, "", $3)      # Remove "Ip:" prefix from IP
        gsub(/\./, "-", $3)       # Replace periods with hyphens in IP
        print "<tr>"
        for (i = 1; i <= NF; i++) {
            print "<td><span style=\"pointer-events:none;\">" $i "</span></td>"
        }
        print "</tr>"
    }
    END {
        print "</table>"
    }')
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
            $SERVER_TIME
        <h2>Uptime:</h2>
            $SERVER_UPTIME
        <h2>Available Package Updates:</h2>
            $APT_UPGRADE_LIST
        <h2>Disk Information:</h2>
            $DISK_DETAILS
        <h2>Memory Usage:</h2>
            $MEMORY_DETAILS
        <h2>CPU Load:</h2>
            $CPU_LOAD_DETAILS
        <h2>Active SSH Sessions:</h2>
            $ACTIVE_SSH_SESSIONS
        <h2>Previous SSH Sessions:</h2>
            $PREVIOUS_SSH_SESSIONS
        <h2>Network Information:</h2>
            $NETWORK_DETAILS
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
echo "$EMAIL_BODY" | mail -s "Daily System Report, $TODAYS_DATE" -a "From: Lightsail Web Updates <lightsail-updates@thecollectivegc.com>" -a "Content-Type: text/html" webmaster@timothywb.com

