/* global ready function checks if logos are cached, fetches them if not,
   then passes to supplied page-specific onload function */
function globalOnLoad(onLoadFunc){
  // check if team logos are pre-cached in localStorage
  if ( localStorage !== null && localStorage.logo_Michigan ){
    console.log('got it');
    // go on with loading the page
    onLoadFunc();
  }
  else {
    // check if localstorage can be used
    if ( localStorage !== null ){
      // $.getScript( 'http://www.ucarecdn.com/2eccf503-4ec6-41c2-8136-87408ac30079/TeamLogos.js' );
      // show loading icon
      $('body').addClass('loading');
      // get the dang logos
      $.ajax({
        // script saves all compressed png logos to localstorage as base64
        url: 'http://www.ucarecdn.com/7cb677ff-d5a6-475a-a0db-bba46bc03f5d/teamLogos.js',
        dataType: "script",
        success: function(){
          // pause loading one second to assure logos can be cached properly
          setTimeout(function(){
            // go on with loading the page
            $('body').removeClass('loading');
            onLoadFunc();
          }, 1000);
        }
      });
    }
    // if no local storage
    else {
      alert('Local storage not supported. Team logos will not be shown.');
      onLoadFunc();
    }
  }
}

var TeamPanel = {
  // holds active teams
  curTeams: [],
  onLoad: function(){
    // change teams on arrow keys
    $(document).on('keydown', function(e){
      var nextTeam, prevTeam;
      // e.preventDefault();
      switch(e.keyCode){
        // right arrow to get next team
        case 39:
          nextTeam = TeamPanel.curTeams[0].nextAll('li').eq(0);
          if (nextTeam.length > 0)
            TeamPanel.changeTeam(nextTeam, 0);
          break;
        // left arrow to get previous team
        case 37:
          prevTeam = TeamPanel.curTeams[0].prevAll('li').eq(0);
          if (prevTeam.length > 0)
            TeamPanel.changeTeam(prevTeam, 0);
          break;
        // down arrow to get next team
        case 40:
          nextTeam = TeamPanel.curTeams[1].nextAll('li').eq(0);
          if (nextTeam.length > 0)
            TeamPanel.changeTeam(nextTeam, 1);
          break;
        // up arrow to get previous team
        case 38:
          prevTeam = TeamPanel.curTeams[1].prevAll('li').eq(0);
          if (prevTeam.length > 0)
            TeamPanel.changeTeam(prevTeam, 1);
          break;
        // enter
        case 13:
          e.preventDefault();
          if ( !$('#results_container').hasClass('show-results') )
            TeamPanel.startSim();
          break;
        // exit
        case 27:
          TeamPanel.closeSim();
          break;
        // r for random matchup
        case 82:
          TeamPanel.randomTeam([0, 1]);
          break;
        default:
          break;
      }
      // if (e.keyCode == 39)
      //   var nextTeam = TeamPanel.curTeams[0].nextAll('li').eq(0)
      //   if (nextTeam.length > 0)
      //     TeamPanel.changeTeam(nextTeam, 0)
    });

    // logo image load binding to get logo color / change matchup text
    $('img.logo').on('load', function(){
      TeamPanel.imageLoad( this, $(this).getPanelIndex() );
    });
    // random team button binding
    $('.random-btn').on('click', function(){
      TeamPanel.randomTeam([$(this).getPanelIndex()]);
    });
    // show dropdown team menu binding
    $('.name-container').on('click', function(){
      $(this.parentElement).toggleClass('select-active');
    });

    // start game simulation presentation on btn click
    $('.btn-sim').on('click', function(){
      TeamPanel.startSim();
    });

    // close game results popup
    $('#close_results_btn').on('click', function(){
      TeamPanel.closeSim();
    });

    $(window).resize(function() {
      TeamPanel.dropDown.setHeight();
    });

    // initialize drop down team selection menu
    TeamPanel.dropDown.initialize();
    // random teams on page load
    TeamPanel.randomTeam([0, 1]);
    // fade in elements on page load
    $('body').removeClass('hide-elements');
  },

  // set random teams on page load
  randomTeam: function( arr ){
    // var teamOptions = $('.select-options').eq(0).find('li');
    $(arr).each(function( index ){
      var team = TeamPanel.teamNodelist.eq( ~~(Math.random() * 128) );
      // TeamPanel.teamOne = team;
      TeamPanel.changeTeam( team, arr[index] );
    });
  },

  imageLoad: function( img, index ){
    var team = img.getAttribute('team');
    var teamColor = localStorage['color_' + team] || TeamPanel.getLogoColor(img, team);
    var teamText = $('.team-matchup').find('h2').eq(index);
    var overall = $('.overall').eq(index);
    var selectBox = $('.custom-select').eq(index);
    var fullColor = 'rgb(' + teamColor + ')';
    var overallColor = 'rgba(' + TeamPanel.getRatingColor(TeamRatings[team][0]) + ', .65)';
    overall.css('background-color', overallColor);
    $('.team-panel').eq(index).find('.logo-container').css('background-color', 'rgb(' + teamColor + 
                  ')');
    selectBox.css('background-color', 'rgb(' + teamColor + ')');
    // selectBox.css('background', 'linear-gradient(rgba(' + teamColor + 
    //               ', .9), rgb(' + teamColor + '))');
    teamText.css('background-color', fullColor)
            .text(team);
  },

  changeLogo: function(team, index){
    var logo = $('.logo-container').eq(index).find('img');
    var image = 'data:image/png;base64,' + 
                localStorage['logo_' + team.replace(/\W/g, '')];
    logo.attr({src: image, 'team': team});
  },

  adjustMeters: function( team, index ){
    var ratingsDisplay = $('.team-panel-cells').eq(index);
    var meters = ratingsDisplay.find('.meter');
    var meterText = ratingsDisplay.find('.rating span');
    var teamRatings = TeamRatings[team];
    meterText.each(function( index ){
      var rating = teamRatings[index];
      var meterColor = TeamPanel.getRatingColor(rating);
      $(meterText[index]).text(rating);
      // $(meters[index - 1]).animate({
      //   width: rating + '%',
      // }, {duration: 700, queue: false}).css('background-color', meterColor);
      rating = rating < 10 ? '0' + rating : rating;
      $(meters[index -1]).css({'background-color': 'rgb(' + meterColor + ')',
                         '-webkit-transform': 'scale3d(.' + rating + ', 1, 1)',
                         'transform': 'scale3d(.' + rating + ', 1, 1)'});
    });

    // $('.overall').eq(index).css('background-color', 'rgb(35, 182, 53)');
  },

  getRatingColor: function(rating){
      if (rating < 45)
        return '229, 57, 53';
      else if (rating < 75)
        return '243, 182, 0';
      else
        return '35, 182, 53';
  },

  getLogoColor: function( logo, team ){
    // extract color from logo
    var colorThief = new ColorThief();
    var colArray = colorThief.getColor( logo );
    var colorString = colArray.join(', ');
    // custom color teams
    if (team == 'Iowa')
      colorString = '255, 193, 7';
    if (team == 'Michigan')
      colorString = '1, 44, 98';
    if (team == 'Virginia Tech')
      colorString = '127, 10, 10';
    if (team == 'Florida')
      colorString =  '0, 79, 156';
    // cache team colors in localStorage so we don't do this again
    localStorage['color_' + team] = colorString;
    // this.teamColors[team] = this.teamColors[team] || {};
    // this.teamColors[team] = colorString;
    return colorString;
  },

  changeTeam: function( team, index ){
    this.curTeams[index] = team;
    var teamName = team.text();
    var dropDown = $('.custom-select').eq(index);
    dropDown.find('.name-container span').text(teamName);
    TeamPanel.changeLogo(teamName, index);
    TeamPanel.adjustMeters(teamName, index);
    dropDown.removeClass('select-active');
  },

  startSim: function(){
    // sim game and add results
    var teamOneName = TeamPanel.curTeams[0][0].textContent;
    var teamTwoName = TeamPanel.curTeams[1][0].textContent;
    var teamOne = new Team( teamOneName, TeamRatings[teamOneName] );
    var teamTwo = new Team( teamTwoName, TeamRatings[teamTwoName] );
    var comparativeStrengths = compareStrengths(teamOne, teamTwo);
    var simResult = SimGame(teamOne, teamTwo, 100);
    $('#sim_winning_pct').text();
    $('#sim_score').text( teamOneName + ' won ' + simResult[0] + ' games, ' + teamTwoName + ' won ' + simResult[1] + ' games.' +
        'average score: ' + teamOneName + ' ' + simResult[2] + ', ' + teamTwoName + ' ' + simResult[3] + ', median score: ' + simResult[4] + '-' + simResult[5]);
    // put team logo / color on bar display
    $('#team_one_bar, #team_two_bar').each(function(index){
      var team = TeamPanel.curTeams[index][0].textContent;
      $(this).css({
        'background-color': 'rgba(' + localStorage['color_' + team] + ', 0.5)',
        'background-image': "url('" + 'data:image/png;base64,' + 
            localStorage['logo_' + team.replace(/\W/g, '')] + "')"
      });
    });
    // fade in bar
    $('#results_container').addClass('show-results');
    // assign win percent on bar
    // var rand = ~~(Math.random() * 100);
    $('#team_one_bar').css('flex-basis', simResult[0] + '%');
    // count to 400 games
    $('#sim_bar').find('.counter').counterUp();
    // drop down stats
    showStats = setTimeout(function(){
      $('#sim_bar').find('.sim-text').css('opacity', '0');
      $('#sim_stats').animate({'height': '200px'}, 800);
    }, 2500);
  },

  closeSim: function(){
    $('#results_container').removeClass('show-results');
    window.clearTimeout(showStats);
    // $(this).slideUp();
    $('#sim_stats').animate({'height': '0px'}, 500);
    setTimeout(function(){
      $('#sim_bar').find('.sim-text').css('opacity', '1');
      $('#team_one_bar').css('flex-basis', '50%');
    }, 455);
  },

  dropDown: {
    initialize: function(){
      var teamOptions = $('.select-options');
      // store team menu elements
      TeamPanel.teamNodelist = $('#team_one_options > li');
      // set team select menu to match panel height
      TeamPanel.dropDown.setHeight(teamOptions);

      // initialize scrollbar
      Ps.initialize(teamOptions[0]);
      Ps.initialize(teamOptions[1]);

      // team dropropdown click binding
      teamOptions.find('> li').on('click', function(){
        var el = $(this);
        TeamPanel.changeTeam( el, el.getPanelIndex() );
      });
    },

    // set team select menu to match panel height
    setHeight: function(teamOptions){
      teamOptions = teamOptions || $('.select-options');
      var selectBox = teamOptions.eq(0).parent();
      var panel = selectBox.parent();
      var height = panel.height() - selectBox.height() + 1;
      teamOptions.css('height', height + 'px');
    }
  }
};

