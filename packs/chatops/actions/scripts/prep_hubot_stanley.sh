#!/bin/bash

NPM=`which npm`
HUBOT_STACKSTORM_REPO=$1
HUBOT_STANLEY_REPO=$2

DATE=`date +%s`
OUTPUT=/tmp/npm-link-output-$DATE

if [[ ! -d "$HUBOT_STACKSTORM_REPO" ]]
then
  echo "ERROR: repo ${HUBOT_STACKSTORM_REPO} doesn't exist."
  exit 1
fi

if [[ ! -d "$HUBOT_STANLEY_REPO" ]]
then
  echo "ERROR: repo ${HUBOT_STANLEY_REPO} doesn't exist."
  exit 1
fi

cd ${HUBOT_STACKSTORM_REPO}
OUT=`sudo npm link > ${OUTPUT}`
if [[ $? != 0 ]]
then
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 2
fi

cd ${HUBOT_STANLEY_REPO}
out=`sudo npm link hubot-stackstorm > ${OUTPUT}`
if [[ $? != 0 ]]
then
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 3
fi

out=`cp /home/stanley/chatops_itests_hubot_start.sh ${HUBOT_STANLEY_REPO} > OUTPUT`
if [[ $? != 0 ]]
then
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 4
fi

rm ${OUTPUT}
echo "${HUBOT_STACKSTORM_REPO} - prepared"
exit 0
