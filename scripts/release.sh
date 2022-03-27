#!/bin/zsh

set -o pipefail

cd $(git rev-parse --show-toplevel)

PACKAGE_NAME='MultipartFormDataParser'

CURRENT_BRANCH=$(git branch | grep '* release' || true)
if [ "${CURRENT_BRANCH}" = '' ]; then
    echo '\e[31m[Error] this script must be run in release branch.\e[m'
    exit 1
fi

if [ "`git diff --name-only`" != '' ]; then
    echo '\e[31m[Error] There are some local changes.\e[m'
    exit 1
fi

TAG=$(cat Sources/MultipartFormDataParser/Info.swift | grep version | awk '{ print $NF }' | sed -E 's/\"(.*)\"/\1/')

# Validate
README_VERSION=$(cat README.md | grep '.package(url: ' | awk '{ print $NF }' | sed -E 's/\"(.*)\"\)?/\1/')
if [ "${TAG}" != "${README_VERSION}" ]; then
    echo '\e[31m[Error] README.md not updated. Match version in installation.\e[m'
    exit 1
fi

if [ "$(git fetch --tags && git tag | grep "${TAG}")" != '' ]; then
    echo "\e[31m[Error] '${TAG}' tag already exists.\e[m"
    exit 1
fi

IS_RELEASE=$(cat Package.swift | grep 'let isRelease' | awk '{ print $NF }')
if [ "$IS_RELEASE" != 'true' ]; then
    echo '\e[31m[Error] `isRelease` flag in Package.swift is false.\e[m'
    exit 1
fi

# Generate xcodeproj
swift package generate-xcodeproj

# commit
if [ "$(git status -s | grep "${PACKAGE_NAME}.xcodeproj/project.pbxproj")" != '' ]; then
    git config advice.addIgnoredFile false
    git config user.name github-actions
    git config user.email github-actions@github.com
    git commit -m 'Update xcodeproj' ${PACKAGE_NAME}.xcodeproj/project.pbxproj
    git push origin
else
    echo '\e[32m[INFO] No update on xcodeproj.\e[m'
fi

# Draft release
EXISTING_RELEASE=$(gh release view --json isDraft,url ${TAG} 2>/dev/null)

if [ "$EXISTING_RELEASE" != '' ]; then
    if [ "$(echo $EXISTING_RELEASE | jq '.isDraft')" = 'true' ]; then
        UPDATE_URL=$(echo $EXISTING_RELEASE | jq -r '.url')
        curl -X PATCH \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -d "{\"tag_name\": \"${TAG}\", \"target_commitish\": \"main\", \"name\": \"${TAG}\", \"draft\": true}" \
        "$UPDATE_URL"
    else
        echo "\e[31m[Error] ${TAG} already exists.\e[m"
        exit 1
    fi
else
    gh release create ${TAG} --target main --title ${TAG} --generate-notes -d
fi
