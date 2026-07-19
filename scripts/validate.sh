#!/bin/zsh
set -euo pipefail

PROJECT_DIR="${0:A:h:h}"
VALIDATOR="$PROJECT_DIR/.build/quickkey-validate"

mkdir -p "${VALIDATOR:h}"
swiftc -parse-as-library \
    "$PROJECT_DIR/AppSources/QuickKey/Models.swift" \
    "$PROJECT_DIR/Tests/validate.swift" \
    -o "$VALIDATOR"
"$VALIDATOR"
