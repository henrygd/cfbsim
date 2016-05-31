#! /home/hank/.rbenv/shims/ruby
# calculate team rankings in somewhat roundabout way
# must save updated teams / national stats pages first

require 'nokogiri'
require 'open-uri'

class Team_hash < Hash
  def stats_to_hundred_scale!
    top_run = values.sort_by {|i| -i[:run_offense]}.first[:run_offense] * 1.01
    # Get top pass offense
    top_pass = values.sort_by {|i| -i[:pass_offense]}.first[:pass_offense] * 1.01
    # Get top run defense
    top_run_defense = values.sort_by {|i| i[:run_defense]}.first[:run_defense] * 0.99
    # Get top pass defense
    top_pass_defense = values.sort_by {|i| i[:pass_defense]}.first[:pass_defense] * 0.99
    # Get biggest lundgrens
    top_lundgren = values.sort_by {|i| i[:lundgren]}.first[:lundgren] * 0.99
    # Assign trait values out of 100
    each do |k, v|
      # run offense
      run_offense = ( ( v[:run_offense] / top_run ) * 100 )
      v[:run_offense] = run_offense
      # Pass offense
      pass_offense = ( ( v[:pass_offense] / top_pass ) * 100 )
      v[:pass_offense] = pass_offense
      # run defense
      run_defense = ( ( top_run_defense / v[:run_defense] ) * 100 )
      v[:run_defense] = run_defense
      # pass defense
      pass_defense = ( ( top_pass_defense / v[:pass_defense] ) * 100 )
      v[:pass_defense] = pass_defense
      # lundgren
      lundgren = ( ( top_lundgren / v[:lundgren] ) * 100 )
      v[:lundgren] = lundgren
      overall = run_offense + pass_offense + run_defense + pass_defense +
                v[:special_teams] + (lundgren / 3)
      v[:overall] = overall
    end
    overall_to_hundred_scale!
  end

  def overall_to_hundred_scale!
    top_overall = values.sort_by {|i| -i[:overall]}.first[:overall] * 1.01
    each do |k, v|
      overall = ( ( v[:overall] / top_overall ) * 100 ).round( 0 )
      v[:overall] = overall
    end
  end

  def get_sos!
    each do |k, v|
      # v[:result_multiplier] ||= 1
      tt = 0
      games = 0
      v[:games].each do |game|
        next if game.length < 3
        # game.push :testing
        opponent = game[1]
        begin
        opponent_overall = TEAM_HASH[opponent::to_sym][:overall]
        rescue
          opponent_overall = 35
        end
        games += 1
        tt += opponent_overall
        # if opponent.nil?
        #   next
        # else
        #   won = game[2] == 'W' 
        #   opponent_strength = opponent[:overall] * 2 - 100
        #   margin = 
        #   # result_multiplier =
        #   game.push 
        # end
      end
      v[:opp_overall] = tt / games.to_f
      overall_to_hundred_scale!
    end

    each do |k, v|
      games = 0
      opp_opp_sos = 0
      v[:games].each do |game|
        next if game.length < 3
        opponent = game[1]
        begin
        opponent_sos = TEAM_HASH[opponent::to_sym][:opp_overall]
        rescue
          opponent_sos = 35
        end
        opp_opp_sos += opponent_sos
        games += 1
      end
      sos = ( ( opp_opp_sos / games ) + v[:opp_overall] )
      sos_divide = (sos / 150) - 1
      sos_factor = sos_divide * 1.1 + 1
      v[:sos] = sos_divide * 3 + 1
      v[:pass_offense] *= sos_factor
      v[:run_offense] *= sos_factor
      v[:pass_defense] *= sos_factor
      v[:run_defense] *= sos_factor
      v[:lundgren] *= sos_factor
      v[:special_teams] *= sos_factor
    end

    # test recalculate overall with sos
    each do |k, v|
      overall = v[:overall] * ( v[:sos] / 2.5 )
      v[:overall] = overall
    end
  end

  def game_by_game!
    # game results
    each do |k, v|
      total_quality_points = 0
      games = 0
      v[:games].each do |game|
        next if game.length < 3
        opponent = game[1]
        begin
          opponent_overall = TEAM_HASH[opponent::to_sym][:overall]
        rescue
          opponent_overall = 35
        end
        win_factor = game[2] == 'W' ? 3.5 : 1
        margin = game[3] - game[4]
        quality_points = (opponent_overall * 4.0) * win_factor + margin
        # game.push quality_points
        total_quality_points += quality_points
        games += 1
      end
      v[:quality_ppg] = total_quality_points / games
      # v[:overall] += total_quality_points / games
      overall_to_hundred_scale!
    end

    each do |k, v|
      qp = v[:quality_ppg] 
      v[:overall] += qp
    end

  #   # add quality_ppg to overall
  #   each do |k, v|
  # #     # qp = v[:quality_ppg]
  #     qp = v[:quality_ppg]
  #     v[:overall] += qp
  # #     v[:pass_offense] += qp_boost
  # #     v[:run_offense] += qp_boost
  # #     v[:pass_defense] += qp_boost
  # #     v[:run_defense] += qp_boost
  # #     v[:lundgren] += qp_boost
  #   end
  end
