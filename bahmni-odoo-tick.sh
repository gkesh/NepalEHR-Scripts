#! /bin/bash

##############################################################
## Odoo Service Check Script                                ##
##############################################################
##                                                          ##
## The script tests if the odoo service is running with     ##
## a loop repeating every 30 seconds and restarts the       ##
## service if it has stopped.                               ##
##                                                          ##
## The script will run inside the following service.        ##
##                                                          ##
##############################################################
## Service File: odoo-tick.service                          ##
##############################################################
##                                                          ##
## [Unit]                                                   ##
## Description=Odoo Tick Service                            ##
## After=network-online.target                              ##    
## After=network.service                                    ##
##                                                          ##
## [Service]                                                ##
## Type=simple                                              ##
## KillMode=none                                            ##
## GuessMainPID=no                                          ##
## RuntimeDirectory=odoo-tick                               ##
## LogsDirectory=odoo-tick                                  ##
## User=root                                                ##
## Group=root                                               ##
## PIDFile=/var/run/odoo-tick/odoo-tick.pid                 ##
## ExecStart=/etc/init.d/odoo-tick start                    ##
## ExecStop=/etc/init.d/odoo-tick stop                      ##
## ExecReload=/etc/init.d/odoo-tick restart                 ##
##                                                          ##
## [Install]                                                ##
## WantedBy=multi-user.target                               ##
##############################################################

LOG_DIR="/var/log/odoo-tick"
LOG_FILE="$LOG_DIR/odoo-tick.log"
PID_DIR="/var/run/odoo-tick"
PID_FILE="$PID_DIR/odoo-tick.pid"

MAX_ATTEMPTS=5


# Function to format log entries
format_log() {
    now=$(date)
    echo "[$1] $now: $2"
}

check_pid() {
    # Checking PID File
    if [ -f "$PID_FILE" ]; then
        # Return 0 if process is running
        return 0
    else
        # Return 1 if process is not running
        return 1
    fi
}

start() {
    # Checking PID File
    check_pid
    if [ $? -eq 0 ]; then
        # PID file exists, the process is already running
        echo $(format_log "ERROR" "Process is already running.")
        return 0
    fi

    if [ ! -d "$LOG_DIR" ]; then
        echo $(format_log "WARN" "Log directory not found, creating...")
        mkdir "$LOG_DIR"

        if [ ! $? -eq 0 ]; then
            echo $(format_log "ERROR" "Failed to create log directory")
            exit 1
        fi
    fi

    # Track attempts made to restart odoo
    ATTEMPTS=0
    
    echo $(format_log "INFO" "Odoo Tick service started.") >> "$LOG_FILE"
    # Infinite loop to keep the service running
    while true; do
        systemctl is-active --quiet odoo.service

        if [ ! $? -eq 0 ]; then

            if [ $ATTEMPTS -gt $MAX_ATTEMPTS ]; then
                echo $(format_log "ERROR" "Failed to restart odoo service. Please check odoo logs...") >> "$LOG_FILE"
                return 1
            fi 

            if [ ! -f "$LOG_FILE" ]; then
                echo $(format_log "WARN" "Log file not found. Generating new file...")
                touch "$LOG_FILE"

                if [ ! $? -eq 0 ]; then
                    echo $(format_log "ERROR" "Failed to create log file.")
                    return 1
                fi    
            fi

            ATTEMPTS=$((ATTEMPTS+1))

            echo $(format_log "WARN" "Odoo service is down. (Attempt $ATTEMPTS) Attempting restart..") >> "$LOG_FILE"
            systemctl restart odoo.service

            if [ $? -eq 0 ]; then
                ATTEMPTS=0
                echo $(format_log "SUCCESS" "Odoo service is up and running.") >> "$LOG_FILE"
            fi

            sleep 5
            continue
        fi

        sleep 30
    done
}

status() {
    check_pid
    STATUS=$?

    if [ $STATUS -eq 0 ]; then
        echo "Odoo Ticker is running..."
    else
        echo "Odoo Ticker is stopped"
    fi

    return $STATUS
}

stop() {
    check_pid
    STATUS=$?

    if [ $STATUS -eq 1 ]; then
        echo "Odoo Ticker is not running..."
    else
        kill -TERM $(cat $PID_FILE)

        if [ ! $? -eq 0 ]; then
            echo "Error occured, failed to kill process."
            return 1
        fi
    fi

    echo $(format_log "INFO" "Odoo Tick service stopped.") >> "$LOG_FILE"

    return $STATUS
}

restart() {
    echo $(format_log "INFO" "Odoo Tick service restarting...") >> "$LOG_FILE"
    stop
    start
}


case "$1" in
start)
    start &
    ;;
stop)
    stop
    ;;
restart|reload)
    restart
    ;;
status)
    status
    ;;
*)
    echo "Invalid option:: Try start, stop, restart, reload or status."
    ;;
esac
