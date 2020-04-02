#! /bin/bash
#

#commenter=$(jq -r ".comment.user.login" "${GITHUB_EVENT_PATH}")
#org=$(jq -r ".repository.owner.login" "${GITHUB_EVENT_PATH}")
#pr_number=$(jq -r ".issue.number" "${GITHUB_EVENT_PATH}")
#project=$(jq -r ".repository.name" "${GITHUB_EVENT_PATH}")
#repo=$(jq -r ".repository.full_name" "${GITHUB_EVENT_PATH}")
#
#comment_url="https://api.github.com/repos/${repo}/issues/${pr_number}/comments"
#pr_url="https://api.github.com/repos/${repo}/pulls/${pr_number}"
#
#pr_resp=$(curl "${pr_url}")
#body=$(echo "${pr_resp}" | jq -r .body)
#
#if [[ ${commenter} == "${author}" ]] || [[ ${isReviewer} -ne 0 ]]; then
#	sha=$(echo "${pr_resp}" | jq -r ".head.sha")
#
#	az extension add --name azure-devops
#	echo ${AZP_TOKEN} | az devops login --organization "https://dev.azure.com/${org}"
#
#	runs=$(az pipelines build list --project ${project} | jq -c ".[] | select(.sourceVersion | contains(\"${sha}\"))" | jq -r .status | grep -v completed | wc -l)
#	if [[ $runs -eq 0 ]]; then
#		az pipelines build queue --branch refs/pull/${pr_number}/merge --commit-id ${sha} --project ${project} --definition-name Pull-Request
#		curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d '{"body": "AZP build triggered!"}' "${comment_url}"
#	else
#		curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d '{"body": "AZP build already running!"}' "${comment_url}"
#	fi
#else
#	curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d '{"body": "You are not authorized to trigger builds for this pull request!"}' "${comment_url}"
#fi

declare -a needs_dco
commits=$(curl -u btl5037:dccf834a810288e7c1605ed3c5741127dad1f85d https://api.github.com/repos/hyperledger/fabric/pulls/928/commits)
index=0
IFS=$'\n' read -rd '' -a messages <<<"$(echo ${commits} | jq -c '.[].commit.message')"

for message in "${messages[@]}"; do
   if [[ "${message}" =~ "Signed-off-by" ]]; then
        sha=$(echo ${commits} | jq -c ".[${index}].html_url" | tr -d '"')
        needs_dco+=("${sha}")
   fi
   index=$((${index} + 1))
done
if [[ ${#needs_dco[@]} -ne 0 ]]; then
    author=$(jq -r ".issue.user.login" "${GITHUB_EVENT_PATH}")
    cat <<EOF
Hyperledger Fabric requires all commits to contain a DCO signoff. The following
commits do not contain a proper signoff:

$(printf "* %s\n" $(echo ${needs_dco[*]} | tr -s ' ' '\n'}))

You cannot add a DCO signoff using the GitHub UI. You must check out the branch
locally and signoff your commits using the CLI.

You can signoff your commits by issuing the following commands:

#`git clone https://github.com/${author}/fabric`
#`git checkout ${GITHUB_HEAD_REF}`
#`git rebase --signoff HEAD~${#needs_dco[@]}`
#`git push origin ${GITHUB_HEAD_REF} -f`
EOF
fi
