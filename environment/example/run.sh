#!/usr/bin/env bash

log() { (>&2 echo "[$(date -Iseconds)] $0: $1"); }

####################################
## to the bat-mobile, let's go... ##
####################################

NAMESPACE=$1
[ -z "${NAMESPACE}" ] && log "Missing namespace (arg 1), bailing out..." && exit 1

kustomize build kustomize | kubectl apply -f - -n ${NAMESPACE}