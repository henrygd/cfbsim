#! /bin/ruby
# record = "8-0"

# if record.split('-')[1] == '0'
#   res = record.split('-')[0].to_f * 1.5
# else
#   res = eval record.gsub '-', '.0/'
# end

# lundgren = 22

# p 88 * ( (lundgren - 100) * -0.0007 + 1 )

require 'nokogiri'
require 'open-uri'
# TEAM_HASH = {'Washington State': {url: 754, games: [['10-31', 'Washington', :W, 32, 42], ['11-7', 'Utah', :L, 21, 27]]}}

class Team_hash < Hash
  def out_of_one_hundred!
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
      run_offense = ( ( v[:run_offense] / top_run ) * 100 ).round( 0 )
      v[:run_offense] = run_offense
      # Pass offense
      pass_offense = ( ( v[:pass_offense] / top_pass ) * 100 ).round( 0 )
      v[:pass_offense] = pass_offense
      # run defense
      run_defense = ( ( top_run_defense / v[:run_defense] ) * 100 ).round( 0 )
      v[:run_defense] = run_defense
      # pass defense
      pass_defense = ( ( top_pass_defense / v[:pass_defense] ) * 100 ).round( 0 )
      v[:pass_defense] = pass_defense
      # lundgren
      lundgren = ( ( top_lundgren / v[:lundgren] ) * 100 ).round( 0 )
      v[:lundgren] = lundgren
      overall = run_offense + pass_offense + run_defense + pass_defense +
                  v[:special_teams] + lundgren
      v[:overall] = overall
    end
  end
end

TEAM_HASH = Team_hash["Air Force": {url: 721}, "Akron": {url: 5}, "Alabama": {url: 8}, "Appalachian State": {url: 27}, "Arizona": {url: 29}, "Arizona State": {url: 28}, "Arkansas": {url: 31}, "Arkansas State": {url: 30}, "Army": {url: 725}, "Auburn": {url: 37}, "BYU": {url: 77}, "Ball State": {url: 47}, "Baylor": {url: 51}, "Boise State": {url: 66}, "Boston College": {url: 67}, "Bowling Green": {url: 71}, "Buffalo": {url: 86}, "California": {url: 107}, "Central Michigan": {url: 129}, "Charlotte": {url: 458}, "Cincinnati": {url: 140}, "Clemson": {url: 147}, "Colorado": {url: 157}, "Colorado State": {url: 156}, "Connecticut": {url: 164}, "Duke": {url: 193}, "East Carolina": {url: 196}, "Eastern Michigan": {url: 204}, "Florida": {url: 235}, "Florida Atlantic": {url: 229}, "Florida International": {url: 231}, "Florida State": {url: 234}, "Fresno State": {url: 96}, "Georgia": {url: 257}, "Georgia Southern": {url: 253}, "Georgia State": {url: 254}, "Georgia Tech": {url: 255}, "Hawai'i": {url: 277}, "Houston": {url: 288}, "Idaho": {url: 295}, "Illinois": {url: 301}, "Indiana": {url: 306}, "Iowa": {url: 312}, "Iowa State": {url: 311}, "Kansas": {url: 328}, "Kansas State": {url: 327}, "Kent State": {url: 331}, "Kentucky": {url: 334}, "LSU": {url: 365}, "Louisiana Tech": {url: 366}, "Louisiana-Lafayette": {url: 671}, "Louisiana-Monroe": {url: 498}, "Louisville": {url: 367}, "Marshall": {url: 388}, "Maryland": {url: 392}, "Massachusetts": {url: 400}, "Memphis": {url: 404}, "Miami (Florida)": {url: 415}, "Miami (Ohio)": {url: 414}, "Michigan": {url: 418}, "Michigan State": {url: 416}, "Middle Tennessee": {url: 419}, "Minnesota": {url: 428}, "Mississippi": {url: 433}, "Mississippi State": {url: 430}, "Missouri": {url: 434}, "Navy": {url: 726}, "Nebraska": {url: 463}, "Nevada": {url: 466}, "New Mexico": {url: 473}, "New Mexico State": {url: 472}, "North Carolina": {url: 457}, "North Carolina State": {url: 490}, "North Texas": {url: 497}, "Northern Illinois": {url: 503}, "Northwestern": {url: 509}, "Notre Dame": {url: 513}, "Ohio": {url: 519}, "Ohio State": {url: 518}, "Oklahoma": {url: 522}, "Oklahoma State": {url: 521}, "Old Dominion": {url: 523}, "Oregon": {url: 529}, "Oregon State": {url: 528}, "Penn State": {url: 539}, "Pittsburgh": {url: 545}, "Purdue": {url: 559}, "Rice": {url: 574}, "Rutgers": {url: 587}, "SMU": {url: 663}, "San Diego State": {url: 626}, "San Jose State": {url: 630}, "South Alabama": {url: 646}, "South Carolina": {url: 648}, "South Florida": {url: 651}, "Southern Mississippi": {url: 664}, "Stanford": {url: 674}, "Syracuse": {url: 688}, "TCU": {url: 698}, "Temple": {url: 690}, "Tennessee": {url: 694}, "Texas": {url: 703}, "Texas A&M": {url: 697}, "Texas State": {url: 670}, "Texas Tech": {url: 700}, "Toledo": {url: 709}, "Troy": {url: 716}, "Tulane": {url: 718}, "Tulsa": {url: 719}, "UCF": {url: 128}, "UCLA": {url: 110}, "UNLV": {url: 465}, "USC": {url: 657}, "UTEP": {url: 704}, "UTSA": {url: 706}, "Utah": {url: 732}, "Utah State": {url: 731},"Vanderbilt": {url: 736}, "Virginia": {url: 746}, "Virginia Tech": {url: 742}, "Wake Forest": {url: 749}, "Washington": {url: 756}, "Washington State": {url: 754}, "West Virginia": {url: 768}, "Western Kentucky": {url: 772}, "Western Michigan": {url: 774}, "Wisconsin": {url: 796}, "Wyoming": {url: 811}]