end

  def performance_to_one_hundred!
    [:pass_offense, :run_offense, :pass_defense, :run_defense, :lundgren, :special_teams, :sos].each do |cat|
      top = TEAM_HASH.values.sort_by {|i| -i[cat]}.first[cat] * 1.01
      TEAM_HASH.each do |k, v|
        v[cat] = ( ( v[cat] / top ) * 100 ).round( 0 )
      end
    end
    top_quality_ppg = TEAM_HASH.values.sort_by {|i| -i[:quality_ppg]}.first[:quality_ppg] * 1.01
    TEAM_HASH.each do |k, v|
      v[:quality_ppg] = ( ( v[:quality_ppg] / top_quality_ppg ) * 100 ).round( 0 )
    end

    # TEAM_HASH.each do |k, v|
    #   quality_ppg = v[:quality_ppg]
    #   v[:pass_offense] = ((v[:pass_offense] + quality_ppg / 2) / 1.5).round(0)
    #   v[:run_offense] = ((v[:run_offense] + quality_ppg / 2) / 1.5).round(0)
    #   v[:pass_defense] = ((v[:pass_defense] + quality_ppg / 2) / 1.5).round(0)
    #   v[:run_defense] = ((v[:run_defense] + quality_ppg / 2) / 1.5).round(0)
    #   v[:lundgren] = ((v[:lundgren] + ( quality_ppg / 2.0 )) / 1.5).round(0)
    #   v[:special_teams] = ((v[:special_teams] + ( quality_ppg / 2.0 )) / 1.5).round(0)
    # end
  end

  def adjust_lundgren!
    top = TEAM_HASH.values.sort_by {|i| -i[:lundgren]}.first[:lundgren]
    TEAM_HASH.each do |k, v|
      v[:lundgren] = (v[:lundgren] + ((top - v[:lundgren]) / 3)).round( 0 )
    end
  end

