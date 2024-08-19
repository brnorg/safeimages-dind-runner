#!/bin/bash

# Check if the script is running for an organization or a repository
if [ -n "$ORG" ]; then
    # Organization scenario
    export ORGANIZATION=$ORG
    export ACCESS_TOKEN=$TOKEN
    export TAG_RUNNER=$TAG
    export $RUNNER_NAME=$NAME

    echo "ORGANIZATION ${ORGANIZATION}"
    echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

    REG_TOKEN=$(curl -k -L -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)

    echo "REG_TOKEN ${REG_TOKEN}"

    cd /home/runner/actions-runner

    ./config.sh --url https://github.com/${ORGANIZATION} --name ${RUNNER_NAME} --token ${REG_TOKEN} --labels ${TAG_RUNNER}
else
    # Repository scenario
    REPOSITORY=$REPO
    ACCESS_TOKEN=$TOKEN
    TAG_RUNNER=$TAG
    RUNNER_NAME=$NAME

    echo "REPO ${REPOSITORY}"
    echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

    REG_TOKEN=$(curl -k -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)

    cd /home/runner/actions-runner

    ./config.sh --url https://github.com/${REPOSITORY} --name ${RUNNER_NAME} --token ${REG_TOKEN} --labels ${TAG_RUNNER}
fi

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
