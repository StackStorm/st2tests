#!/bin/bash

STACKSTORM_REPO=$1

DATE=`date +%s`
OUTPUT=/tmp/prep-st2-output-$DATE

if [[ ! -d "$STACKSTORM_REPO" ]]
then
  echo "ERROR: repo ${STACKSTORM_REPO} doesn't exist."
  exit 1
fi

cd ${STACKSTORM_REPO}
OUT=`make requirements > ${OUTPUT}`
if [[ $? != 0 ]]
then
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 2
fi

OUT=`source ./virtualenv/bin/activate > ${OUTPUT}`
if [[ $? != 0 ]]
then
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 3
fi

cd st2client
OUT=`sudo python setup.py develop > ${OUTPUT}`
if [[ $? != 0 ]]
then
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 4
fi

rm ${OUTPUT}
echo "${STACKSTORM_REPO} - stackstorm prep complete"
exit 0