TEAM_HASH = Team_hash[:Cincinnati=>{:img=>"2132", :url=>140}, :Connecticut=>{:img=>"41", :url=>164}, :"East Carolina"=>{:img=>"151", :url=>196}, :Houston=>{:img=>"248", :url=>288}, :Memphis=>{:img=>"235", :url=>404}, :Navy=>{:img=>"2426", :url=>726}, :SMU=>{:img=>"2567", :url=>663}, :"South Florida"=>{:img=>"58", :url=>651}, :Temple=>{:img=>"218", :url=>690}, :Tulane=>{:img=>"2655", :url=>718}, :Tulsa=>{:img=>"202", :url=>719}, :UCF=>{:img=>"2116", :url=>128}, :"Boston College"=>{:img=>"103", :url=>67}, :Clemson=>{:img=>"228", :url=>147}, :Duke=>{:img=>"150", :url=>193}, :"Florida State"=>{:img=>"52", :url=>234}, :"Georgia Tech"=>{:img=>"59", :url=>255}, :Louisville=>{:img=>"97", :url=>367}, :"Miami (Florida)"=>{:img=>"2390", :url=>415}, :"North Carolina State"=>{:img=>"152", :url=>490}, :"North Carolina"=>{:img=>"153", :url=>457}, :Pittsburgh=>{:img=>"221", :url=>545}, :Syracuse=>{:img=>"183", :url=>688}, :Virginia=>{:img=>"258", :url=>746}, :"Virginia Tech"=>{:img=>"259", :url=>742}, :"Wake Forest"=>{:img=>"154", :url=>749}, :Baylor=>{:img=>"239", :url=>51}, :"Iowa State"=>{:img=>"66", :url=>311}, :Kansas=>{:img=>"2305", :url=>328}, :"Kansas State"=>{:img=>"2306", :url=>327}, :Oklahoma=>{:img=>"201", :url=>522}, :"Oklahoma State"=>{:img=>"197", :url=>521}, :TCU=>{:img=>"2628", :url=>698}, :Texas=>{:img=>"251", :url=>703}, :"Texas Tech"=>{:img=>"2641", :url=>700}, :"West Virginia"=>{:img=>"277", :url=>768}, :Illinois=>{:img=>"356", :url=>301}, :Indiana=>{:img=>"84", :url=>306}, :Iowa=>{:img=>"2294", :url=>312}, :Maryland=>{:img=>"120", :url=>392}, :Michigan=>{:img=>"130", :url=>418}, :"Michigan State"=>{:img=>"127", :url=>416}, :Minnesota=>{:img=>"135", :url=>428}, :Nebraska=>{:img=>"158", :url=>463}, :Northwestern=>{:img=>"77", :url=>509}, :"Ohio State"=>{:img=>"194", :url=>518}, :"Penn State"=>{:img=>"213", :url=>539}, :Purdue=>{:img=>"2509", :url=>559}, :Rutgers=>{:img=>"164", :url=>587}, :Wisconsin=>{:img=>"275", :url=>796}, :Charlotte=>{:img=>"2429", :url=>458}, :"Florida Atlantic"=>{:img=>"2226", :url=>229}, :"Florida International"=>{:img=>"2229", :url=>231}, :"Louisiana Tech"=>{:img=>"2348", :url=>366}, :Marshall=>{:img=>"276", :url=>388}, :"Middle Tennessee"=>{:img=>"2393", :url=>419}, :"North Texas"=>{:img=>"249", :url=>497}, :"Old Dominion"=>{:img=>"295", :url=>523}, :Rice=>{:img=>"242", :url=>574}, :"Southern Mississippi"=>{:img=>"2572", :url=>664}, :UTSA=>{:img=>"2636", :url=>706}, :UTEP=>{:img=>"2638", :url=>704}, :"Western Kentucky"=>{:img=>"98", :url=>772}, :Army=>{:img=>"349", :url=>725}, :BYU=>{:img=>"252", :url=>77}, :"Notre Dame"=>{:img=>"87", :url=>513}, :Akron=>{:img=>"2006", :url=>5}, :"Ball State"=>{:img=>"2050", :url=>47}, :"Bowling Green"=>{:img=>"189", :url=>71}, :Buffalo=>{:img=>"2084", :url=>86}, :"Central Michigan"=>{:img=>"2117", :url=>129}, :"Eastern Michigan"=>{:img=>"2199", :url=>204}, :"Kent State"=>{:img=>"2309", :url=>331}, :Massachusetts=>{:img=>"113", :url=>400}, :"Miami (Ohio)"=>{:img=>"193", :url=>414}, :"Northern Illinois"=>{:img=>"2459", :url=>503}, :Ohio=>{:img=>"195", :url=>519}, :Toledo=>{:img=>"2649", :url=>709}, :"Western Michigan"=>{:img=>"2711", :url=>774}, :"Air Force"=>{:img=>"2005", :url=>721}, :"Boise State"=>{:img=>"68", :url=>66}, :"Colorado State"=>{:img=>"36", :url=>156}, :"Fresno State"=>{:img=>"278", :url=>96}, :"Hawai'i"=>{:img=>"62", :url=>277}, :Nevada=>{:img=>"2440", :url=>466}, :"New Mexico"=>{:img=>"167", :url=>473}, :"San Diego State"=>{:img=>"21", :url=>626}, :"San Jose State"=>{:img=>"23", :url=>630}, :UNLV=>{:img=>"2439", :url=>465}, :"Utah State"=>{:img=>"328", :url=>731}, :Wyoming=>{:img=>"2751", :url=>811}, :Arizona=>{:img=>"12", :url=>29}, :"Arizona State"=>{:img=>"9", :url=>28}, :California=>{:img=>"25", :url=>107}, :Colorado=>{:img=>"38", :url=>157}, :Oregon=>{:img=>"2483", :url=>529}, :"Oregon State"=>{:img=>"204", :url=>528}, :Stanford=>{:img=>"24", :url=>674}, :UCLA=>{:img=>"26", :url=>110}, :USC=>{:img=>"30", :url=>657}, :Utah=>{:img=>"254", :url=>732}, :Washington=>{:img=>"264", :url=>756}, :"Washington State"=>{:img=>"265", :url=>754}, :Alabama=>{:img=>"333", :url=>8}, :Arkansas=>{:img=>"8", :url=>31}, :Auburn=>{:img=>"2", :url=>37}, :Florida=>{:img=>"57", :url=>235}, :Georgia=>{:img=>"61", :url=>257}, :Kentucky=>{:img=>"96", :url=>334}, :LSU=>{:img=>"99", :url=>365}, :"Mississippi State"=>{:img=>"344", :url=>430}, :Missouri=>{:img=>"142", :url=>434}, :Mississippi=>{:img=>"145", :url=>433}, :"South Carolina"=>{:img=>"2579", :url=>648}, :Tennessee=>{:img=>"2633", :url=>694}, :"Texas A&M"=>{:img=>"245", :url=>697}, :Vanderbilt=>{:img=>"238", :url=>736}, :"Appalachian State"=>{:img=>"2026", :url=>27}, :"Arkansas State"=>{:img=>"2032", :url=>30}, :"Georgia Southern"=>{:img=>"290", :url=>253}, :"Georgia State"=>{:img=>"2247", :url=>254}, :Idaho=>{:img=>"70", :url=>295}, :"Louisiana-Lafayette"=>{:img=>"309", :url=>671}, :"Louisiana-Monroe"=>{:img=>"2433", :url=>498}, :"New Mexico State"=>{:img=>"166", :url=>472}, :"South Alabama"=>{:img=>"6", :url=>646}, :"Texas State"=>{:img=>"326", :url=>670}, :Troy=>{:img=>"2653", :url=>716}]

