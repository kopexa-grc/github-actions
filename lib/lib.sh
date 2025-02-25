#!/bin/bash

export GOPRIVATE='github.com/kopexa-grc/*'

git config --global url."https://${GIT_CI_BOT_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/"

# GITHUB_REF in a PR points to refs/remotes/pulls/<number>/merge
if [[ $GITHUB_EVENT_NAME == 'pull_request' ]]; then
    GIT_REF=refs/heads/${GITHUB_HEAD_REF}
else
    GIT_REF=${GITHUB_REF}
fi

export CI_COMMIT_REF_SLUG=$(echo ${GIT_REF:11} | sed -r 's/[^a-zA-Z0-9]+/-/g' | sed -r 's/^-+\|-+$//g' | tr '[:upper:]' '[:lower:]')
export CI_COMMIT_SHORT_SHA=$(echo ${GITHUB_SHA} | head -zc 8)

# Defaults to  mk8s projects if projects are not set
export HARBOR_DEV_PROJECT=${HARBOR_DEV_PROJECT:-jk-dev}
export HARBOR_PROD_PROJECT=${HARBOR_PROD_PROJECT:-jk}
export HARBOR_REGISTRY="harbor.infra.cluster.kopexa.com"

# default to dev project
export HARBOR_PROJECT="${HARBOR_DEV_PROJECT}"
export HARBOR_USERNAME="${HARBOR_DEV_PROJECT_USER}"
export HARBOR_PASSWORD="${HARBOR_DEV_PROJECT_PASS}"

export CI_COMMIT_TAG=""
if [[ "${GIT_REF}" == refs/tags/* ]]
then
    export CI_COMMIT_TAG="${GIT_REF##refs/tags/}"
fi

cd "${GITHUB_WORKSPACE}"
git fetch --tags --quiet --force
cd -

if [[ -n "${CI_COMMIT_TAG}" ]]
then
    export VERSION="${CI_COMMIT_TAG}"
    # Point to harbor prod project
    export HARBOR_PROJECT="${HARBOR_PROD_PROJECT}"
    export HARBOR_USERNAME=${HARBOR_PROD_PROJECT_USER}
    export HARBOR_PASSWORD=${HARBOR_PROD_PROJECT_PASS}
elif [[ "${CI_COMMIT_REF_SLUG}" == 'master' || "${CI_COMMIT_REF_SLUG}" == 'main' || "${CI_COMMIT_REF_SLUG:0:8}" == 'release-' || $FORCE_SEMVER == 'true' ]]
then
    if [[ ${STABLE_DEFAULT_BRANCH-} == "true" ]]; then
        # sometimes we want to push images built from the default branch to production
        export HARBOR_PROJECT="${HARBOR_PROD_PROJECT}"
        export HARBOR_USERNAME=${HARBOR_PROD_PROJECT_USER}
        export HARBOR_PASSWORD=${HARBOR_PROD_PROJECT_PASS}
    fi
    cd "${GITHUB_WORKSPACE}"
    git fetch --tags --quiet --depth=50
    export VERSION="$(git describe --always --tags --exclude='*/*')" # exclude e.g. Go submodules or legacy chart tags
    cd -
else
    export VERSION="${CI_COMMIT_REF_SLUG}-${CI_COMMIT_SHORT_SHA}"
fi

# Export legacy variables to prevent breaking docker push
export DOCKER_REGISTRY=$HARBOR_REGISTRY
export DOCKER_NAMESPACE=$HARBOR_PROJECT

if [[ -n "${HARBOR_PASSWORD}" && -n "${HARBOR_USERNAME}" ]]
then
    logout() {
        docker logout "$HARBOR_REGISTRY"
        helm registry logout "$HARBOR_REGISTRY"
    }

    trap logout EXIT

    docker login --username "${HARBOR_USERNAME}" --password "${HARBOR_PASSWORD}" "${HARBOR_REGISTRY}"
    helm registry login --username "${HARBOR_USERNAME}" --password "${HARBOR_PASSWORD}" "${HARBOR_REGISTRY}"
fi
