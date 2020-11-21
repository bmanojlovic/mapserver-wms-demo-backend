#!/bin/bash
set -e

function _log { D=$(date  +"%Y%m%dT%H:%M:%S"); echo -e $D "$@"; }
function log_error { _log "\e[0;31mERROR\e[0m : $@"; exit -1; }
function log_warn { ISSUE=$(($ISSUE + 1 )); _log "\e[0;33mWARN\e[0m  : $@"; }
function log_info { _log "\e[1;32mINFO\e[0m  : $@"; }


# we need it... if you do not, set with -mapcache or fcgid in APACHE_MODULES
a2enmod mapcache  || :
a2enmod fcgid || :
a2enmod headers || :
##### Please try not hardcoding passwords for db access - if using one...

if [ -n "${CONFIG_FILES}" ]; then
  if [ -z "${DB_USERNAME}" -a -z "${DB_PASSWORD}" ]; then
    log_error "Please provide both DB_USERNAME and DB_PASSWORD"
  fi
  for cfgfile in "${CONFIG_FILES}"; do
    sed -i "s/__DB_USERNAME__/${DB_USERNAME}/g" $cfgfile
    sed -i "s/__DB_PASSWORD__/${DB_PASSWORD}/g" $cfgfile
    if [ -n "${DB_HOST}" ]; then
      sed -i "s/__DB_HOST__/${DB_HOST}/g" $cfgfile
    fi
  done
fi


# apache modules which you would like to enable set as env var APACHE_MODULES
if [ -n "${APACHE_MODULES}" ]; then
  for module in ${APACHE_MODULES}; do 
    if [[ ${module:0:1} = '-' ]]; then
      a2dismod ${module:1}
    else
      a2enmod ${module}
    fi
  done
fi

# same logic for flags (such as SSL)
if [ -n "${APACHE_FLAGS}" ]; then
  for flag in ${APACHE_FLAGS}; do 
    if [[ ${flag:0:1} = '-' ]]; then
      a2enflag -d $flag
    else
      a2enflag $flag
    fi
  done
fi
mkdir -p /srv/www/maps/{cache,data} || : 
chown -R wwwrun. /srv/www/maps/{data,cache} || :

# default behaviour is to launch apache2...
if [[ -z ${1} ]]; then
  echo "Starting apache2..."
  exec /usr/sbin/start_apache2 -DFOREGROUND
else
  exec "$@"
fi
