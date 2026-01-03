#!/usr/bin/env bash
set -euo pipefail

# Simple localization sanity check:
# 1. Ensure both en.lproj and zh-Hans.lproj exist
# 2. Ensure they contain the same set of keys (order not important)
# 3. Report any missing keys per language
# 4. Fail if differences are found

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EN_FILE="$ROOT_DIR/Resources/en.lproj/Localizable.strings"
ZH_FILE="$ROOT_DIR/Resources/zh-Hans.lproj/Localizable.strings"

if [[ ! -f "$EN_FILE" || ! -f "$ZH_FILE" ]]; then
  echo "❌ Missing localization files." >&2
  exit 1
fi

# Function to extract keys, ignoring comments and blank lines
extract_keys() {
  sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//;' "$1" | \
  grep -v -E '^/\*' | \
  grep -v -E '^$' | \
  sed -E 's/"([^"\\]|\\.)*"[[:space:]]*=[[:space:]]*".*";/\1\t&/' | \
  cut -f1 | \
  grep -E '^[a-zA-Z0-9_.]+' | \
  sort -u
}

en_tmp_keys=$(mktemp)
zh_tmp_keys=$(mktemp)
extract_keys "$EN_FILE" > "$en_tmp_keys"
extract_keys "$ZH_FILE" > "$zh_tmp_keys"

EN_KEYS=()
while IFS= read -r line; do EN_KEYS+=("$line"); done < "$en_tmp_keys"
ZH_KEYS=()
while IFS= read -r line; do ZH_KEYS+=("$line"); done < "$zh_tmp_keys"

en_tmp=$(mktemp)
zh_tmp=$(mktemp)
printf '%s\n' "${EN_KEYS[@]}" > "$en_tmp"
printf '%s\n' "${ZH_KEYS[@]}" > "$zh_tmp"

missing_in_zh=$(grep -F -x -v -f "$zh_tmp" "$en_tmp" || true)
missing_in_en=$(grep -F -x -v -f "$en_tmp" "$zh_tmp" || true)

status=0
if [[ -n "$missing_in_zh" ]]; then
  echo "❌ Keys missing in zh-Hans:" >&2
  echo "$missing_in_zh" >&2
  status=1
fi
if [[ -n "$missing_in_en" ]]; then
  echo "❌ Keys missing in en:" >&2
  echo "$missing_in_en" >&2
  status=1
fi

if [[ $status -eq 0 ]]; then
  echo "✅ Localization sanity check passed. Key counts: en=${#EN_KEYS[@]}, zh-Hans=${#ZH_KEYS[@]}" 
else
  echo "Total en keys: ${#EN_KEYS[@]}, zh-Hans keys: ${#ZH_KEYS[@]}" >&2
fi

rm -f "$en_tmp" "$zh_tmp" "$en_tmp_keys" "$zh_tmp_keys"
exit $status
