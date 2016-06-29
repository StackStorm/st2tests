#!/bin/bash
# This is for debugging purpose only

export ROBOT_SYSLOG_FILE=/tmp/robotfm.log
export ROBOT_SYSLOG_LEVEL=DEBUG

robot --name BVT robotfm_tests/

