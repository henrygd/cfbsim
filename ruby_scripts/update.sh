#! /bin/bash
# can be set as cronjob
# update shebangs in files below to current ruby location & chmod 774
# must run inside this directory - will take a few min
# will break if cfbstats.com or football outsiders change current site format

./grab_teams.rb
./grab_national_stats.rb
./save_ratings.rb