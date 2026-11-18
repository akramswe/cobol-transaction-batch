#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
./run.sh >/dev/null
report="output/batch_report.txt"
grep -Fq "Processed: 9" "$report"
grep -Fq "Accepted: 5" "$report"
grep -Fq "Rejected: 4" "$report"
grep -Fq "Credits: 1549" "$report"
grep -Fq "Debits: 2399" "$report"
grep -Fq "Net movement: DEBIT 850" "$report"
grep -Fq "REJECTED: ZERO AMOUNT" "$report"
grep -Fq "REJECTED: INVALID TYPE" "$report"
grep -Fq "REJECTED: INVALID AMOUNT" "$report"
grep -Fq "REJECTED: DUPLICATE ID" "$report"
echo "All checks passed."
