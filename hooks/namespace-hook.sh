#!/usr/bin/env bash

##############################
## generic helper functions ##
##############################

log() { (>&2 echo "[$(date -Iseconds)] $0: $1"); }

catch_error() {
    local err=$?
    if [ $err != 0 ]
    then
        log "ignoring error during script execution, error code: ${err}..."
    fi
    return 0
}

sanitize() {
  echo $1 | sed 's/[^a-zA-Z0-9_-]//g'
}

#####################################
## configuration for this operator ##
#####################################

if [[ $1 == "--config" ]] ; then
  cat <<EOF
  {
    "configVersion":"v1",
    "kubernetes": [
      {
        "apiVersion": "v1",
        "kind": "Namespace",
        "watchEvent": ["Added"]
      }
    ]
  }
EOF
  exit 0
fi

####################################
## to the bat-mobile, let's go... ##
####################################

type=$(jq -r '.[0].object.metadata.annotations["envinit.joyrex2001.com/type"]' $BINDING_CONTEXT_PATH)
type=$(sanitize ${type})

name=$(jq -r '.[0].object.metadata.name' $BINDING_CONTEXT_PATH)
name=$(sanitize ${name})

if  [[ ! "${type}" = "" ]]     && \
    [[ ! "${type}" = "null" ]] && \
    [ -f ${runfolder}/environment/${type}/run.sh ]
then
      log "provisioning namespace '${name}' as a '${type}' environment..." && \
      cd ${runfolder}/environment/${type} || catch_error
      ./run.sh "${name}" || catch_error
fi
