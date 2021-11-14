#! /bin/bash
# Script to test if all the relevant components of bahmni are active
# A total of 8 services are to be tested

declare -a MODULES=("httpd" "openmrs" "bahmni-reports" "bahmni-lab" "odoo" "bahmni-erp-connect" "atomfeed-console" "mysqld" "postgresql-9.6")

# Start with new line
echo ""

# Colors for the output
ERROR='\033[0;31m'
SUCCESS='\033[0;32m'
INFO='\033[1;34m'
NC='\033[0m'

# Required status
STATE=active

# Testing httpd
for val in ${MODULES[@]}; do
 echo "********************************"
 echo -e "${INFO} $val Service${NC}"
 echo "********************************"
 echo "Testing $val.service to identify status...."
 STATUS=$(systemctl status $val.service | grep -o "$STATE")
 if [ "$STATUS" == "active" ]
 then
  echo -e "${SUCCESS}Service $val is active and operational${NC}\n"
 else
  echo -e "${ERROR}Service $val is down. Check logs for more info.${NC}\n"
 fi
done