# Align team names between sites
def correct_team_name( team )
  case team
    when 'Central Florida' then team = 'UCF'
    when 'Hawaii'          then team = "Hawai'i"
    when /Louisiana\s[LM]/ then team.gsub! ' ', '-' 
    when 'Miami (OH)'      then team = 'Miami (Ohio)'
    when 'Miami'           then team = 'Miami (Florida)'
  end
  team
end

############## SACKS ##############
sack_page = Nokogiri::HTML( open( "./national_stats/sacks.html" ) )
sack_teams = sack_page.css('.team-name > a')
sacks = sack_page.css('table.leaders td:nth-child(4)')
sack_yds = sack_page.css('table.leaders td:nth-child(5)')
sacks_pg = sack_page.css('table.leaders td:nth-child(6)')
# Add team sack yards to hash
sack_teams.each_with_index do |team, x| 
  # TEAM_HASH[team.text] ||= {}
  TEAM_HASH[team.text::to_sym][:sacks] = sacks[x].text.to_f
  TEAM_HASH[team.text::to_sym][:sack_yds] = sack_yds[x].text.to_f
  TEAM_HASH[team.text::to_sym][:sacks_pg] = sacks_pg[x].text.to_f
end

############## SACKS ALLOWED ##############
sacks_allowed_page = Nokogiri::HTML( open( "./national_stats/sacks_allowed.html" ) )
sacks_allowed_teams = sacks_allowed_page.css('.team-name > a')
sack_yds_allowed = sacks_allowed_page.css('table.leaders td:nth-child(5)')
sacks_allowed = sacks_allowed_page.css('table.leaders td:nth-child(4)')
sacks_allowed_pg = sacks_allowed_page.css('table.leaders td:nth-child(6)')
# Add team sack yards to hash
sacks_allowed_teams.each_with_index do |team, x| 
  # TEAM_HASH[team.text] ||= {}
  TEAM_HASH[team.text::to_sym][:sack_yds_allowed] = sack_yds_allowed[x].text.to_f
  TEAM_HASH[team.text::to_sym][:sacks_allowed] = sacks_allowed[x].text.to_f
  TEAM_HASH[team.text::to_sym][:sacks_allowed_pg] = sacks_allowed_pg[x].text.to_f
