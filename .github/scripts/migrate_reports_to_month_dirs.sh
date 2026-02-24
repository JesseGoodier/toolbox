#!/usr/bin/env bash
set -euo pipefail

TARGETS=("$@")
if [ ${#TARGETS[@]} -eq 0 ]; then
  TARGETS=("build-history" "cve-audit")
fi

for ROOT in "${TARGETS[@]}"; do
  [ -d "$ROOT" ] || continue

  for YEAR_DIR in "$ROOT"/*; do
    [ -d "$YEAR_DIR" ] || continue
    YEAR_NAME=$(basename "$YEAR_DIR")
    [[ "$YEAR_NAME" =~ ^[0-9]{4}$ ]] || continue

    for REPORT in "$YEAR_DIR"/*.md; do
      [ -f "$REPORT" ] || continue
      REPORT_NAME=$(basename "$REPORT")
      [[ "$REPORT_NAME" =~ ^([0-9]{2})-([0-9]{2})\.md$ ]] || continue

      MONTH="${BASH_REMATCH[1]}"
      mkdir -p "$YEAR_DIR/$MONTH"
      mv "$REPORT" "$YEAR_DIR/$MONTH/$REPORT_NAME"
    done
  done
done
