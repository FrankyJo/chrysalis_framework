#!/usr/bin/env bash
# Checks whether the Playwright MCP server is configured for this project.
# Exit codes:
#   0 - configured AND connected
#   2 - configured but NOT connected (needs auth / failed / pending approval)
#   1 - not configured at all, or `claude` CLI not found
#
# Usage: ./check_playwright.sh
# Prints the matching line from `claude mcp list` (if any) to stdout for context.

if ! command -v claude >/dev/null 2>&1; then
  echo "claude CLI not found on PATH"
  exit 1
fi

STATUS=$(claude mcp list 2>/dev/null | grep -i playwright)

if [ -z "$STATUS" ]; then
  echo "Playwright MCP server not configured"
  exit 1
fi

echo "$STATUS"

if echo "$STATUS" | grep -qi "connected"; then
  exit 0
else
  exit 2
fi
