#!/bin/zsh

set -eu

PROJECT_NAME=$1
TAG=$2

DEBUG=0

if ! type "gh" > /dev/null; then
    echo '\e[33m`gh` not found. Install\e[m'
    brew install gh
fi

cd $(git rev-parse --show-toplevel)

if [ `git symbolic-ref --short HEAD` != 'main' ]; then
    echo '\e[33mRelease job is enabled only in main. Run in debug mode\e[m'
    DEBUG=1
fi

echo "${TAG}" | grep -wE '([0-9]+)\.([0-9]+)\.([0-9]+)' > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Invalid version format: \"${TAG}\""
    exit 1
fi

LOCAL_CHANGES=`git diff --name-only HEAD`
if [ "$LOCAL_CHANGES" = 'Makefile' ]; then
    MAKEFILE_DIFF="$(git diff -U0 Makefile | grep '^[+-]' | grep -Ev '^(--- a/|\+\+\+ b/)')"
    if [ "$(echo $MAKEFILE_DIFF | grep -Ev '^[+-]ver = [0-9]*\.[0-9]*\.[0-9]*$')" != '' ]; then
        echo '\e[31m[Error] There are some local changes.\e[m'
        exit 1
    fi
elif [ "$LOCAL_CHANGES" != '' ]; then
    echo '\e[31m[Error] There are some local changes.\e[m'
    exit 1
fi

# Validate
if [ "$(git fetch --tags && git tag | grep "${TAG}")" != '' ]; then
    echo "\e[31m[Error] '${TAG}' tag already exists.\e[m"
    exit 1
fi

sed -i '' -E "s/(\.package\(url: \".*${PROJECT_NAME}\.git\", from: \").*(\"\),?)/\1${TAG}\2/g" README.md
sed -i '' -E "s/(let isDevelop = )(true|false)/\1false/" Package.swift

# Podspec
MAC_OS_VERSION="$(cat Package.swift | grep '.macOS(.v' | sed -E "s/ *\.macOS\(\.v([0-9_]*)\),?/\1/g" | sed -E "s/_/./g")"
if [[ "$MAC_OS_VERSION" != *"."* ]]; then
    MAC_OS_VERSION="${MAC_OS_VERSION}.0"
fi
IOS_VERSION="$(cat Package.swift | grep '.iOS(.v' | sed -E "s/ *\.iOS\(\.v([0-9_]*)\),?/\1/g" | sed -E "s/_/./g")"
if [[ "$IOS_VERSION" != *"."* ]]; then
    IOS_VERSION="${IOS_VERSION}.0"
fi
TV_OS_VERSION="$(cat Package.swift | grep '.tvOS(.v' | sed -E "s/ *\.tvOS\(\.v([0-9_]*)\),?/\1/g" | sed -E "s/_/./g")"
if [[ "$TV_OS_VERSION" != *"."* ]]; then
    TV_OS_VERSION="${TV_OS_VERSION}.0"
fi

sed -i '' -E "s/(spec\.version *= )\"([0-9]*\.[0-9]*(\.[0-9]*)?)\"/\1\"${TAG}\"/g" ${PROJECT_NAME}.podspec
sed -i '' -E "s/(spec\.osx\.deployment_target *= )\"([0-9]*\.[0-9]*(\.[0-9]*)?)\"/\1\"${MAC_OS_VERSION}\"/g" ${PROJECT_NAME}.podspec
sed -i '' -E "s/(spec\.ios\.deployment_target *= )\"([0-9]*\.[0-9]*(\.[0-9]*)?)\"/\1\"${IOS_VERSION}\"/g" ${PROJECT_NAME}.podspec
sed -i '' -E "s/(spec\.tvos\.deployment_target *= )\"([0-9]*\.[0-9]*(\.[0-9]*)?)\"/\1\"${TV_OS_VERSION}\"/g" ${PROJECT_NAME}.podspec

COMMIT_OPTION=''
if [ $DEBUG -ne 0 ]; then
    COMMIT_OPTION='--dry-run'
fi

git commit $COMMIT_OPTION -m "Bump version to ${TAG}" Package.swift Makefile README.md "${PROJECT_NAME}.podspec"
if [ $DEBUG -eq 0 ]; then
    git push origin main
    gh release create ${TAG} --target main --title ${TAG} --generate-notes
fi

sed -i '' -E "s/(let isDevelop = )(true|false)/\1true/" Package.swift
git commit $COMMIT_OPTION -m 'switch develop flag to true' Package.swift
if [ $DEBUG -eq 0 ]; then
    git push origin main
fi
