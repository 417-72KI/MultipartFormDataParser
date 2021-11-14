#!/bin/zsh

set -eo pipefail

cd $(git rev-parse --show-toplevel)

PACKAGE_NAME='MultipartFormDataParser'

CURRENT_BRANCH=$(git branch | grep '* release')
if [ "${CURRENT_BRANCH}" = '' ]; then
    echo '[Error] this script must be run in release branch.'
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

# commit
git config advice.addIgnoredFile false
git config user.name github-actions
git config user.email github-actions@github.com
git add -f ${PACKAGE_NAME}.xcodeproj/project.pbxproj
git commit -m 'Update xcodeproj'
git push origin

# Draft release
curl -X POST \
-H "Authorization: token ${GITHUB_TOKEN}" \
-d "{\"tag_name\": \"${TAG}\", \"target_commitish\": \"main\", \"name\": \"${TAG}\", \"draft\": true}" \
https://api.github.com/repos/417-72KI/MultipartFormDataParser/releases