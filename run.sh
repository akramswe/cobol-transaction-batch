#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p bin output
cobc -x -free -Wall -o bin/batch_checker src/batch_checker.cbl
./bin/batch_checker
