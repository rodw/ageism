var on_dom_ready = function() {
  var default_game = document.getElementById('selected-game').value;

  var initial_player_state = document.getElementById('initial-player').value;
  if(initial_player_state == null || initial_player_state.length == 0) {
    initial_player_state = games[default_game].player;
    document.getElementById('initial-player').value = initial_player_state;
  }
  eval("var player_state = "+initial_player_state);

  var game_def = document.getElementById('game-def').value;
  if(game_def == null || game_def.length == 0) {
    game_def =  games[default_game].game_def;
    document.getElementById('game-def').value = game_def;
  }
  eval("var gamedef = "+game_def);

  datasource = new MockDatasource();
  game = new GameEngine(datasource,gamedef);
  player = null;
  game.create_player(player_state,function(s,m,p) {
    player = p;
    refresh_actions();
  });
  document.getElementById('alert').onclick = hide_alert;

  var body = document.getElementById('main-controls');
  body.classList.add('pulse');
  body.classList.add('animated');
  window.setTimeout( function(){
    body.classList.remove('pulse');
    body.classList.remove('animated');
  },2000);
};

var validate_json = function(str) {
  try {
    JSON.parse(str);
    return true;
  } catch (e) {
    return false;
  }
};

var validate_js = function(str) {
  try {
    eval('(function(){ var ignored = '+str + '})()');
    return true;
  } catch (e) {
    return false;
  }
};

var toggle_element = function(eltid,validate_fn,validate_data_field) {
  var elt = document.getElementById(eltid);
  if(elt.classList.contains('hidden')) {
    if(validate_data_field) { set_revertable(validate_data_field); }
    elt.classList.remove('hidden');
    elt.classList.add('bounceInUp');
    elt.classList.add('animated');
    var wait = window.setTimeout( function(){
      elt.classList.remove('bounceInUp');
      elt.classList.remove('animated');
    },1500);
  } else {
    if(validate_fn && validate_data_field) {
      var data = document.getElementById(validate_data_field).value;
      if(!validate_fn(data)) {
        elt.classList.add('shake');
        elt.classList.add('animated');
        document.getElementById(validate_data_field).select();
        var wait = window.setTimeout( function(){
          elt.classList.remove('shake');
          elt.classList.remove('animated');
        },5000);
        return;
      }
    }
    elt.classList.add('bounceOutDown');
    elt.classList.add('animated');
    var wait = window.setTimeout( function(){
      elt.classList.add('hidden');
      elt.classList.remove('bounceOutDown');
      elt.classList.remove('animated');
    },5000);
  }
};

revertable = {};
var set_revertable = function(eltid) {
  revertable[eltid] = document.getElementById(eltid).value;
};
var revert = function(eltid) {
  document.getElementById(eltid).value = revertable[eltid];
};

var toggle_gamedef_edit = function() { toggle_element('game-def-container',validate_js,'game-def'); };
var toggle_initial_player_edit = function() { toggle_element('initial-player-container',validate_js,'initial-player'); };
var toggle_current_player_edit = function() { toggle_element('current-player-container',validate_js,'current-player'); };

var save_current_player_edit = function() {
  var str = document.getElementById('current-player').value;
  var obj = JSON.parse(str);
  if(obj) {
    obj.id = player.id;
    datasource.save_player(obj,function(status,message,p) { player = p; refresh(200,"",{player:player}); });
  }
};

var load_current_player_edit = function() {
  datasource.get_player(player.id,function(status,message,p) {
    document.getElementById('current-player').value = JSON.stringify(p);
  });
};

var load_game = function(gamename) {
  var game_data = games[gamename];
  document.getElementById('initial-player').value = game_data.player;
  document.getElementById('game-def').value = game_data.game_def;
  on_dom_ready();
};

var alert_new_achievements = function(achievements) {
  var title = document.getElementById('alert-title');
  var headline = 'Achievement unlocked.';
  if(achievements.length != 1) {
    headline = achievements.length + ' achievements unlocked.';
  }
  title.innerHTML = headline;

  var content = document.getElementById('alert-content');
  content.innerHTML = "";
  for(var i=0;i<achievements.length;i++) {
    add_achievement(content,achievements[i],false);
  }
  show_alert();
};

var show_alert = function() {
  var alert = document.getElementById('alert');
  alert.style.display = 'block';
  alert.classList.add('bounceInDown');
  alert.classList.add('animated');
  window.setTimeout( function(){ hide_alert(); } , 1500 );
};

