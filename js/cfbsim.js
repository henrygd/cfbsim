// global ready function grabs team ratings, checks if logos are cached,
// fetches & stores them if not, then runs supplied callback
// (scalable for additional content like team pages, computer poll, etc.)
function globalOnLoad(cb){
  // show loading icon
  $('body').addClass('loading');
  function clear() {$('body').removeClass('loading');}
  // get team rankings
  $.getScript('js/teamRatings/teamratings.js')
    .fail(function() {
      clear();
      alert('Error: Could not fetch team rankings. Please try again later.');
    })
    .done(function() {
      // check if team logos are pre-cached in localStorage
      if ( localStorage !== null && localStorage.logo_Michigan ){
        // go on with loading the page
        setTimeout(function() {
          clear();
          cb();
        }, 300);
      }
      else {
        // check if localstorage can be used
        if ( localStorage !== null ){
          // get logos
          $.getScript('js/teamLogoScript/teamLogos.js').done(function() {
            setTimeout(function() {
              clear();
              cb();
            }, 1000);
          });
        }
        // if no local storage alert error
        else {
          clear();
          alert('To use this website, please download a browser that supports local storage (Chrome, Opera, Safari, Firefox, etc.)');
        }
      }
    });
}

var cfbSim = {
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
          nextTeam = cfbSim.curTeams[0].nextAll('li').eq(0);
          if (nextTeam.length > 0)
            cfbSim.changeTeam(nextTeam, 0);
          break;
        // left arrow to get previous team
        case 37:
          prevTeam = cfbSim.curTeams[0].prevAll('li').eq(0);
          if (prevTeam.length > 0)
            cfbSim.changeTeam(prevTeam, 0);
          break;
        // down arrow to get next team
        case 40:
          nextTeam = cfbSim.curTeams[1].nextAll('li').eq(0);
          if (nextTeam.length > 0)
            cfbSim.changeTeam(nextTeam, 1);
          break;
        // up arrow to get previous team
        case 38:
          prevTeam = cfbSim.curTeams[1].prevAll('li').eq(0);
          if (prevTeam.length > 0)
            cfbSim.changeTeam(prevTeam, 1);
          break;
        // enter
        case 13:
          e.preventDefault();
          if ( !$('#results_container').hasClass('show-results') )
            cfbSim.startSim();
          break;
        // exit
        case 27:
          cfbSim.closeSim();
          break;
        // r for random matchup
        case 82:
          cfbSim.randomTeam([0, 1]);
          break;
        default:
          break;
      }
    });

    // logo image load binding to get logo color / change matchup text
    $('img.logo').on('load', function(){
      cfbSim.imageLoad( this, $(this).getPanelIndex() );
    });
    // random team button binding
    $('.random-btn').on('click', function(){
      cfbSim.randomTeam([$(this).getPanelIndex()]);
    });
    // show dropdown team menu binding
    $('.name-container').on('click', function(){
      $(this.parentElement).toggleClass('select-active');
    });

    // start game simulation presentation on btn click
    $('.btn-sim').on('click', function(){
      cfbSim.startSim();
    });

    // close game results popup
    $('#close_results_btn').on('click', function(){
      cfbSim.closeSim();
    });

    // set popstate to load url teams
    window.addEventListener('popstate', function(event) {
      // console.log('popstate fired!');
      cfbSim.loadURLTeams();
    });

    // initialize drop down team selection menu
    cfbSim.dropDown.initialize();
    // find teams or assign random teams on page load
    if (window.location.hash.length > 0)
      cfbSim.loadURLTeams();
    else
      cfbSim.randomTeam([0, 1]);
    // fade in elements on page load
    $('body').removeClass('hide-elements');
  },

  // load teams if specified in url 
  loadURLTeams: function() {
    var teams = window.location.hash.replace('#', '').split('_vs_');
    var teamOne = decodeURI(teams[0]);
    var teamTwo = decodeURI(teams[1]);
    var teamList = Object.keys(TeamRatings);
    var teamCount = 0;
    teamList.forEach(function(thisTeam, index) {
      if (thisTeam === teamOne) {
        cfbSim.changeTeam($(cfbSim.teamNodelist[index]), 0);
        teamCount += 1;
      }
      else if (thisTeam === teamTwo) {
        cfbSim.changeTeam($(cfbSim.teamNodelist[index]), 1);
        teamCount += 1;
      }
    });
    if (teamCount < 2)
      cfbSim.randomTeam([0, 1]);
    else
      document.title = ('CFB SIM | ' + teamOne + ' vs ' + teamTwo);
  },

  // set random teams on page load
  randomTeam: function( arr ){
    $(arr).each(function( index ){
      var team = cfbSim.teamNodelist.eq( ~~(Math.random() * 128) );
      // cfbSim.teamOne = team;
      cfbSim.changeTeam( team, arr[index] );
    });
  },

  imageLoad: function( img, index ){
    var team = img.getAttribute('team');
    var teamColor = localStorage['color_' + team] || cfbSim.getLogoColor(img, team);
    var teamText = $('.team-matchup').find('h2').eq(index);
    var overall = $('.overall').eq(index);
    var selectBox = $('.custom-select').eq(index);
    var fullColor = 'rgb(' + teamColor + ')';
    var overallColor = 'rgba(' + cfbSim.getRatingColor(TeamRatings[team][0]) + ', .8)';
    overall.css('background-color', overallColor);
    selectBox.css('background-color', 'rgb(' + teamColor + ')');
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
      var meterColor = cfbSim.getRatingColor(rating);
      $(meterText[index]).text(rating);
      if (rating < 10 )
        rating = '0' + rating;
      $(meters[index -1]).css({'background-color': 'rgb(' + meterColor + ')',
                         '-webkit-transform': 'scale3d(.' + rating + ', 1, 1)',
                         'transform': 'scale3d(.' + rating + ', 1, 1)'});
    });
    // find comparative strengths and adjust meters
    cfbSim.compareStrengths();
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
    return colorString;
  },

  changeTeam: function( team, index ){
    this.curTeams[index] = team;
    var teamName = team.text();
    var dropDown = $('.custom-select').eq(index);
    dropDown.find('.name-container span').text(teamName);
    cfbSim.changeLogo(teamName, index);
    cfbSim.adjustMeters(teamName, index);
    dropDown.removeClass('select-active');
  },

  startSim: function(){
    // clear close timeout
    clearTimeout(cfbSim.closeTimeout);
    // function to display count of games being simulated
    var counter = (function() {
      var count = 0;
      var el = $('#sim_bar').find('.counter')[0];
      return function() {
        if (count < 500) {
          count += 10;
          el.innerHTML = count;
          setTimeout(counter, 33);
        }
      };
    })();
    // sim game and add results
    var teamOneName = cfbSim.curTeams[0].text();
    var teamTwoName = cfbSim.curTeams[1].text();
    var teamOne = new Team( teamOneName );
    var teamTwo = new Team( teamTwoName );
    var numGames = 500;
    var result = SimGame(teamOne, teamTwo, numGames);
    var simStats = $('#sim_stats');
    function getColor(team) {
      return 'rgb(' + localStorage['color_' + team] + ')';
    }
    if (result.teamOne.wins === result.teamTwo.wins) {
      simStats.find('.winning-team').text('Too close to call').css('color', '#333');
      simStats.find('.wins').text('Even');
      simStats.find('.winchance').text('50%');
    }
    else {
      var winner = (result.teamOne.wins > result.teamTwo.wins ? result.teamOne : result.teamTwo);
      $('#team_one_bar').css('flex-basis', (result.teamOne.wins / numGames * 100) + '%');
      simStats.find('.winning-team').text(winner.teamName).css('color', getColor(winner.teamName));
      simStats.find('.wins').text(winner.wins + '/' + numGames);
      simStats.find('.winchance').text((winner.wins / numGames * 100).toFixed(1) + '%');
    }

    // fill out results / stats
    simStats.find('.score').html('<span style="color:' + getColor(teamOneName) + '">' + (result.teamOne.totalPoints / numGames).toFixed(1) + '</span> - ' + '<span style="color:' + getColor(teamTwoName) + '">' + Math.round(result.teamTwo.totalPoints / numGames) + '</span>' );

    // put team logo / color on bar display
    $('#team_one_bar, #team_two_bar').each(function(index){
      var team = cfbSim.curTeams[index].text();
      $(this).css({
        'background-color': 'rgba(' + localStorage['color_' + team] + ', 0.5)',
        'background-image': "url('" + 'data:image/png;base64,' + 
            localStorage['logo_' + team.replace(/\W/g, '')] + "')"
      });
    });
    // fade in bar
    $('#results_container').addClass('show-results');
    // show games counter
    counter();
    // drop down results / stats
    ShowStats = setTimeout(function(){
      var ddheight = simStats[0].scrollHeight;
      $('#sim_bar').find('.sim-text').css('opacity', '0');
      $('#sim_stats').css({'max-height': ddheight});
    }, 2500);
  },

  closeSim: function(){
    $('#results_container').removeClass('show-results');
    clearTimeout(ShowStats);
    // $(this).slideUp();
    $('#sim_stats').css({'max-height': '0'});
    cfbSim.closeTimeout = setTimeout(function(){
      $('#sim_bar').find('.sim-text').css('opacity', '1');
      $('#team_one_bar').css('flex-basis', '50%');
    }, 455);
  },

  dropDown: {
    initialize: function(){
      var teamOptions = $('.select-options');
      // store team menu elements
      cfbSim.teamNodelist = $('#team_one_options > li');
      // initialize scrollbar
      Ps.initialize(teamOptions[0]);
      Ps.initialize(teamOptions[1]);
      // team dropropdown click binding
      teamOptions.find('> li').on('click', function(){
        var el = $(this);
        cfbSim.changeTeam( el, el.getPanelIndex() );
      });
    },
  }
};