# sack_page = Nokogiri::HTML( open( "#{ENV['HOME']}/bin/sacks.html" ) )
# sack_teams = sack_page.css('.team-name > a')
# # Add team sack yards to hash
# sack_teams.each_with_index do |team, x| 
#   TEAM_HASH[team.text] ||= {}
# end

# TEAM_HASH.each do |k, v|
#   v[:games].each {|game| p "Score: #{k} #{game[2]}, #{game[0]} #{game[3]}"}
# end


# ############## INDIVIDUAL TEAMS ##############
TEAM_HASH.each do |k, v|
  team_page = Nokogiri::HTML( open( "/home/hank/Documents/team_pages/team_#{v[:url]}.html" ) )
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
    tt.gsub! 'La.', 'Louisiana'
    tt.gsub! 'St.', 'State'
    tt.gsub! 'Fla.', 'Florida'
    tt.gsub! 'Caro.', 'Carolina'
    tt.gsub!( /^ /, '' )
    tt.gsub! 'Brigham Young', 'BYU'
    tt.gsub!(/\+\s+/, '')
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

# TEAM_HASH.out_of_one_hundred!

bad_teams = []

TEAM_HASH.each do |k, v|
  v[:games].each do |t|
    team = t[1]
    bad_teams.push(team) if TEAM_HASH[team.to_sym].nil?
  end
end

puts bad_teams.sort

# TEAM_HASH.each do |k, v|
#   v[:games].each { |game| puts "#{game[0]} #{game[2]} #{game[1]}" + 
#     ( !game[3].nil? ? " #{game[3]} - #{game[4]}" : '' ) }
# end

# def calculate_lundgren( turnovers, penalties )
#   return ( (turnovers - Top_turnover_margin) * -4 ) + penalties 
# end

# Penalties_teams.each_with_index do |team, x|
#   TEAM_HASH[team.text][:penalties] = Penalties_per_game[x].text.to_f
# end

# Turnovers_teams.each_with_index do |team, x|
#   TEAM_HASH[team.text][:lundgren] = calculate_lundgren(
#     Turnover_margin[x].text.to_f, TEAM_HASH[team.text][:penalties] )
# end

# p TEAM_HASH.sort_by {|k, v| v[:lundgren]}


# # top_pass_defense = TEAM_HASH.values.sort_by {|i| i[:pass_defense]}.first[:pass_defense] * 0.99
# # Get best turnover margin
# top_lundgren = TEAM_HASH.values.sort_by {|i| -i[:lundgren]}.first[:lundgren] * 1.01
# # Assign trait values out of 100
# TEAM_HASH.each do |k, v|
#   lundgren = ( ( v[:lundgren] / top_lundgren ) * 100 ).round( 0 )
#   TEAM_HASH[k][:lundgren] = lundgren
# end

# p TEAM_HASH.sort_by {|k, v| -v[:lundgren]}