/* sim game function, team objects */

  // def sim_game( team_one, team_two, games=400 )

  //   # Simulate 200 games
  //   games.times do
  //     team_one_score = 0
  //     team_two_score = 0
  //     # Random per game stat boosts or drops
  //     # team_one.random_chance_magic
  //     # team_two.random_chance_magic
  //     # Ten possesions for each team
  //     10.times do
  //       team_one_score += team_one.drive_against( team_two )
  //       team_two_score += team_two.drive_against( team_one )
  //     end
  //     # OVERTIME
  //     if team_one_score == team_two_score
  //       # puts "Went to OT at #{team_one.name} #{team_one_score}, #{team_two.name} #{team_two_score}"
  //       until team_one_score != team_two_score
  //         team_one_score += team_one.drive_against( team_two )
  //         team_two_score += team_two.drive_against( team_one )
  //       end
  //     end
  //     team_one.total_points += team_one_score
  //     team_two.total_points += team_two_score
  //     team_one_score > team_two_score ? team_one.wins += 1 : team_two.wins += 1
  //   end

  //   # "Final score: #{team_one.name} #{team_one_score}, #{team_two.name} #{team_two_score}"

  //   unless team_one.wins == team_two.wins
  //     winning_team = team_one.wins > team_two.wins ? team_one : team_two
  //   end
  //   # projected_line = (team_one.margin < 0 ? team_one.margin * -1 : team_one.margin) / 200.0
  //   margin = ((team_one.total_points - team_two.total_points) / 200.0)
  //   # pluralize "games"
  //   "#{team_one.name} won #{team_one.wins} games. #{team_two.name} won #{team_two.wins} games." \
  //   "\nProjected winner: #{winning_team ? winning_team.name : 'Too close to call'}" \
  //   "\nConfidence: #{winning_team ? (winning_team.wins / 4) : 100}%" \
  //   "\nAverage margin of victory: #{(margin > 0 ? margin : margin * -1).round(1)} points" \
  //   "\nO/U: #{(team_one.total_points + team_two.total_points) / 400}"
  // end

