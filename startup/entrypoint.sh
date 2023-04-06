#!/bin/bash
export USER=headless

/dockerstartup/vnc_startup.sh

tail -F /tmp/none
