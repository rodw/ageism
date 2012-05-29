# # MockDatasource
# is an in-memory implentation of a data source for the AGEISM module.

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

# `MockDatasource` implements the generic AGEISM data source
# interface methods:
#
# - `save_player(player,callback)`
# - `get_player(player_id,callback)`
#
# See the method definitions below for more detail.

# ## `MockDatasource`
class MockDatasource
  constructor:()->
    @players = {}

  # ### `save_player`
  # "upserts" the given `player` instance into the datastore.
  #
  # The `callback` method should accept the following parameters:
  #
  # 1. a status code (numeric)
  # 2. a human-readable status message (string)
  # 3. the newly saved player, which *may* be a distinct object
  #    from the original `player` argument and *may* be `null`
  #    if an error occured.
  save_player:(player,callback)->
    player = util.clone(player)
    if player.id?
      status = sc.OK
    else
      player.id = util.count(@players)
      status = sc.CREATED
    @players[player.id] = player
    callback status, "Player #{player.id} saved", player

  # ### `get_player`
  # fetches the player object with the given `player_id`
  # from the datastore.
  #
  # The `callback` method should accept the following parameters:
  #
  # 1. a status code (numeric)
  # 2. a human-readable status message (string)
  # 3. the fetched player object, which *may* be `null`
  #    if an error occured.
  get_player:(player_id,callback)->
    player = @players[player_id]
    if player?
      callback(sc.OK,"Player #{player_id} found.",player)
    else
      callback(sc.NOT_FOUND,"Player #{player_id} not found.")

# We "export" the module in node.js and browser friendly way.
exports = exports ? this
exports.MockDatasource = MockDatasource
