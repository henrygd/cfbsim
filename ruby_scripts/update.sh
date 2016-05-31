#! /bin/bash
# can be set as cronjob
# update shebangs in files below to current ruby location
# must run inside this directory - will take a few min

./grab_teams.rb
./grab_national_stats.rb
./save_ratings.rb