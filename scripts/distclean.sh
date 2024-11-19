#!/usr/bin/env bash

#
# script is not intended to be executed directly. use `pnpm exec ...` instead or call it as package script.
#
# this script cleans up the environment as if it was never started
#
# ATTENTION: Please ensure that wp-env is stopped before cleaning up wp-env-home
#

# bootstrap the environment
source "$(realpath $0 | xargs dirname)/includes/bootstrap.sh"

# MARK: test wp-env not running
# ensure wp-env is not running
# - if the install path does not exist
# - and the wp-env containers are not running
WPENV_INSTALLPATH="$(realpath --relative-to $(pwd) $(pnpm exec wp-env install-path))"
if [[ -d "$WPENV_INSTALLPATH/WordPress" ]] && [[ "$(docker ps -q --filter "name=$(basename $WPENV_INSTALLPATH)" | wc -l)" == '6' ]]; then
  ionos.wordpress.log_warn "wp-env is already running. Excecute 'pnpm stop' or 'pnpm destroy' to stop it before cleaning up."
  exit 1
fi
# ENDMARK

# MARK: cleanup docker images
# loop over all docker workspace packages
for PACKAGE_JSON in $(find packages/docker -maxdepth 2 -mindepth 2 -name "package.json" 2>/dev/null ||:); do
# we need to encase the loop in a subshell to avoid variable pollution
(
  # inject .env and .secret files from plugin directory
  ionos.wordpress.load_env "$(dirname $PACKAGE_JSON)"

  PACKAGE_NAME=$(jq -r '.name' $PACKAGE_JSON)
  PACKAGE_VERSION=$(jq -r '.version' $PACKAGE_JSON)
  DOCKER_IMAGE_NAME="$(echo $PACKAGE_NAME | sed -r 's/@//g')"

  # if DOCKER_USERNAME is not set take the package scope (example: "@foo/bar" package user is "foo")
  DOCKER_USERNAME="${DOCKER_USERNAME:-${DOCKER_IMAGE_NAME%/*}}"
  # if DOCKER_REPOSITORY is not set take the package repository (example: "@foo/bar" package repository is "bar")
  DOCKER_REPOSITORY="${DOCKER_REPOSITORY:-${DOCKER_IMAGE_NAME#*/}}"
  DOCKER_IMAGE_NAME="$DOCKER_USERNAME/$DOCKER_REPOSITORY"

  ionos.wordpress.log_warn "remove local docker image $DOCKER_IMAGE_NAME:$PACKAGE_VERSION if exists"

  # remove all docker containers using the image
  docker ps -a -q --filter ancestor=$DOCKER_IMAGE_NAME:$PACKAGE_VERSION | xargs -r docker rm -f
  # delete docker image
  docker image rm -f $DOCKER_IMAGE_NAME:$PACKAGE_VERSION 2>/dev/null ||:
)
done
# remove docker images generated by workspace packages

# ENDMARK:

git clean $GIT_CLEAN_OPTS \
  -ff \
  -e '!/*.code-workspace' \
  -e '!/*.secrets' \
  -e '!/*.env.local' \
  -e '!/.wp-env.override.json'

