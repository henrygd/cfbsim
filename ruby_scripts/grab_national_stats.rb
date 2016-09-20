#! /home/hank/.rbenv/shims/ruby

# save national stats pages from cfbstats.com / footballoutsiders
require 'open-uri'

national_stats = {
  :pass_defense => 'http://www.cfbstats.com/2016/leader/national/team/defense/split01/category02/sort01.html',
  :pass_offense => 'http://www.cfbstats.com/2016/leader/national/team/offense/split01/category02/sort01.html',
  :penalties => 'http://www.cfbstats.com/2016/leader/national/team/offense/split01/category14/sort01.html',
  :run_defense => 'http://www.cfbstats.com/2016/leader/national/team/defense/split01/category01/sort01.html',
  :run_offense => 'http://www.cfbstats.com/2016/leader/national/team/offense/split01/category01/sort01.html',
  :sacks => 'http://www.cfbstats.com/2016/leader/national/team/offense/split01/category20/sort01.html',
  :sacks_allowed => 'http://www.cfbstats.com/2016/leader/national/team/defense/split01/category20/sort01.html',
  :blocked_kicks => 'http://www.cfbstats.com/2016/leader/national/team/offense/split01/category24/sort01.html',
  :turnovers => 'http://www.cfbstats.com/2016/leader/national/team/offense/split01/category12/sort01.html'
}

national_stats.each do |k, v|
  web_page = open(v)
  open("./national_stats/#{k}.html", 'w') do |f|
    f << web_page.read
  end
  puts "Saved #{k} page succesfully!"
  sleep 2
end