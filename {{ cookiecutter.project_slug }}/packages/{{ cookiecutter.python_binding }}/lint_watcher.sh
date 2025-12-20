#!/usr/bin/env bash
set -euo pipefail
cmake --preset gcc-debug
cmake --build --preset build-gcc-debug --target tests
clang-tidy -p build/gcc-debug $(git ls-files '*.cpp' '*.h')
