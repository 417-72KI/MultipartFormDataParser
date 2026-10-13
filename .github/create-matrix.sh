#!/bin/bash

set -euo pipefail

while getopts "f:" opt; do
  case "$opt" in
    f) FILE="$OPTARG" ;;
    \?) exit 1 ;;
  esac
done
shift $((OPTIND - 1))

matrix_file="${FILE:-$(git rev-parse --show-toplevel)/.github/matrix.yml}"
mode=$(echo "${1:-macOS}" | tr 'A-Z' 'a-z')

if [ "$mode" = "macos" ]; then
  yq -o=json -I=0 '[
    .macos_runners
    | to_entries[] as $runner
    | $runner.value.xcode
    | to_entries[] as $xcode
    | $xcode.value.destination[]
    | {
        "runner": $runner.key,
        "xcode": $xcode.key,
        "destination": .
      }
  ]' "$matrix_file"
elif [ "$mode" = "linux" ]; then
  yq -o=json -I=0 '.linux_runner.swift_versions' "$matrix_file"
else
  echo "Unsupported mode: $mode" >&2
  exit 1
fi
