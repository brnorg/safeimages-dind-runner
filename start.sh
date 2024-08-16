#!/bin/bash

export ORGANIZATION=$ORG
export ACCESS_TOKEN=$TOKEN
export TAG_RUNNER=$TAG

echo "ORGANIZATION ${ORGANIZATION}"
echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

REG_TOKEN=$(curl -k -L -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)

echo "REG_TOKEN ${REG_TOKEN}"

cd /home/runner/actions-runner

./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN} --labels ${TAG_RUNNER}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!