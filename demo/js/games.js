// four_square =  {
//   player: {id:'demo-player',checkins:{}},
//   game_def:
// {
//   actions: [
//     { id:'at_starbucks', label:'Check-in at Starbucks.', labeled:'Checked-in at Starbucks', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },
//     { id:'at_whole_foods', label:'Check-in at Whole Foods.', labeled:'Checked-in at Whole Foods', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },
//     { id:'at_eiffel_tower', label:'Check-in at Eiffel Tower.', labeled:'Checked-in at Eiffel Tower', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },
//     { id:'at_big_ben', label:'Check-in at Big Ben.', labeled:'Checked-in at Big Ben', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },
//     { id:'at_washington_monument', label:'Check-in at Washington Monument.', labeled:'Checked-in at Washington Monument', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },
//     { id:'at_golden_gate_bridge', label:'Check-in at Golden Gate Bridge.', labeled:'Checked-in at Golden Gate Bridge', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } }
//   ],
//   achievements: [
//     {
//       id:'newbie', label:'Newbie Badge', icon:'./img/star-32x32.png',
//       conditions: [
//         { predicate: function(player, action, data, achievement) { return player.history.length >= 1; } },
//         { predicate: AgeismUtil.predicates.one_time_achievement }
//       ]
//     }, {
//       id:'bi-coastal', label:'Bi-Coastal Badge', icon:'./img/star-32x32.png',
//       conditions: [
//         {
//           predicate: function(player, action, data, achievement) {
//             return player.checkins.at_washington_monument > 0 && player.checkins.at_golden_gate_bridge > 0;
//           }
//         },
//         {
//           predicate: AgeismUtil.predicates.one_time_achievement
//         }
//       ]
//     }, {
//       id:'globe-trotter', label:'Globe Trotter', icon:'./img/star-32x32.png',
//       conditions: [
//         {
//           predicate: function(player, action, data, achievement) {
//             return (player.checkins.at_washington_monument > 0 || player.checkins.at_golden_gate_bridge > 0) &&
//                    (player.checkins.at_big_ben > 0 || player.checkins.at_eiffel_tower > 0);
//           }
//         },
//         {
//           predicate: AgeismUtil.predicates.one_time_achievement
//         }
//       ]
//     }, {
//       id:'tourist', label:'Tourist', icon:'./img/star-32x32.png',
//       conditions: [
//         {
//           predicate: function(player, action, data, achievement) {
//             return player.checkins.at_washington_monument > 0 && player.checkins.at_golden_gate_bridge > 0 &&
//                    player.checkins.at_big_ben > 0 && player.checkins.at_eiffel_tower > 0;
//           }
//         },
//         {
//           predicate: AgeismUtil.predicates.one_time_achievement
//         }
//       ]
//     }
//   ]
// }
// };
var games = {
  simple: {
    player: "{id:'demo-player'}",
    game_def: "\
{\n\
  actions: [\n\
    { id:'do-something', label:'Do something.', labeled:'Did something' },\n\
    { id:'do-something-else', label:'Do something else.', labeled:'Did something else' }\n\
  ],\n\
  achievements: [\n\
    {\n\
      id:'did-some', label:'You did some things', icon:'./img/star-32x32.png',\n\
      conditions: [\n\
        { predicate: function(player, action, data, achievement) { return player.history.length >=3 && player.history.length%3==0; } }\n\
      ]\n\
    }, {\n\
      id:'did-more', label:'You did more things', icon:'./img/heart-32x32.png',\n\
      conditions: [\n\
        { predicate: function(player, action, data, achievement) { return player.history.length >= 10; } },\n\
        { predicate: AgeismUtil.predicates.one_time_achievement }\n\
      ]\n\
    }\n\
  ]\n\
}\n"
  },
  complex: {
    player: "\
{\n\
  id:'demo-player',      \n\
  red_box:'closed',      \n\
  blue_box:'closed',     \n\
  yellow_box:'hidden',   \n\
  light_bulb:'off',      \n\
  bell:false,            \n\
  key:'not-found',       \n\
  red_button_presses: 0, \n\
  red_button: true,      \n\
  cookie_in_jar: true,   \n\
  cookie_jar: 'closed'   \n\
}",
    game_def: "\
{\n\
  actions: [\n\
    {\n\
      id:'ring-bell', label: 'Ring the bell.', labeled:'Rang the bell',\n\
      prerequisites:[ { predicate:function(player,action){ return player.bell == true; } } ]\n\
    },\n\
    {\n\
      id:'press-red-button', label: 'Press the red button.', labeled:'Pressed the red button',\n\
      on_performed:function(p,a,d) { p.red_button_presses += 1; },\n\
      prerequisites:[ { predicate:function(player,action){ return player.red_button; } } ]\n\
    },\n\
    {\n\
      id:'press-blue-button', label: 'Press the blue button.', labeled:'Pressed the blue button',\n\
      on_performed:function(p,a,d) { if(p.cookie_jar == 'closed') { p.cookie_in_jar = true; } }\n\
    },\n\
    {\n\
      id:'open-cookie-jar', label: 'Open the cookie jar.', labeled:'Opened the cookie jar',\n\
      on_performed:function(p,a,d) { p.cookie_jar = 'open'; },\n\
      prerequisites:[ { predicate:function(player,action){ return player.cookie_jar == 'closed'; } } ]\n\
    },\n\
    {\n\
      id:'close-cookie-jar', label: 'Close the cookie jar.', labeled:'Closed the cookie jar',\n\
      on_performed:function(p,a,d) { p.cookie_jar = 'closed'; },\n\
      prerequisites:[ { predicate:function(player,action){ return player.cookie_jar == 'open'; } } ]\n\
    },\n\
    {\n\
      id:'open-red', label: 'Open the red box.', labeled:'Opened the red box',\n\
      on_performed:function(p,a,d) { p.red_box = 'open'; },\n\
      prerequisites:[ { predicate:function(player,action){ return player.red_box == 'closed'; } } ]\n\
    },\n\
    {\n\
      id:'close-red', label: 'Close the red box.', labeled:'Closed the red box',\n\
      on_performed:function(p,a,d) { p.red_box = 'closed'; },\n\
      prerequisites:[ {predicate:function(player,action){ return player.red_box == 'open'; } } ]\n\
    },\n\
    {\n\
      id:'open-blue', label: 'Open the blue box.', labeled:'Opened the blue box',\n\
      on_performed:function(p,a,d) { p.blue_box = 'open'; if(p.yellow_box == 'hidden') { p.yellow_box = 'closed'; } },\n\
      prerequisites:[ { predicate:function(player,action){ return player.blue_box == 'closed'; } } ]\n\
    },\n\
    {\n\
      id:'close-blue', label: 'Close the blue box.', labeled:'Closed the blue box',\n\
      on_performed:function(p,a,d) { p.blue_box = 'closed'; p.yellow_box = 'hidden'; },\n\
      prerequisites:[ { predicate:function(player,action){ return player.blue_box == 'open'; } } ]\n\
    },\n\
    {\n\
      id:'open-yellow', label: 'Open the yellow box.', labeled:'Opened the yellow box',\n\
      on_performed:function(p,a,d) { p.yellow_box = 'open'; },\n\
      prerequisites:[ { predicate:function(player,action){ return player.yellow_box == 'closed'; } } ]\n\
    },\n\
    {\n\
      id:'close-yellow', label: 'Close the yellow box.', labeled:'Closed the yellow box',\n\
      on_performed:function(p,a,d) { p.yellow_box = 'closed'; },\n\
      prerequisites:[ { predicate:function(player,action){ return player.yellow_box == 'open'; } } ]\n\
    }\n\
  ],\n\
  achievements: [\n\
    {\n\
      id: 'found-bell', label: 'You found a bell', icon: './img/bell-32x32.png',\n\
      conditions: [\n\
        { predicate: function(player, action, data, achievement) { return player.yellow_box == 'open'; } },\n\
        { predicate: AgeismUtil.predicates.one_time_achievement }\n\
      ],\n\
      on_achieved: function(player,achievement) { player.bell = true; }\n\
    },\n\
    {\n\
      id: 'found-yellow-box', label: 'You found the yellow box', icon: './img/box-32x32.png',\n\
      conditions: [\n\
        { predicate: function(player, action, data, achievement) { return player.yellow_box != 'hidden'; } },\n\
        { predicate: AgeismUtil.predicates.one_time_achievement }\n\
      ],\n\
      on_achieved: function(player,achievement) { player.yellow_box = 'closed'; }\n\
    },\n\
    {\n\
      id: 'found-gold-star', label: 'You earned a gold star', icon: './img/star-32x32.png',\n\
      conditions: [\n\
        {\n\
          predicate: function(player, action, data, achievement) {\n\
            count = AgeismUtil.count_matching(player.history,'ring-bell','action_type_id');\n\
            return (count >= 3 && count%3 == 0);\n\
          }\n\
        },\n\
        { predicate: AgeismUtil.predicates.higher_order.n_time_achievement(3) }\n\
      ]\n\
    },\n\
    {\n\
      id: 'found-cookie', label: 'You found a cookie', icon: './img/cookie-32x32.png',\n\
      conditions: [\n\
        { predicate: function(player, action, data, achievement) { return (player.cookie_in_jar && player.cookie_jar == 'open'); } }\n\
      ],\n\
      on_achieved: function(player,achievement) { player.cookie_in_jar = false; }\n\
    },\n\
    {\n\
      id: 'broke-red-button', label: 'You broke the red button.', icon: './img/heart-32x32.png',\n\
      conditions: [\n\
        { predicate: function(player, action, data, achievement) { return player.red_button_presses >= 55; } },\n\
        { predicate: AgeismUtil.predicates.one_time_achievement }\n\
      ],\n\
      on_achieved: function(player,achievement) { player.red_button = false; }\n\
    },\n\
    {\n\
      id: 'earned-heart', label: 'You earned a heart', icon: './img/heart-32x32.png',\n\
      conditions: [\n\
        {\n\
          predicate: function(player, action, data, achievement) {\n\
            if(action.id != 'press-red-button') { return false; }\n\
            switch(player.red_button_presses) {\n\
              case 3: return true;\n\
              case 5: return true;\n\
              case 8: return true;\n\
              case 13: return true;\n\
              case 21: return true;\n\
              case 34: return true;\n\
              default: return false;\n\
            }\n\
          }\n\
        }\n\
      ]\n\
    },\n\
    {\n\
      id: 'broke-the-bell', label: 'You broke the bell', icon:'./img/broken-bell-32x32.png',\n\
      conditions: [\n\
        { predicate: function(player, action, data, achievement) { var count = AgeismUtil.count_matching(player.history,'ring-bell','action_type_id'); return (count >= 12); } },\n\
        { predicate: AgeismUtil.predicates.one_time_achievement }\n\
      ],\n\
      on_achieved: function(player,achievement) { player.bell = false; }\n\
    },\n\
    {\n\
      id: 'found-key', label: 'You found a key', icon: './img/key-32x32.png',\n\
      conditions: [\n\
        { predicate: function(player, action, data, achievement) { return player.key == 'found'; } },\n\
        { predicate: AgeismUtil.predicates.one_time_achievement }\n\
      ]\n\
    }\n\
  ]\n\
}"
   },

four_square: {
  player: "{id:'demo-player',checkins:{}}",
  game_def:"\
{\n\
  actions: [\n\
    { id:'at_starbucks', label:'Check-in at Starbucks.', labeled:'Checked-in at Starbucks', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },\n\
    { id:'at_whole_foods', label:'Check-in at Whole Foods.', labeled:'Checked-in at Whole Foods', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },\n\
    { id:'at_eiffel_tower', label:'Check-in at Eiffel Tower.', labeled:'Checked-in at Eiffel Tower', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },\n\
    { id:'at_big_ben', label:'Check-in at Big Ben.', labeled:'Checked-in at Big Ben', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },\n\
    { id:'at_washington_monument', label:'Check-in at Washington Monument.', labeled:'Checked-in at Washington Monument', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } },\n\
    { id:'at_golden_gate_bridge', label:'Check-in at Golden Gate Bridge.', labeled:'Checked-in at Golden Gate Bridge', on_performed:function(player,action) { (player.checkins[action.id]) = (player.checkins[action.id]) ? (player.checkins[action.id])+1 : 1; } }\n\
  ],\n\
  achievements: [\n\
    {\n\
      id:'newbie', label:'Newbie Badge', icon:'./img/star-32x32.png',\n\
      conditions: [\n\
        { predicate: function(player, action, data, achievement) { return player.history.length >= 1; } },\n\
        { predicate: AgeismUtil.predicates.one_time_achievement }\n\
      ]\n\
    }, {\n\
      id:'bi-coastal', label:'Bi-Coastal Badge', icon:'./img/star-32x32.png',\n\
      conditions: [\n\
        {\n\
          predicate: function(player, action, data, achievement) {\n\
            return player.checkins.at_washington_monument > 0 && player.checkins.at_golden_gate_bridge > 0;\n\
          }\n\
        },\n\
        {\n\
          predicate: AgeismUtil.predicates.one_time_achievement\n\
        }\n\
      ]\n\
    }, {\n\
      id:'globe-trotter', label:'Globe Trotter', icon:'./img/star-32x32.png',\n\
      conditions: [\n\
        {\n\
          predicate: function(player, action, data, achievement) {\n\
            return (player.checkins.at_washington_monument > 0 || player.checkins.at_golden_gate_bridge > 0) &&\n\
                   (player.checkins.at_big_ben > 0 || player.checkins.at_eiffel_tower > 0);\n\
          }\n\
        },\n\
        {\n\
          predicate: AgeismUtil.predicates.one_time_achievement\n\
        }\n\
      ]\n\
    }, {\n\
      id:'tourist', label:'Tourist', icon:'./img/star-32x32.png',\n\
      conditions: [\n\
        {\n\
          predicate: function(player, action, data, achievement) {\n\
            return player.checkins.at_washington_monument > 0 && player.checkins.at_golden_gate_bridge > 0 &&\n\
                   player.checkins.at_big_ben > 0 && player.checkins.at_eiffel_tower > 0;\n\
          }\n\
        },\n\
        {\n\
          predicate: AgeismUtil.predicates.one_time_achievement\n\
        }\n\
      ]\n\
    }, {\n\
      id:'errand-runner', label:'Errand Runner', icon:'./img/star-32x32.png',\n\
      conditions: [\n\
        {\n\
          predicate: function(player, action, data, achievement) {\n\
            return player.checkins.at_starbucks > 0 && player.checkins.at_whole_foods > 0;\n\
          }\n\
        },\n\
        {\n\
          predicate: AgeismUtil.predicates.one_time_achievement\n\
        }\n\
      ]\n\
    }, {\n\
      id:'mayor-of-starbucks', label:'Mayor of Starbucks', icon:'./img/star-32x32.png',\n\
      conditions: [\n\
        {\n\
          predicate: function(player, action, data, achievement) {\n\
            return player.checkins.at_starbucks > 7;\n\
          }\n\
        },\n\
        {\n\
          predicate: AgeismUtil.predicates.one_time_achievement\n\
        }\n\
      ]\n\
    }\n\
  ]\n\
}"
}
};
