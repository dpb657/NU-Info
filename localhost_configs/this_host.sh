#!/bin/sh

THIS_DOMAIN="northwestern.edu"
THIS_SITE="evanston"

EVHOST1="evnuinfoprodweb1"
EVHOST2="evnuinfoprodweb2"
EVHOST3="evnuinfoprodweb3"

CHHOST1="chnuinfoprodweb1"
CHHOST2="chnuinfoprodweb2"
CHHOST3="chnuinfoprodweb3"

THIS_HOST="$EVHOST1"
THIS_HOST_FQDN="${EVHOST1}.${THIS_DOMAIN}"

evanston_HOSTS="$EVHOST1 $EVHOST2 $EVHOST3"
chicago_HOSTS="$CHHOST1 $CHHOST3 $CHHOST3"
evanston_HOSTS_FQDN="${EVHOST1}.${THIS_DOMAIN} ${EVHOST2}.${THIS_DOMAIN} ${EVHOST3}.${THIS_DOMAIN}"
chicago_HOSTS_FQDN="${CHHOST1}.${THIS_DOMAIN} ${CHHOST2}.${THIS_DOMAIN} ${CHHOST3}.${THIS_DOMAIN}"

