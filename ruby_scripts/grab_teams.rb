#! /home/hank/.rbenv/shims/ruby
# save team stats pages from cfbstats.com

require 'open-uri'

teams = {:Cincinnati=>{:img=>"2132", :url=>140}, :Connecticut=>{:img=>"41", :url=>164}, :"East Carolina"=>{:img=>"151", :url=>196}, :Houston=>{:img=>"248", :url=>288}, :Memphis=>{:img=>"235", :url=>404}, :Navy=>{:img=>"2426", :url=>726}, :SMU=>{:img=>"2567", :url=>663}, :"South Florida"=>{:img=>"58", :url=>651}, :Temple=>{:img=>"218", :url=>690}, :Tulane=>{:img=>"2655", :url=>718}, :Tulsa=>{:img=>"202", :url=>719}, :UCF=>{:img=>"2116", :url=>128}, :"Boston College"=>{:img=>"103", :url=>67}, :Clemson=>{:img=>"228", :url=>147}, :Duke=>{:img=>"150", :url=>193}, :"Florida State"=>{:img=>"52", :url=>234}, :"Georgia Tech"=>{:img=>"59", :url=>255}, :Louisville=>{:img=>"97", :url=>367}, :"Miami (Florida)"=>{:img=>"2390", :url=>415}, :"North Carolina State"=>{:img=>"152", :url=>490}, :"North Carolina"=>{:img=>"153", :url=>457}, :Pittsburgh=>{:img=>"221", :url=>545}, :Syracuse=>{:img=>"183", :url=>688}, :Virginia=>{:img=>"258", :url=>746}, :"Virginia Tech"=>{:img=>"259", :url=>742}, :"Wake Forest"=>{:img=>"154", :url=>749}, :Baylor=>{:img=>"239", :url=>51}, :"Iowa State"=>{:img=>"66", :url=>311}, :Kansas=>{:img=>"2305", :url=>328}, :"Kansas State"=>{:img=>"2306", :url=>327}, :Oklahoma=>{:img=>"201", :url=>522}, :"Oklahoma State"=>{:img=>"197", :url=>521}, :TCU=>{:img=>"2628", :url=>698}, :Texas=>{:img=>"251", :url=>703}, :"Texas Tech"=>{:img=>"2641", :url=>700}, :"West Virginia"=>{:img=>"277", :url=>768}, :Illinois=>{:img=>"356", :url=>301}, :Indiana=>{:img=>"84", :url=>306}, :Iowa=>{:img=>"2294", :url=>312}, :Maryland=>{:img=>"120", :url=>392}, :Michigan=>{:img=>"130", :url=>418}, :"Michigan State"=>{:img=>"127", :url=>416}, :Minnesota=>{:img=>"135", :url=>428}, :Nebraska=>{:img=>"158", :url=>463}, :Northwestern=>{:img=>"77", :url=>509}, :"Ohio State"=>{:img=>"194", :url=>518}, :"Penn State"=>{:img=>"213", :url=>539}, :Purdue=>{:img=>"2509", :url=>559}, :Rutgers=>{:img=>"164", :url=>587}, :Wisconsin=>{:img=>"275", :url=>796}, :Charlotte=>{:img=>"2429", :url=>458}, :"Florida Atlantic"=>{:img=>"2226", :url=>229}, :"Florida International"=>{:img=>"2229", :url=>231}, :"Louisiana Tech"=>{:img=>"2348", :url=>366}, :Marshall=>{:img=>"276", :url=>388}, :"Middle Tennessee"=>{:img=>"2393", :url=>419}, :"North Texas"=>{:img=>"249", :url=>497}, :"Old Dominion"=>{:img=>"295", :url=>523}, :Rice=>{:img=>"242", :url=>574}, :"Southern Mississippi"=>{:img=>"2572", :url=>664}, :UTSA=>{:img=>"2636", :url=>706}, :UTEP=>{:img=>"2638", :url=>704}, :"Western Kentucky"=>{:img=>"98", :url=>772}, :Army=>{:img=>"349", :url=>725}, :BYU=>{:img=>"252", :url=>77}, :"Notre Dame"=>{:img=>"87", :url=>513}, :Akron=>{:img=>"2006", :url=>5}, :"Ball State"=>{:img=>"2050", :url=>47}, :"Bowling Green"=>{:img=>"189", :url=>71}, :Buffalo=>{:img=>"2084", :url=>86}, :"Central Michigan"=>{:img=>"2117", :url=>129}, :"Eastern Michigan"=>{:img=>"2199", :url=>204}, :"Kent State"=>{:img=>"2309", :url=>331}, :Massachusetts=>{:img=>"113", :url=>400}, :"Miami (Ohio)"=>{:img=>"193", :url=>414}, :"Northern Illinois"=>{:img=>"2459", :url=>503}, :Ohio=>{:img=>"195", :url=>519}, :Toledo=>{:img=>"2649", :url=>709}, :"Western Michigan"=>{:img=>"2711", :url=>774}, :"Air Force"=>{:img=>"2005", :url=>721}, :"Boise State"=>{:img=>"68", :url=>66}, :"Colorado State"=>{:img=>"36", :url=>156}, :"Fresno State"=>{:img=>"278", :url=>96}, :"Hawai'i"=>{:img=>"62", :url=>277}, :Nevada=>{:img=>"2440", :url=>466}, :"New Mexico"=>{:img=>"167", :url=>473}, :"San Diego State"=>{:img=>"21", :url=>626}, :"San Jose State"=>{:img=>"23", :url=>630}, :UNLV=>{:img=>"2439", :url=>465}, :"Utah State"=>{:img=>"328", :url=>731}, :Wyoming=>{:img=>"2751", :url=>811}, :Arizona=>{:img=>"12", :url=>29}, :"Arizona State"=>{:img=>"9", :url=>28}, :California=>{:img=>"25", :url=>107}, :Colorado=>{:img=>"38", :url=>157}, :Oregon=>{:img=>"2483", :url=>529}, :"Oregon State"=>{:img=>"204", :url=>528}, :Stanford=>{:img=>"24", :url=>674}, :UCLA=>{:img=>"26", :url=>110}, :USC=>{:img=>"30", :url=>657}, :Utah=>{:img=>"254", :url=>732}, :Washington=>{:img=>"264", :url=>756}, :"Washington State"=>{:img=>"265", :url=>754}, :Alabama=>{:img=>"333", :url=>8}, :Arkansas=>{:img=>"8", :url=>31}, :Auburn=>{:img=>"2", :url=>37}, :Florida=>{:img=>"57", :url=>235}, :Georgia=>{:img=>"61", :url=>257}, :Kentucky=>{:img=>"96", :url=>334}, :LSU=>{:img=>"99", :url=>365}, :"Mississippi State"=>{:img=>"344", :url=>430}, :Missouri=>{:img=>"142", :url=>434}, :Mississippi=>{:img=>"145", :url=>433}, :"South Carolina"=>{:img=>"2579", :url=>648}, :Tennessee=>{:img=>"2633", :url=>694}, :"Texas A&M"=>{:img=>"245", :url=>697}, :Vanderbilt=>{:img=>"238", :url=>736}, :"Appalachian State"=>{:img=>"2026", :url=>27}, :"Arkansas State"=>{:img=>"2032", :url=>30}, :"Georgia Southern"=>{:img=>"290", :url=>253}, :"Georgia State"=>{:img=>"2247", :url=>254}, :Idaho=>{:img=>"70", :url=>295}, :"Louisiana-Lafayette"=>{:img=>"309", :url=>671}, :"Louisiana-Monroe"=>{:img=>"2433", :url=>498}, :"New Mexico State"=>{:img=>"166", :url=>472}, :"South Alabama"=>{:img=>"6", :url=>646}, :"Texas State"=>{:img=>"326", :url=>670}, :Troy=>{:img=>"2653", :url=>716}}

teams.each do |k, v|
  team_num = v[:url]
  web_page = open("http://www.cfbstats.com/2015/team/140/index.html")
  open("team_#{team_num}.html", 'w') do |f|
    f << web_page.read
  end
  puts "Saved #{k} page succesfully!"
  sleep 2
end