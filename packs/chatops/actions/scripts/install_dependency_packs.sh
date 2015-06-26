#!/bin/bash

STACKSTORM_REPO=$1

DATE=`date +%s`
OUTPUT=/tmp/install-dep-st2-output-$DATE

if [[ ! -d "$STACKSTORM_REPO" ]]
then
  echo "ERROR: repo ${STACKSTORM_REPO} doesn't exist."
  exit 1
fi

cd ${STACKSTORM_REPO}
OUT=`source ./virtualenv/bin/activate > ${OUTPUT}`
if [[ $? != 0 ]]
then
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 2
fi

st2 run packs.install repo_url=https://github.com/StackStorm/st2-slack.git packs=st2-slack
cp /home/stanley/slack_pack_config.yaml /opt/stackstorm/packs/st2-slack/config.yaml

rm ${OUTPUT}
echo "${STACKSTORM_REPO} - stackstorm prep complete"
exit 0