var hide_alert = function() {
  var alert = document.getElementById('alert');
  alert.classList.remove('bounceInDown');
  alert.classList.remove('animated');
  alert.classList.add('bounceOut');
  alert.classList.add('animated');
  window.setTimeout( function(){
    alert.style.display = 'none';
    alert.classList.remove('bounceOut');alert.classList.remove('animated');
  } , 2000 );
};

var refresh = function(status,message,result) {
  if(!result) { result = {}; }
  if(!result.achievements_added) { result.achievements_added = []; }
  refresh_actions();
  refresh_history();
  refresh_achievements(result.achievements_added);
  if(result.achievements_added.length > 0) { alert_new_achievements(result.achievements_added); }
};

var refresh_actions = function() {
  game.get_available_actions(player.id,function(s,m,actions) {
    var div = document.getElementById('actions');
    div.innerHTML = '';
    for(var i=0;i<actions.length;i++) { add_action(div,actions[i]); }
  });
};

var refresh_history = function() {
  var div = document.getElementById('history');
  div.innerHTML = '';
  for(var i=player.history.length;i>0;i--) { add_history(div,player.history[i-1]); }
};

var format_date = function(dt) {
  var now = new Date();
  dt = new Date(dt);
  var delta = now.getTime() - dt.getTime();
  if(delta < 3*1000) {
    return 'just now';
  } else if(delta < 46*1000) {
    return Math.round(delta/(1000)) + ' seconds ago';
  } else if(delta < 2*60*1000) {
    return 'a minute ago';
  } else if(delta < 45*60*1000) {
    return Math.round(delta/(60*1000)) + ' minutes ago';
  } else if(delta < 90*60*1000) {
    return 'an hour ago';
  } else if(delta < 24*60*60*1000) {
    return Math.round(delta/(60*60*1000)) + ' hours ago';
  } else if(delta < 48*60*60*1000) {
    return 'yesterday';
  } else if(delta < 360*24*60*60*1000) {
    return Math.round(delta/(24*60*60*1000)) + ' days ago';
  } else if(delta < 365*24*60*60*1000) {
    return 'a year ago';
  } else {
    return Math.round(delta/(364*24*60*60*1000)) + ' years ago';
  }
};

var refresh_achievements = function(new_achievements) {
  var div = document.getElementById('achievements');
  div.innerHTML = '';
  for(var i=player.achievements.length-1;i>=0;i--) {
    var is_new = AgeismUtil.contains_id(new_achievements,player.achievements[i].achievement_type_id);
    add_achievement(div,player.achievements[i],true,is_new);
  }
};

var add_history = function(parent,entry) {
  parent.innerHTML = parent.innerHTML + "\
<p>\
<span class='label'>"+entry.labeled+"</span>\
 \
<span class='ts'>"+format_date(entry.timestamp)+"</span>\
</p>";
};

var add_achievement = function(parent,entry,showTimestamp,isnew) {
  var classname = ""
  if(isnew) {
    classname = 'newly-achieved'
  }
  var message = "<p class='"+classname+"'>"
  if(entry.icon != null) {
    message += "<img src='"+entry.icon+"' width='24' height='24'>&nbsp; &nbsp;"
  }
  message += "<span class='label'>"+entry.label+"</span>";
  if(showTimestamp == null || showTimestamp) {
    message += " <span class='ts'>"+format_date(entry.timestamp)+"</span>."
  }
  message += "</p>";
  parent.innerHTML = parent.innerHTML + message
}

var add_action = function(parent,action) {
  p = document.createElement('p');
  if(action.icon != null) {
    p.innerHTML += "<img src='"+action.icon+"' width='24' height='24'>&nbsp; &nbsp;";
  }
  a = document.createElement('a');
  a.href = '#';
  a['data-action-id'] = action.id;
  a.onclick = function(e) { game.post_action(player.id,this['data-action-id'],{},refresh); };
  a.appendChild(document.createTextNode(action.label));
  p.appendChild(a);
  parent.appendChild(p);
};

var bootstrap = function() {
  var _this = this;
  if ((typeof domready !== "undefined" && domready !== null) && typeof domready === 'function') {
    return domready(this.on_dom_ready);
  } else if ((typeof $ !== "undefined" && $ !== null) && typeof $ !== 'undefined' && (($(document).ready) != null)) {
    return $(document).ready(this.on_dom_ready);
  } else if (document.addEventListener != null) {
    return document.addEventListener("DOMContentLoaded", this.on_dom_ready, false);
  } else if (document.attachEvent != null) {
    return document.attachEvent("onreadystatechange", this.on_dom_ready);
  } else if (window.onload == null) {
    return window.onload = this.on_dom_ready;
  } else {
    return setTimeout((function() {
      return _this.on_dom_ready();
    }), 2000);
  }
}
bootstrap();
