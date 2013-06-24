#!/bin/bash
export CINCH_SCRIPT_PID=$$
/usr/bin/env ruby ./bot.rb
git pull
bundle install
./auto_restart.sh
