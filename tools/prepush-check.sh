#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> Regenerating documentation"
Rscript --vanilla -e 'roxygen2::roxygenise(".")'

echo "==> Building source tarball"
rm -f bsvarPost_*.tar.gz
R CMD build .

TARBALL="$(ls -1t bsvarPost_*.tar.gz | head -n1)"

echo "==> Running R CMD check"
_R_CHECK_FORCE_SUGGESTS_=false R CMD check --as-cran "$TARBALL"

echo "==> Done"
echo "Next:"
echo "  1. Run focused tests for the code you changed"
echo "  2. Review git diff"
echo "  3. Push and wait for GitHub R-CMD-check to go green"