end

# ############## RUN OFFENSE ##############
Run_offense_page = Nokogiri::HTML( open( "./national_stats/run_offense.html" ) )
Run_offense_teams = Run_offense_page.css('.team-name > a')
Run_offense_yards = Run_offense_page.css('table.leaders td:nth-child(5)')
Run_offense_atts = Run_offense_page.css('table.leaders td:nth-child(4)')


# Run_offense_teams.each { |t| TEAM_HASH[t.text] ||= {} }

def calculate_run_offense( arr )
  return (Run_offense_yards[arr[0]].text.to_f + TEAM_HASH[arr[1]::to_sym][:sack_yds_allowed]) / 
         (Run_offense_atts[arr[0]].text.to_f - TEAM_HASH[arr[1]::to_sym][:sacks_allowed])
end

# top_run_offense = calculate_run_offense( 0 ) * 1.01
Run_offense_teams.each_with_index do |team, x|
  run_offense = calculate_run_offense( [x, team.text] )
  TEAM_HASH[team.text::to_sym][:run_offense] = run_offense
end

# # ############## PASS OFFENSE ##############
Pass_offense_page = Nokogiri::HTML( open( "./national_stats/pass_offense.html" ) )
Pass_offense_teams = Pass_offense_page.css('.team-name > a')
Pass_offense_ypa = Pass_offense_page.css('table.leaders td:nth-child(8)')
Pass_offense_comp_percent = Pass_offense_page.css('table.leaders td:nth-child(6)')
Pass_offense_tds = Pass_offense_page.css('table.leaders td:nth-child(9)')
Pass_offense_ints = Pass_offense_page.css('table.leaders td:nth-child(10)')
Pass_offense_ypg = Pass_offense_page.css('table.leaders td:nth-child(13)')

# Pass_offense_teams.each { |t| TEAM_HASH[t.text] ||= {} }

def calculate_pass_offense( arr )
  return ( Pass_offense_ypa[arr[0]].text.to_f * 2.0 ) -
         ( TEAM_HASH[arr[1]::to_sym][:sacks_allowed_pg] * 2.0 ) +
         ( Pass_offense_comp_percent[arr[0]].text.to_f / 4.0 ) + 
         ( ( Pass_offense_tds[arr[0]].text.to_f - Pass_offense_ints[arr[0]].text.to_f) / 2.0 ) +
         ( Pass_offense_ypg[arr[0]].text.to_f / 30.0 )
end

# top_pass_offense = calculate_pass_offense( 0 ) * 1.01

Pass_offense_teams.each_with_index do |team, x|
  pass_offense = calculate_pass_offense( [x, team.text] )
  TEAM_HASH[team.text::to_sym][:pass_offense] = pass_offense
end

# ############## RUN DEFENSE ##############
Run_defense_page = Nokogiri::HTML( open( "./national_stats/run_defense.html" ) )
Run_defense_teams = Run_defense_page.css('.team-name > a')
Run_defense_yards = Run_defense_page.css('table.leaders td:nth-child(5)')
Run_defense_atts = Run_defense_page.css('table.leaders td:nth-child(4)')

# Run_defense_teams.each { |t| TEAM_HASH[t.text] ||= {} }

