#!/usr/bin/env bash
#set -euo pipefail
declare -a needs_dco
#set -x
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

if [[ ${#needs_dco[@]} -ne 0 ]]; then
#              author=$(jq -r ".issue.user.login" "${GITHUB_EVENT_PATH}")
 read -r -d '' data <<EOM
          Hyperledger Fabric requires all commits to contain a DCO signoff. The following
          commits do not contain a proper signoff:

          $(printf "* %s\n" $(echo ${needs_dco[*]} | tr -s ' ' '\n'}))

          You cannot add a DCO signoff using the GitHub UI. You must check out the branch
          locally and signoff your commits using the CLI.

          You can signoff your commits by issuing the following commands:

          ``git clone https://github.com/${author}/fabric``
#          `git checkout ${GITHUB_HEAD_REF}`
#          `git rebase --signoff HEAD~${#needs_dco[@]}`
#          `git push origin ${GITHUB_HEAD_REF} -f`
EOM
echo $data
  fi