function compareStrengths(teamOne, teamTwo) {
  // var teams = [teamOne, teamTwo];
  // var comparisons = {
  //   passOffvsDef: [],
  //   runOffvsDef: [],
  //   specialTeams: [teamOne.spTeams - teamTwo.spTeams],
  //   lundgren: [teamOne.lundgren - teamTwo.lundgren]
  // };
  // for (var i = 0; i <= 1; i++) {
  //   var curTeam = teams[i];
  //   var otherTeam = teams[i === 0 ? 1 : 0];
  //   comparisons.passOffvsDef.push(curTeam.passOff - otherTeam.passDef);
  //   console.log(comparisons);
  // }
}

function SimGame( teamOne, teamTwo, gamesNum) {
  var teamOneScore;
  var teamTwoScore;
  // default number of games is 400
  gamesNum = gamesNum || 100;
  // res
  teamOne.wins = 0;
  teamTwo.wins = 0;
  // simulate x amount of games
  for (var games = 0; games < gamesNum; games++) {
    teamOneScore = 0;
    teamTwoScore = 0;
    // ten possesions for each team
    for (var possesions = 0; possesions < 13; possesions++) {
      teamOneScore += teamOne.driveAgainst( teamTwo );
      teamTwoScore += teamTwo.driveAgainst( teamOne );
    }
    // OVERTIME
    if ( teamOneScore == teamTwoScore ) {
      // console.log('overtime at ' + teamOneScore + '-' + teamTwoScore);
      while (teamOneScore == teamTwoScore) {
        teamOneScore += teamOne.driveAgainst( teamTwo );
        teamTwoScore += teamTwo.driveAgainst( teamOne );
      }
      // console.log('overtime done at ' + teamOneScore + '-' + teamTwoScore);
    }
    // add to respective team's win number
    teamOne.totalPoints.push(teamOneScore);
    teamTwo.totalPoints.push(teamTwoScore);
    if (teamOneScore > teamTwoScore)
      teamOne.wins += 1;
    else
      teamTwo.wins += 1;
  }
  // console.log(teamOne.teamName + ' : ' + teamOne.wins + ', ' + teamTwo.teamName + ' : ' + teamTwo.wins);
  // return teamOne.teamName + ' : ' + teamOne.wins + ', ' + teamTwo.teamName + ' : ' + teamTwo.wins;
  // console.log(teamOne.totalPoints);
  return [teamOne.wins, 
      teamTwo.wins,
      teamOne.totalPoints.average(),
      teamTwo.totalPoints.average(),
      teamOne.totalPoints.median(),
      teamTwo.totalPoints.median()
    ];
}

