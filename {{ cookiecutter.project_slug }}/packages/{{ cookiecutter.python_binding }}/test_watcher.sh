#!/usr/bin/env bash
set -euo pipefail
cmake --preset gcc-debug
cmake --build --preset build-gcc-debug --target tests
ctest --test-dir build/gcc-debug --output-on-failure
