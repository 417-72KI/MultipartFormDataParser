#!/bin/zsh

if ! type "github-release" > /dev/null; then
    echo '`github-release` not found. Install'
    go get github.com/aktau/github-release
fi

cd $(git rev-parse --show-toplevel)

PACKAGE_NAME='MultipartFormDataParser'

CURRENT_BRANCH=$(git branch | grep '* main')
if [ "${CURRENT_BRANCH}" = '' ]; then
    echo '[Error] this script must be run in main branch.'
    exit 1
fi

if [ "`git diff --name-only`" != '' ]; then
    echo '[Error] There are some local changes.'
    exit 1
fi

TAG=$(cat Sources/MultipartFormDataParser/Info.swift | grep version | awk '{ print $NF }' | sed -E 's/\"(.*)\"/\1/')

# Validate
README_VERSION=$(cat README.md | grep '.package(url: ' | awk '{ print $NF }' | sed -E 's/\"(.*)\"\)?/\1/')
if [ "${TAG}" != "${README_VERSION}" ]; then
    echo '[Error] README.md not updated. Match version in installation.'
    exit 1
fi

if [ "$(git fetch --tags && git tag | grep "${TAG}")" != '' ]; then
    echo "[Error] '${TAG}' tag already exists."
    exit 1
fi

# Generate xcodeproj
swift package generate-xcodeproj

git add ${PACKAGE_NAME}.xcodeproj
git commit -m 'Update xcodeproj'
git push origin

# TAG
git tag ${TAG}
git push origin ${TAG}

# GitHub Release
github-release release \
    --user 417-72KI \
    --repo ${PACKAGE_NAME} \
    --tag ${TAG}