// compare team ratings to find and display team strengths
cfbSim.compareStrengths = (function() {
  var elOne = $('#compare_team_one');
  var elTwo = $('#compare_team_two');
  var elBundleOne = [elOne, elOne.find('h3'), elOne.find('.meter'), elOne.find('.comp-strength-logo')];
  var elBundleTwo = [elTwo, elTwo.find('h3'), elTwo.find('.meter'), elTwo.find('.comp-strength-logo')];
  var ratings = [
    ['Run Offense', 'Run Defense'],
    ['Pass Offense', 'Pass Defense'],
    ['Run Defense', 'Run Offense'],
    ['Pass Defense', 'Pass Offense'],
    ['Special Teams', 'Special Teams'],
    ['Discipline', 'Discipline']
  ];
  function getLogo(team) {
    return 'url(data:image/png;base64,' + 
                localStorage['logo_' + team.replace(/\W/g, '')] + ')';
  }
  function scale(position, num, team, rating, teamTwo) {
    var el, ratingOne, ratingTwo;
    if (position === 1) {
      ratingOne = ratings[rating][0];
      ratingTwo = ratings[rating][1];
      els = elBundleOne;
    }
    else {
      ratingOne = ratings[rating][1];
      ratingTwo = ratings[rating][0];
      els = elBundleTwo;
    }
    els[3].css('background-image', getLogo(team));
    if (num <= 0)
      els[1].html(' ¯\\_(ツ)_/¯');
    else {
      els[1].html('<span>' + '+' + num + '</span> <i>' + ratingOne + '</i> vs <i style="background-image:' + getLogo(teamTwo) + '">' + ratingTwo + '</i>');
    }
    num = num < 50 ? num *= 2 : 99;
    if (num < 10)
      num = '0' + num;
    els[2].css({'-webkit-transform': 'scale3d(.' + num + ', 1, 1)',
            'transform': 'scale3d(.' + num + ', 1, 1)'});
  }
  // return closure to use above vars / functions
  return function() {
    clearTimeout(window.TimeoutCompareStrengths);
    // timout to prevent two calls on simultaneous switch of both teams
    window.TimeoutCompareStrengths = setTimeout(function() {
      var teamOneName = cfbSim.curTeams[0].text();
      var teamTwoName = cfbSim.curTeams[1].text();
      var teamOne = new Team(teamOneName);
      var teamTwo = new Team(teamTwoName);
      var compRats = [
        teamOne.runOff - teamTwo.runDef,
        teamOne.passOff - teamTwo.passDef,
        teamOne.runDef - teamTwo.runOff,
        teamOne.passDef - teamTwo.passOff,
        teamOne.spTeams - teamTwo.spTeams,
        teamOne.discipline - teamTwo.discipline
      ];
      var teamOneStrength = [0, 0];
      var teamTwoStrength = [0, 0];
      // set window location to match teams
      window.location.hash = encodeURI(teamOneName + '_vs_' + teamTwoName);
      // loop through comparative ratings to find largest in favor
      compRats.forEach(function(num, index) {
        if (num > teamOneStrength[1])
          teamOneStrength = [index, num];
        if (num < teamTwoStrength[1])
          teamTwoStrength = [index, num];
      });
      // make changes on page
      scale(1, teamOneStrength[1], teamOneName, teamOneStrength[0], teamTwoName);
      scale(2, (teamTwoStrength[1] * -1), teamTwoName, teamTwoStrength[0], teamOneName);
    }, 50);

  };
}());

