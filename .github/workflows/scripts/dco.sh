#!/usr/bin/env bash
set -euo pipefail
declare -a needs_dco
set -x
#          pr_number=$(jq .number "${GITHUB_EVENT_PATH}")
commits=$(curl -u btl5037: https://api.github.com/repos/btl5037/fabric/pulls/24/commits)
index=0
IFS=$'\n' read -rd '' -a messages <<<"$(echo ${commits} | jq -c '.[].commit.message')" || true

for message in "${messages[@]}"; do
	if [[ ${message} =~ "Signed-off-by" ]]; then
		sha=$(echo ${commits} | jq -c ".[${index}].html_url" | tr -d '"')
		needs_dco+=("${sha}")
	fi
	index=$((index + 1))
done
