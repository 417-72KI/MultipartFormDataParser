#!/bin/zsh

set -eu

APPLICATION_INFO_FILE='Sources/MultipartFormDataParser/Info.swift'

if ! type "github-release" > /dev/null; then
    echo '`github-release` not found. Install'
    go get github.com/github-release/github-release
fi

cd $(git rev-parse --show-toplevel)

PACKAGE_NAME='MultipartFormDataParser'

if [ `git symbolic-ref --short HEAD` != 'master' ]; then
    echo '\e[31mRelease is enabled only in master.\e[m'
    exit 1
fi

if [ "$(git status -s | grep "${APPLICATION_INFO_FILE}")" = '' ]; then
    echo "\e[31m${APPLICATION_INFO_FILE} is not modified.\e[m"
    exit 1
fi

if [ "$(git status -s | grep .swift | grep -v ${APPLICATION_INFO_FILE})" != '' ]; then
    echo "\e[31mUnexpected added/modified/deleted file.\e[m"
    exit 1
fi

# TAG
TAG=$(cat "${APPLICATION_INFO_FILE}" | grep version | awk '{ print $NF }' | sed -E 's/\"(.*)\"/\1/')
if [ "$(git tag | grep ${TAG})" != '' ]; then
    echo "\e[31mTag: '${TAG}' already exists.\e[m"
    exit 1
fi

git commit -m "Bump version to ${TAG}" "${APPLICATION_INFO_FILE}"
git tag ${TAG}
git push origin ${TAG}

# GitHub Release
github-release release \
    --user 417-72KI \
    --repo ${PACKAGE_NAME} \
    --tag ${TAG}
