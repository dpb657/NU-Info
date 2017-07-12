#!/bin/sh

THIS_DOMAIN="northwestern.edu"
THIS_SITE="EVANSTON"

EVHOST1="evnuinfoprodweb1"
EVHOST2="evnuinfoprodweb2"
EVHOST3="evnuinfoprodweb3"

CHHOST1="chnuinfoprodweb1"
CHHOST2="chnuinfoprodweb2"
CHHOST3="chnuinfoprodweb3"

THIS_HOST="$EVHOST1"
THIS_HOST_FQDN="${EVHOST1}.ci.${THIS_DOMAIN}"

evanston_HOSTS="$EVHOST1 $EVHOST2 $EVHOST3"
chicago_HOSTS="$CHHOST1 $CHHOST2 $CHHOST3"
evanston_HOSTS_FQDN="${EVHOST1}.ci.${THIS_DOMAIN} ${EVHOST2}.ci.${THIS_DOMAIN} ${EVHOST3}.ci.${THIS_DOMAIN}"
chicago_HOSTS_FQDN="${CHHOST1}.ci.${THIS_DOMAIN} ${CHHOST2}.ci.${THIS_DOMAIN} ${CHHOST3}.ci.${THIS_DOMAIN}"

