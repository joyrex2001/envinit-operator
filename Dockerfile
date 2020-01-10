#####################
## Download extras ## --------------------------------------------------------
#####################

FROM ubuntu:18.04 AS download

RUN apt-get update && \
    apt-get install -y curl

## Download kustomize
RUN curl -L $(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases \
              | grep browser_download | grep linux | grep kustomize_v | cut -d '"' -f 4 | head -n 1) \
         -o kustomize_latest.tar.gz \
    &&  tar xf kustomize_latest.tar.gz \
    &&  chmod u+x ./kustomize \
    &&  mv ./kustomize /bin/kustomize

#################
## Final image ## ------------------------------------------------------------
#################

FROM docker.io/flant/shell-operator:latest

COPY --from=download /bin/kustomize /bin/kustomize
ADD /environment /environment
ADD /hooks/*.sh /hooks
