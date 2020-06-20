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
        "watchEvent": ["Added","Modified"]
      }
    ]
  }
EOF
  exit 0
fi

####################################
## to the bat-mobile, let's go... ##
####################################

list=""
[ "$(cat $BINDING_CONTEXT_PATH | jq '.[].objects' | head -n 1)" == "null" ] || list=".objects[]"

query=$(cat << _JQ_QUERY
        .[]${list} as \$item | \
        "\(\$item.object.metadata.name),\
        \(\$item.object.metadata.annotations["envinit.joyrex2001.com/type"]),\
        \(\$item.object.metadata.annotations["envinit.joyrex2001.com/applied"])"
_JQ_QUERY
)

cat $BINDING_CONTEXT_PATH | jq -r "${query}" |
while IFS=$',' read -r name type applied; do
    type=$(sanitize ${type})
    name=$(sanitize ${name})
    applied=$(sanitize ${applied})

    if  [[ ! "${type}" = "" ]]     && \
        [[ ! "${type}" = "null" ]] && \
        [[ "${applied}" = "null" ]]  && \
        [ -f ${runfolder}/environment/${type}/run.sh ]
    then
        log "provisioning namespace '${name}' as a '${type}' environment..." && \
        cd ${runfolder}/environment/${type} || catch_error
        ./run.sh "${name}" || catch_error
        kubectl annotate namespace ${name} envinit.joyrex2001.com/applied=$(date +%s) --overwrite=true
     else
        log "skip provisioning namespace '${name}'..."
    fi
done