// sim game function, team objects
function SimGame( teamOne, teamTwo, gamesNum) {
  var teamOneScore;
  var teamTwoScore;
  // default number of games is 500
  gamesNum = gamesNum || 500;
  // res
  teamOne.wins = 0;
  teamTwo.wins = 0;
  // simulate x amount of games
  for (var games = 0; games < gamesNum; games++) {
    teamOneScore = 0;
    teamTwoScore = 0;
    // ten possesions for each team
    for (var possesions = 0; possesions < 11; possesions++) {
      teamOneScore += teamOne.driveAgainst( teamTwo );
      teamTwoScore += teamTwo.driveAgainst( teamOne );
    }
    // OVERTIME
    if ( teamOneScore == teamTwoScore ) {
      while (teamOneScore == teamTwoScore) {
        teamOneScore += teamOne.driveAgainst( teamTwo );
        teamTwoScore += teamTwo.driveAgainst( teamOne );
      }
    }
    // add to respective team's win number
    teamOne.totalPoints += teamOneScore;
    teamTwo.totalPoints += teamTwoScore;
    if (teamOneScore > teamTwoScore)
      teamOne.wins += 1;
    else
      teamTwo.wins += 1;
  }
  return {
    teamOne: teamOne,
    teamTwo: teamTwo
  };
}

