#!/bin/bash
export CINCH_SCRIPT_PID=$$
/usr/bin/env ruby ./bot.rb
./auto_restart.sh
