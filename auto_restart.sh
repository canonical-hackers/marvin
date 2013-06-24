#!/bin/sh
/usr/bin/env ruby ./bot.rb
git pull
bundle install
./auto_restart.sh
