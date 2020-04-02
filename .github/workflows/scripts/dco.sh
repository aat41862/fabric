#!/usr/bin/env bash

needs_dco=("https://git.com" "https://gith2.com")
cat <<EOF > data.json
{"body":"Hyperledger Fabric requires all commits to contain a DCO signoff. The following\ncommits do not contain a proper signoff:\n\n$(printf '%s\\n' $(echo ${needs_dco[*]} | tr -s ' ' '\n'}))\n\nYou cannot add a DCO signoff using the GitHub UI. You must check out the branch\nlocally and signoff your commits using the CLI.\n\nIf you haven't cloned your Fabric fork yet, issue the following command:\n\n\`git clone https://github.com/${author}/fabric\`\n\nYou can signoff your commits by issuing the following commands:\n\`git checkout ${GITHUB_HEAD_REF}\`\n\`git rebase --signoff HEAD~${#needs_dco[@]}\`\n\`git push origin ${GITHUB_HEAD_REF} -f\`"}
EOF