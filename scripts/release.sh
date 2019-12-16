#!/bin/zsh

if ! type "github-release" > /dev/null; then
    echo '`github-release` not found. Install'
    go get github.com/aktau/github-release
fi

cd $(git rev-parse --show-toplevel)

PACKAGE_NAME='MultipartFormDataParser'

CURRENT_BRANCH=$(git branch | grep '* master')
if [ "${CURRENT_BRANCH}" = '' ]; then
    echo '[Error] this script must be run in master branch.'
    exit 1
fi

# Generate xcodeproj
swift package generate-xcodeproj

git add -f ${PACKAGE_NAME}.xcodeproj
git commit -m 'Update xcodeproj'
git push origin

# TAG
TAG=$(cat Sources/MultipartFormDataParser/Info.swift | grep version | awk '{ print $NF }' | sed -E 's/\"(.*)\"/\1/')
git tag ${TAG}
git push origin ${TAG}

# GitHub Release
github-release release \
    --user 417-72KI \
    --repo ${PACKAGE_NAME} \
    --tag ${TAG}
