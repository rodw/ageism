# # MongoDatasource
# is an mongodb based a data source for the AGEISM module.

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
  mongodb              = require('mongodb')
# ...and setup the object instances whether we're running under
# node or in a browser.
util = AgeismUtil = AgeismUtil ? this.AgeismUtil
sc = StatusCode = StatusCode ? this.StatusCode
mongodb = mongodb ? this.mongodb
#---------------------------------------------------------------------

class MongoDatasource
  constructor:(dbname,host='localhost',port=27017,options={auto_reconnect:true})->
    @db = new mongodb.Db(dbname, new mongodb.Server(host,port,options))

  teardown: (callback)->
    @db.open (err,db)->
      if err?
        db.close() if db?
        callback sc.ERROR, err
      else
        db.dropCollection 'players', (err,count)->
          db.close() if db?
          if err?
            callback sc.ERROR, err
          else
            callback sc.OK, "#{count} records removed."

  save_player:(player,callback)->
    @db.open (err,db)->
      if err?
        db.close() if db?
        callback sc.ERROR, err
      else
        db.collection 'players', (err,collection)->
          if err?
            db.close() if db?
            callback sc.ERROR, err
          else
            collection.update {id:player.id}, player, {safe:true,upsert:true}, (err,result)->
              if err?
                db.close() if db?
                callback sc.ERROR, err
              else
                db.close() if db?
                callback sc.OK, "Player saved", player

    # @_insert_one 'players', player, callback, (player)->
    #   callback sc.OK, "Player #{player.id} saved", player

  get_player:(player_id,callback)->
    @db.open (err,db)->
      if err?
        db.close() if db?
        callback sc.ERROR, err
      else
        db.collection 'players', (err,collection)->
          if err?
            db.close() if db?
            callback sc.ERROR, err
          else
            collection.findOne {id:player_id}, (error,player)->
              if err?
                db.close() if db?
                callback sc.ERROR, err
              else
                db.close() if db?
                if player? && player.length? && player.length == 1
                  player = player[0]
                if player?
                  callback(sc.OK,"Player #{player_id} found.",player)
                else
                  callback(sc.NOT_FOUND,"Player #{player_id} not found.")

exports = exports ? this
exports.MongoDatasource = MongoDatasource