def calculate_run_defense( arr )
  return (Run_defense_yards[arr[0]].text.to_f + TEAM_HASH[arr[1]::to_sym][:sack_yds]) / 
         (Run_defense_atts[arr[0]].text.to_f - TEAM_HASH[arr[1]::to_sym][:sacks])
end

# top_run_defense = calculate_run_defense( [0, run_defense_teams[0].text] ) * 0.99
Run_defense_teams.each_with_index do |team, x|
  run_defense = calculate_run_defense( [x, team.text] )
  TEAM_HASH[team.text::to_sym][:run_defense] = run_defense
end

# ############## PASS DEFENSE ##############
Pass_defense_page = Nokogiri::HTML( open( "./national_stats/pass_defense.html" ) )
Pass_defense_teams = Pass_defense_page.css('.team-name > a')
Pass_defense_ypa = Pass_defense_page.css('table.leaders td:nth-child(8)')
Pass_defense_comp_percent = Pass_defense_page.css('table.leaders td:nth-child(6)')
Pass_defense_tds = Pass_defense_page.css('table.leaders td:nth-child(9)')
Pass_defense_ints = Pass_defense_page.css('table.leaders td:nth-child(10)')
Pass_defense_ypg = Pass_defense_page.css('table.leaders td:nth-child(13)')

# Pass_defense_teams.each { |t| TEAM_HASH[t.text] ||= {} }

def calculate_pass_defense( arr )
  return ( Pass_defense_ypa[arr[0]].text.to_f * 2.0 ) -
         ( TEAM_HASH[arr[1]::to_sym][:sacks_pg] * 2.0) +
         ( Pass_defense_comp_percent[arr[0]].text.to_f / 4.0 ) + 
         ( Pass_defense_tds[arr[0]].text.to_f - Pass_defense_ints[arr[0]].text.to_f ) +
         ( Pass_defense_ypg[arr[0]].text.to_f / 30.0 )
end

# top_pass_defense = calculate_pass_defense( 0 ) * 0.99

Pass_defense_teams.each_with_index do |team, x|
  pass_defense = calculate_pass_defense( [x, team.text] )
  TEAM_HASH[team.text::to_sym][:pass_defense] = pass_defense
end

# ############## lundgren ##############
Penalties_page = Nokogiri::HTML( open( "./national_stats/penalties.html" ) )
Penalties_teams = Penalties_page.css('.team-name > a')
Penalties_per_game = Penalties_page.css('table.leaders td:nth-child(6)')


Turnovers_page = Nokogiri::HTML( open( "./national_stats/turnovers.html" ) )
Turnovers_teams = Turnovers_page.css('.team-name > a')
Turnover_margin = Turnovers_page.css('table.leaders td:nth-child(11)')
Top_turnover_margin = Turnover_margin[0].text.to_f

# Penalties_teams.each { |t| TEAM_HASH[t.text] ||= {} }

def calculate_lundgren( turnovers, penalties )
  return ( (turnovers - Top_turnover_margin) * -2 ) + penalties 
end

Penalties_teams.each_with_index do |team, x|
  TEAM_HASH[team.text::to_sym][:penalties] = Penalties_per_game[x].text.to_f
end

Turnovers_teams.each_with_index do |team, x|
  team = team.text::to_sym
  TEAM_HASH[team::to_sym][:lundgren] = calculate_lundgren(
    Turnover_margin[x].text.to_f, TEAM_HASH[team][:penalties] )
end

############## SPECIAL TEAMS ##############
Special_teams_page = Nokogiri::HTML( open( "./national_stats/special_teams.html" ) )
st_teams = Special_teams_page.css('table.stats tr td:nth-child(2)')
st_rating = Special_teams_page.css('table.stats tr td:nth-child(4)')
# Add special teams rating
st_worst = st_rating.last.text.to_f * 2.5
st_best = ( st_rating[1].text.to_f - st_worst ) * 1.01
st_teams.each_with_index do |team, x|
  team = team.text
  next if team == 'Team'
  # Adjust team names to match other site
  team = correct_team_name( team )
  # TEAM_HASH[team] ||= {}
  TEAM_HASH[team::to_sym][:special_teams] = ( ( (st_rating[x].text.to_f - st_worst) / 
    st_best ) * 100 ).round 0