function Team( teamName, rat ){
  this.teamName = teamName; 
  this.overall = rat[0];
  this.runOff = rat[1];
  this.passOff = rat[2];
  this.runDef = rat[3];
  this.passDef = rat[4];
  this.spTeams = rat[5];
  this.lundgren = rat[6];
  this.qualityPPG = rat[8];
  this.totalPoints = [];
  Team.prototype.driveAgainst = function( opponent ){
    var teamMagic = (this.qualityPPG * 5 + this.lundgren) / (Math.random() * 10 + 10);
    var oppMagic = (opponent.qualityPPG * 5 + opponent.lundgren) / (Math.random() * 10 + 10);
    // console log the magic for debugging
    // console.log(this.teamName + ' magic: ' + teamMagic + ', ' + opponent.teamName + ' magic: ' + oppMagic);

    var teamRand = Math.random();
    var oppRand  = Math.random();
    var rand23 = teamRand * 2 + 1;
    var rand26 = teamRand * 3 + 5;

    if ( (this.runOff / rand23) + teamMagic > oppRand * (opponent.runDef * 3.5) + oppMagic )
      return 7;
    else if ( (this.passOff / rand23) + teamMagic > oppRand * (opponent.passDef * 3.5) + oppMagic )
      return 7;
    else if ( (this.spTeams + teamMagic) / rand26 > oppRand * (opponent.spTeams + oppMagic) )
      return 3;
    else
      return 0;
  };
}

//////////////////  Prototypes & helpers /////////////////////

// returns parent panel for given element
$.fn.extend ({
  getPanelIndex: function(){
    return $(this).parents('.team-panel').index();
  }
});
// returns average number from array of numbers
Array.prototype.average = function (){
  var total = 0;
  this.forEach(function (num) {
    total += num;
  });
  return total / this.length;
};
// returns median number from long array of numbers
Array.prototype.median = function (){
  var middle = Math.round(this.length / 2);
  // sort in order
  this.sort(function(a, b){return a-b;});
  // check if even length
  if (this.length % 2 === 0)
    // if so, return average of middle two
    return (this[middle] + this[middle - 1]) / 2;
  // if odd length
  else
    // return middle num
    return this[middle - 1];
};