function Team( teamName ){
  var rat = TeamRatings[teamName];
  this.teamName = teamName; 
  this.overall = rat[0];
  this.runOff = rat[1];
  this.passOff = rat[2];
  this.runDef = rat[3];
  this.passDef = rat[4];
  this.spTeams = rat[5];
  this.discipline = rat[6];
  this.qualityPPG = rat[8];
  this.totalPoints = 0;
}
Team.prototype.driveAgainst = function( opponent ){
  var teamMagic = (this.qualityPPG * 7 + this.discipline) / (Math.floor((Math.random() * 20) + 2));
  var oppMagic = (opponent.qualityPPG * 7 + opponent.discipline) / (Math.floor((Math.random() * 20) + 2));
  // console log the magic for debugging
  // console.log(this.teamName + ' magic: ' + teamMagic + ', ' + opponent.teamName + ' magic: ' + oppMagic);

  var teamRand = Math.random();
  var oppRand  = Math.random();
  var rand23 = teamRand * 2 + 1;
  var rand26 = teamRand * 3 + 5;

  if ( ((this.runOff / rand23) + teamMagic) > (oppRand * (opponent.runDef * 3) + oppMagic) )
    return 7;
  else if ( ((this.passOff / rand23) + teamMagic) > (oppRand * (opponent.passDef * 3) + oppMagic) )
    return 7;
  else if ( (this.spTeams + teamMagic) / rand26 > oppRand * (opponent.spTeams + oppMagic) )
    return 3;
  else
    return 0;
};

//////////////////  Prototypes & helpers /////////////////////

// returns parent panel for given element
$.fn.extend ({
  getPanelIndex: function(){
    return $(this).parents('.team-panel').index();
  }
});
// returns average number from array of numbers
// Array.prototype.average = function (){
//   var total = 0;
//   this.forEach(function (num) {
//     total += num;
//   });
//   return total / this.length;
// };
// returns median number from long array of numbers
// Array.prototype.median = function (){
//   var middle = Math.round(this.length / 2);
//   // sort in order
//   this.sort(function(a, b){return a-b;});
//   // check if even length
//   if (this.length % 2 === 0)
//     // if so, return average of middle two
//     return (this[middle] + this[middle - 1]) / 2;
//   // if odd length
//   else
//     // return middle num
//     return this[middle - 1];
// };