end


# Output team  objects
# TEAM_HASH.each do |k, v|
#   puts "Team.new(name:\"#{k}\", pass_offense: #{v[:pass_offense]}, pass_defense: #{v[:pass_defense]}, run_offense: #{v[:run_offense]}, run_defense: #{v[:run_defense]}, special_teams: #{v[:special_teams]}),"
# end


# ############## INDIVIDUAL TEAMS ##############
TEAM_HASH.each do |k, v|
  team_page = Nokogiri::HTML( open( "./team_pages/team_#{v[:url]}.html" ) )
  # team_scoring = team_page.css('table.team-statistics tr')[1].css('td')
  # team_point_margin = team_scoring[1].text.to_f / team_scoring[2].text.to_f
  game_opponent = team_page.css('table.team-schedule td.opponent')
  game_date = team_page.css('table.team-schedule td.date')
  game_result = team_page.css('table.team-schedule td.result')

  game_opponent.each_with_index do |team, x|
    tt = team.text
    result_array = [game_date[x].text]
    # fix abbreviated team names
    tt.gsub!(/^@ |\d/, '')
    tt.gsub!( /^ /, '' )
    tt.gsub!(/\+\s+/, '')
    tt.gsub! 'La.', 'Louisiana'
    tt.gsub! 'St.', 'State'
    tt.gsub! 'Fla.', 'Florida'
    tt.gsub! 'Caro.', 'Carolina'
    tt.gsub! 'Brigham Young', 'BYU'
    tt.gsub! 'Mich.', 'Michigan'
    tt.gsub! "Int'l", 'International'
    tt.gsub! 'Ga.', 'Georgia'
    tt.gsub! 'Hawaii', "Hawai'i"
    tt.gsub! 'Tenn.', 'Tennessee'
    tt.gsub! 'Ill.', 'Illinois'
    tt.gsub! 'Southern California', 'USC'
    tt.gsub! 'Southern Methodist', 'SMU'
    tt.gsub! 'Miss.', 'Mississippi'
    tt.gsub! 'Ky.', 'Kentucky'
    tt.gsub! 'Middle Tennessee State', 'Middle Tennessee'
    result_array.push tt
    # scores of played games
    if game_result[x].text.length > 0
      # W or L
      result = game_result[x].text.split( ' ' )
      result_array.push result[0]
      # team scores
      result = result[1].split '-'
      result_array.push result[0].to_i, result[1].to_i
    end
    # add game results to hash
    v[:games] ||= []
    v[:games].push result_array
  end

  # v[:games] = [team_scoring.text]
  # p "#{k} ppg bonus: #{team_point_margin}"
end
adjust_lundgren!
TEAM_HASH
  .stats_to_hundred_scale! # .overall_to_hundred_scale!
  .get_sos! # .overall_to_hundred_scale!
  .game_by_game! # .overall_to_hundred_scale!


performance_to_one_hundred!

TEAM_HASH.overall_to_hundred_scale!

# TEAM_HASH.sort_by {|k, v| -v[:overall]}
#     .each {|k| puts k }


# # Output js teams
js = "TeamRatings={"
TEAM_HASH.each do |k, v|
  # unminified
  # js += "\n  '#{k}': [#{v[:overall]}, #{v[:run_offense]}, #{v[:pass_offense]}, #{v[:run_defense]}, #{v[:pass_defense]}, #{v[:special_teams]}, #{v[:lundgren]}, #{v[:sos]}, #{v[:quality_ppg]}],"
  # minified
  js += "\"#{k}\":[#{v[:overall]},#{v[:run_offense]},#{v[:pass_offense]},#{v[:run_defense]},#{v[:pass_defense]},#{v[:special_teams]},#{v[:lundgren]},#{v[:sos]},#{v[:quality_ppg]}],"
end
js += "}"
open("../js/teamRatings/teamratings-#{Time.new.strftime("%Y-%m-%d")}.js", 'w') { |f|  f << js }
open("../js/teamRatings/teamratings.js", 'w') { |f|  f << js }
puts "Updated team ratings"