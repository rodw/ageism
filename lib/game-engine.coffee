# # GameEngine
# manages a instance of an AGEISM game.

#---------------------------------------------------------------------
# imports
#---------------------------------------------------------------------
# `require` the right module files if we're running under node.js...
IS_NODE = (typeof require != 'undefined' && typeof module != 'undefined')
if IS_NODE
  HOMEDIR              =  "#{__dirname}/.."
  IS_COFFEE            = process.argv[0].indexOf('coffee') >= 0
  IS_INSTRUMENTED      = (require('path')).existsSync("#{HOMEDIR}/lib-cov")
  LIB_DIR              = if IS_INSTRUMENTED then "#{HOMEDIR}/lib-cov" else "#{HOMEDIR}/lib"
  EXT                  = if IS_COFFEE then "coffee" else "js"
  AgeismUtil           = require("#{LIB_DIR}/ageism-util.#{EXT}").AgeismUtil
  StatusCode           = require("#{LIB_DIR}/status-code.#{EXT}").StatusCode

# ...and setup the object instances whether we're running under
# node or in a browser.
util = AgeismUtil = AgeismUtil ? this.AgeismUtil
sc = StatusCode = StatusCode ? this.StatusCode
#---------------------------------------------------------------------
# ## `GameEngine`
class GameEngine

  # `constructor`
  # takes two arguments: a data source and a game definition.
  constructor:(datasource,gamedef)->
    @ds = datasource
    @game = gamedef

  # fields to filterr from  gamedef objects
  private_fields = [ 'conditions','prerequistes' ]

  # `create_player`
  # asynchronously generates a new player with the given `name`
  # and `id`.
  #
  # The `callback` method should accept the following parameters:
  # 1. a status code (numeric)
  # 2. a human readable status message (a string)
  # 3. the newly created player (which *may* be `null` if an error occurs)
  create_player:(data={},callback)->
    player = if data? then util.clone(data) else {}
    if !player.id?
      callback sc.BAD_REQUEST, "id field is required. found #{data}"
    else
      player.history = [] unless data.history?
      player.achievements = [] unless data.achievements?
      @ds.save_player player, (status,message,saved)->
        if sc.is_ok(status)
          callback(sc.CREATED,"Player #{player.id} created.",saved)
        else
          callback(status,message)

  # `get_available_actions`
  # enumerates the actions currently available to the player with
  # the given `player_id`
  #
  # The `callback` method should accept the following parameters:
  # 1. a status code (numeric)
  # 2. a human readable status message (a string)
  # 3. an array of action objects (which *may* be `null` if an error occurs)
  get_available_actions:(player_id,callback)->
    @ds.get_player player_id, (status,message,player)=>
      if !sc.is_ok(status)
        callback(status,message)
      else
        if !player?
          callback(sc.NOT_FOUND,"Player #{player_id} not found.")
        else
          actions = []
          for action in @game.actions
            if @action_is_available(player,action)
              actions.push(util.filtered_clone(action,private_fields))
          callback(sc.OK,"#{actions.length} actions now available to player #{player.id}",actions)


  # `action_is_valid`
  # an internal utility function that tests whether the given `player`
  # can take the given `action`.
  action_is_valid:(player,action,data)->
    if @action_is_available(player,action)
      if action.conditions?
        for cond in action.conditions
          if cond.predicate? && !cond.predicate(player,action,data)
            return false
      return true
    else
      return false

  # `action_is_available`
  # an internal utility function that tests whether the given `action`
  # is available to the given `player`
  action_is_available:(player,action)->
    if action.prerequisites?
      for prereq in action.prerequisites
        if prereq.predicate? && !(prereq.predicate(player,action))
          return false
    return true

  # `achievement_is_achieved`
  # an internal utility function that tests whether the given `achievement`
  # has been unlocked by the given `player` now that the given `action` has
  # been performed.
  achievement_is_achieved:(player,action,data,achievement)->
    if achievement.conditions?
      for cond in achievement.conditions
        if cond.predicate? && !cond.predicate(player,action,data,achievement)
          return false
    return true

  make_history_entry:(action,data)->
    e = util.rename_key(util.filtered_clone(action,private_fields),'id','action_type_id')
    e.data = util.clone(data) if data?
    e.timestamp = new Date()
    return e

  make_achievement_entry:(achievement)->
    achievement = util.rename_key(util.filtered_clone(achievement,private_fields),'id','achievement_type_id')
    achievement.timestamp = new Date()
    return achievement

  # `post_action`
  # a RESTish method for positing an action taken by a player.
  #
  # The `callback` method should accept the following parameters:
  # 1. a status code (numeric)
  # 2. a human readable status message (a string)
  # 3. a "results" hash, containing
  #   - `player`
  #   - `achievements_added` (optional)
  #   - `achievements_removed` (optional)
  #   - `actions_available` (optional)
  post_action:(player_id,action_id,data={},callback)->
    if !callback?
      console.log 'WARNING: no callback method passed to post_action'
    action = util.get_by_id @game.actions, action_id
    if !action?
      callback(sc.NOT_FOUND,"Action #{action_id} not found.")
    else
      @ds.get_player player_id, (status,message,player)=>
        if !sc.is_ok(status)
          callback(status,message)
        else
          if !player?
            return callback(sc.NOT_FOUND,"Player #{player_id} not found.")
          else

            # validate the action
            if !@action_is_valid(player,action,data)
              callback(sc.REJECTED,"A precondition of #{action.id} was not satisifed by player #{player.id}.")
            else
              # execute & record the action
              action.on_performed(player,action,data) if action.on_performed?
              player.history.push @make_history_entry(action,data)
              # look for achievements
              new_achievements = []
              if @game.achievements?
                for achievement in @game.achievements
                  if @achievement_is_achieved(player,action,data,achievement)
                    achievement.on_achieved(player,achievement) if achievement.on_achieved?
                    achievement = @make_achievement_entry(achievement)
                    new_achievements.push achievement
                    player.achievements.push achievement

              @ds.save_player player, (status,message,player)=>
                if !sc.is_ok(status)
                  callback(status,message)
                else
                  @get_available_actions player.id, (status_code,status_message,actions)->
                    callback(sc.CREATED,"Action #{action.id} recorded for player #{player.id}.",{player:player,achievements_added:new_achievements,actions_available:actions})

# We "export" the module in a node.js and browser friendly way.
exports = exports ? this
exports.GameEngine = GameEngine
