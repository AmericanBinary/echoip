#!/bin/sh
# Entrypoint of the PDT image (pdt/jib.yaml): runs echoip with each GeoIP
# database that is present, so the same image works with and without them.
#
#   -f (country): /opt/echoip/db/country.mmdb (an operator's file mounted over
#      the image, e.g. the ACC chart's geoip.countryDatabaseHostPath), else
#      /opt/echoip/data/country.mmdb, else /opt/echoip/data/city.mmdb (a City
#      database also answers country lookups)
#   -c (city):    /opt/echoip/data/city.mmdb
#   -a (ASN):     /opt/echoip/data/asn.mmdb
#
# Arguments are passed to echoip after the database flags (default, from the
# image cmd: -p -r -H X-Forwarded-For). An argument -f, -c or -a given here
# replaces the detected one (the last flag wins).
set -eu

data=/opt/echoip/data
db=""

for f in /opt/echoip/db/country.mmdb "${data}/country.mmdb" "${data}/city.mmdb"; do
  if [ -f "${f}" ]; then db="${db} -f ${f}"; break; fi
done
if [ -f "${data}/city.mmdb" ]; then db="${db} -c ${data}/city.mmdb"; fi
if [ -f "${data}/asn.mmdb" ]; then db="${db} -a ${data}/asn.mmdb"; fi

# shellcheck disable=SC2086 # the paths above have no spaces
exec /opt/echoip/echoip ${db} "$@"
