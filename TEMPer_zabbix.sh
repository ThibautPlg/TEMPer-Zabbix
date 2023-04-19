#!/usr/bin/env sh

##################### CONFIG ###########################
########################################################
# To configure the JSON PARSING, follow the guide of
# temper.py and change the jq query to match your output.
#   ==    https://github.com/urwen/temper    ==

TEMPERPY=/home/pi/temper/temper.py
ZABBIX_CONF=/etc/zabbix/zabbix_agentd.conf
ZABBIX_SENDER=/usr/bin/zabbix_sender
JQ=/usr/bin/jq
# Should be ok for TEMPer 0c45:7401
TEMPER_JSON_PARSING=".[0][\"internal temperature\"]"

##################### END CONFIG ###########################

exit_with_error(){
  echo 1>&2 "TEMPer_zabbix.sh: ERROR: ${2}"
  exit ${1}
}

zabbixsend() {
  key=${1}
  shift
  message="${@}"
  ${ZABBIX_SENDER} -c "${ZABBIX_CONF}" -k $key -o "${message}"
}

datestamp() {
  local formatting="+%F %T %z"
  date "${formatting}"
}

check_config() {
  failures=0

  # checking zabbix
  if [ ! -f "${ZABBIX_CONF}" ];then
    echo 1>&2 "ZABBIX_CONF Not found, check config at top of script"
    failures=$(( ${failures} + 1 ))
  fi
  if [ ! -x "${ZABBIX_SENDER}" ];then
    echo 1>&2 "ZABBIX_SENDER Not a program, check config at top of script. Looking for zabbix_sender in PATH"
    which zabbix_sender
    failures=$(( ${failures} + 1 ))
  fi

  # check jq
  if [ ! -x "${JQ}" ];then
    echo 1>&2 "jq Not a program, check config at top of script. Looking for jq in PATH"
    which jq
    failures=$(( ${failures} + 1 ))
  fi

  # check temper.py
  if [ ! -x ${TEMPERPY} ];then
    echo 1>&2 "temper.py is not found. Check config at top of script"
    failures=$(( ${failures} + 1 ))
  fi

  if [ $failures -gt 0 ];then
    exit_with_error 2 "Script config is not set up correctly. please check config at top of script. see errors above "
   else
    return 0
  fi
}

temper_error() {
  echo 1>&2  "temper.py command failed. Check config at top of this script."
  INFO="DATE	: $(datestamp)
temper.py command failed.
"
  zabbixsend temper.is_online 0
  exit 1
}

main() {
  check_config

  # Get data from TEMPer
  # looks like ./temper.py --json |jq '.[0]["internal temperature"]'
  DATA="$( ${TEMPERPY} --json |jq "${TEMPER_JSON_PARSING}" )" || temper_error

  zabbixsend temper.temperature ${DATA}
  zabbixsend temper.is_online 1
}

main "${@}"