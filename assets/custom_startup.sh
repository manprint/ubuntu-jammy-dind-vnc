#!/bin/bash

/usr/bin/desktop_ready && sudo service ssh start && sudo service docker start && sudo service cron start
