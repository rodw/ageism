#---------------------------------------------------------------------
IS_NODE = (typeof require != 'undefined' && typeof module != 'undefined')
if IS_NODE
  should               = require('should')
  HOMEDIR              =  "#{__dirname}/.."
  IS_COFFEE            = process.argv[0].indexOf('coffee') >= 0
  IS_INSTRUMENTED      = (require('path')).existsSync("#{HOMEDIR}/lib-cov")
  LIB_DIR              = if IS_INSTRUMENTED then "#{HOMEDIR}/lib-cov" else "#{HOMEDIR}/lib"
  EXT                  = if IS_COFFEE then "coffee" else "js"
  AgeismUtil           = require("#{LIB_DIR}/ageism-util.#{EXT}").AgeismUtil
  StatusCode           = require("#{LIB_DIR}/status-code.#{EXT}").StatusCode
  MockDatasource       = require("#{LIB_DIR}/mock-datasource.#{EXT}").MockDatasource
  MongoDatasource      = require("#{LIB_DIR}/mongodb-datasource.#{EXT}").MongoDatasource
  GameEngine           = require("#{LIB_DIR}/game-engine.#{EXT}").GameEngine
  mongodb              = require('mongodb')
#---------------------------------------------------------------------
should = should ? this.should
util = AgeismUtil = AgeismUtil ? this.AgeismUtil
sc = StatusCode = StatusCode ? this.StatusCode
GameEngine = GameEngine ? this.GameEngine
DataSource = MockDatasource = MockDatasource ? this.MockDatasource
#DataSource = MongoDatasource = MongoDatasource ? this.MongoDatasource

describe "GameEngine", ->
  afterEach (done)->
    done()

  beforeEach (done)->
    setup = (done)=>
      @ds = new DataSource("ageism-test-db")
      @gamedef = {
        actions: [
          { id: 'action-1', label: 'Action One', prerequisites:[ {predicate:util.predicates.one_time_action} ] },
          { id: 'action-2', label: 'Action Two' },
          { id: 'action-3', label: 'Action Three' }
        ],
        achievements: [
          {
            id: 'newbie',
            label: 'Newbie',
            conditions: [
              { predicate:(player)-> return player.history.length > 0 }
            ]
          },
          {
            id: 'veteran',
            label: 'Veteran',
            conditions: [
              { predicate:(player)-> return player.history.length > 10 }
            ]
          }
        ]
      }
      done()
    if @ds? && @ds.teardown?
      @ds.teardown (status,message)->setup(done)
    else
      setup(done)

  it "exists", (done)->
    should.exist GameEngine
    game = new GameEngine(@ds,@gamedef)
    done()

  it "can create new players", (done)->
    game = new GameEngine(@ds,@gamedef)
    game.create_player {id:1, name:'Test Player'}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      player.id.should.equal 1
      player.name.should.equal 'Test Player'

      game.create_player {id:2, name:'Another Player'}, (status,msg,player)->
        sc.is_ok(status).should.be.ok
        player.id.should.equal 2
        player.name.should.equal 'Another Player'
        done()

  it "can enumerate actions available to player",(done)->
    gamedef = {
      actions: [
        { id: 'action-1', label: 'Action One' },
        { id: 'action-2', label: 'Action Two' },
        { id: 'action-3', label: 'Action Three' }
      ]
    }
    game = new GameEngine(@ds,gamedef)
    game.create_player  {id:1, name:'Test Player'}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      game.get_available_actions player.id, (status,msg,actions)->
        sc.is_ok(status).should.be.ok
        actions.length.should.equal 3
        for action in gamedef.actions
          util.contains_id(actions,action.id).should.be.ok
        done()

  it "only enumerates actions whose prereqs are met",(done)->
     gamedef = {
       actions: [
         { id: 'action-1', label: 'Action One' },
         { id: 'action-2', label: 'Action Two', prerequisites: [ { predicate:(player)->return (player.id % 2 == 0); } ] },
         { id: 'action-3', label: 'Action Three' }
       ]
     }
     game = new GameEngine(@ds,gamedef)
     game.create_player {id:1, name:'Odd Player'}, (status,msg,player)->
       sc.is_ok(status).should.be.ok
       game.get_available_actions player.id, (status,msg,actions)->
         sc.is_ok(status).should.be.ok
         actions.length.should.equal 2
         game.create_player {id:2, name:'Even Player'}, (status,msg,player)->
           sc.is_ok(status).should.be.ok
           game.get_available_actions player.id, (status,msg,actions)->
             sc.is_ok(status).should.be.ok
             actions.length.should.equal 3
             done()

  it "allows actions to be posted",(done)->
    gamedef = {
      actions: [
        { id: 'action-1', label: 'Action One' },
        { id: 'action-2', label: 'Action Two' },
        { id: 'action-3', label: 'Action Three' }
      ]
    }
    starttime = new Date()
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1, name:'Player One'}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      game.post_action player.id, gamedef.actions[0].id, null, (status,msg,result)->
        sc.is_ok(status).should.be.ok
        result.player.history.length.should.equal 1
        result.player.history[0].label.should.equal 'Action One'
        result.player.history[0].timestamp.should.not.be.below starttime
        done()

  it "prohibits actions when prereqs aren't met",(done)->
    gamedef = {
      actions: [
        { id: 'action-1', label: 'Action One' },
        { id: 'action-2', label: 'Action Two', prerequisites: [ { predicate:(player)->return (player.id % 2 == 0); } ] },
        { id: 'action-3', label: 'Action Three' }
      ]
    }
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1, name:'Player One'}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      game.post_action player.id, gamedef.actions[1].id, null, (status,msg,result)->
        sc.is_ok(status).should.not.be.ok
        game.create_player {id:2, name:'Player Two'}, (status,msg,player)->
          sc.is_ok(status).should.be.ok
          game.post_action player.id, gamedef.actions[1].id, null, (status,msg,result)->
            sc.is_ok(status).should.be.ok
            result.player.history.length.should.equal 1
            result.player.history[0].label.should.equal 'Action Two'
            done()

  it "prohibits actions when conditions aren't met",(done)->
    gamedef = {
      actions: [
        { id: 'action-1', label: 'Action One' },
        { id: 'action-2', label: 'Action Two', conditions: [ { predicate:(player)->return (player.id % 2 == 0); } ] },
        { id: 'action-3', label: 'Action Three' }
      ]
    }
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1, name:'Player One'}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      game.post_action player.id, gamedef.actions[1].id, null, (status,msg,result)->
        sc.is_ok(status).should.not.be.ok
        game.create_player {id:2, name:'Player Two'}, (status,msg,player)->
          sc.is_ok(status).should.be.ok
          game.post_action player.id, gamedef.actions[1].id, null, (status,msg,result)->
            sc.is_ok(status).should.be.ok
            result.player.history.length.should.equal 1
            result.player.history[0].label.should.equal 'Action Two'
            done()

  it "awards achievements when earned",(done)->
    gamedef = {
      actions: [ { id: 'x', label: 'The Action' } ],
      achievements: [ {
        id: 1, label: 'acted once',
        conditions: [
          { predicate:util.predicates.one_time_achievement },
          { predicate:(player,action,data,achievement)->return player.history.length >= 1 }
        ]
      }, {
        id: 2, label: 'acted twice',
        conditions: [
          { predicate:util.predicates.one_time_achievement },
          { predicate:(player,action,data,achievement)->return player.history.length >= 2 }
        ]
      }, {
        id: 3, label: 'acted thrice',this_achievement:'has extra data'
        conditions: [
          { predicate:util.predicates.one_time_achievement },
          { predicate:(player,action,data,achievement)->return player.history.length >= 3 }
        ]
      } ]
    }
    starttime = new Date()
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1,name:'Player One'}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      game.post_action player.id, 'x', {}, (status,msg,result)->
        sc.is_ok(status).should.be.ok
        result.achievements_added.length.should.equal 1
        result.achievements_added[0].label.should.equal 'acted once'
        result.player.achievements.length.should.equal 1
        result.player.achievements[0].label.should.equal 'acted once'
        result.player.achievements[0].timestamp.should.not.be.below starttime
        game.post_action player.id, 'x', {}, (status,msg,result)->
          sc.is_ok(status).should.be.ok
          result.achievements_added.length.should.equal 1
          result.achievements_added[0].label.should.equal 'acted twice'
          result.player.achievements.length.should.equal 2
          result.player.achievements[1].label.should.equal 'acted twice'
          result.player.achievements[1].timestamp.should.not.be.below starttime
          game.post_action player.id, 'x', {}, (status,msg,result)->
            sc.is_ok(status).should.be.ok
            result.achievements_added.length.should.equal 1
            result.achievements_added[0].label.should.equal 'acted thrice'
            result.player.achievements.length.should.equal 3
            result.player.achievements[2].label.should.equal 'acted thrice'
            result.player.achievements[2].this_achievement.should.equal 'has extra data'
            result.player.achievements[2].timestamp.should.not.be.below starttime
            done()

  it "prohibits actions when action instance data doesn't meet conditions",(done)->
    gamedef = { actions: [ {
      id: 'x', label: 'The Action',
      conditions: [ { predicate:(player,action,data)->return data.foo } ]
    } ] }
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1, name:'Player One'}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      player.history.length.should.equal 0
      game.post_action player.id, 'x', {foo:true}, (status,msg,result)->
        sc.is_ok(status).should.be.ok
        result.player.history.length.should.equal 1
        game.post_action result.player.id, 'x', {foo:false}, (status,msg,result)->
          sc.is_ok(status).should.not.be.ok
          if result?
            result.player.history.length.should.equal 1
          done()

  it "records action instance data within player state",(done)->
    gamedef = { actions: [ { id: 'x', label: 'The Action' } ] }
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1, name:'Player One'}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      player.history.length.should.equal 0
      game.post_action player.id, 'x', {hello:'player'}, (status,msg,result)->
        sc.is_ok(status).should.be.ok
        result.player.history.length.should.equal 1
        result.player.history[0].action_type_id.should.equal 'x'
        should.exist result.player.history[0].data
        result.player.history[0].data.hello.should.equal 'player'
        done()

  it "tracks extra player data",(done)->
    gamedef = { }
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1, name:'Player One', extra:'data', found:'here'}, (status,msg,player)=>
      sc.is_ok(status).should.be.ok
      player.extra.should.equal 'data'
      player.found.should.equal 'here'
      @ds.get_player player.id, (status,message,player)->
        sc.is_ok(status).should.be.ok
        player.extra.should.equal 'data'
        player.found.should.equal 'here'
        done()

  it "tracks extra action data",(done)->
    gamedef = { actions: [ { id:1,label:'an action',icon:'act.png',foo:'bar'} ] }
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      game.get_available_actions player.id, (status,msg,actions)->
        sc.is_ok(status).should.be.ok
        actions.length.should.equal 1
        actions[0].id.should.equal 1
        actions[0].label.should.equal 'an action'
        actions[0].icon.should.equal 'act.png'
        actions[0].foo.should.equal 'bar'
        done()

  it "can alter player state using achievement.on_achieved",(done)->
    gamedef = {
      actions: [ { id:1,label:'an action' } ],
      achievements: [ {
        id:7, label:'Point Added',
        on_achieved:(player,achievement)->player.points += 1
      } ]
    }
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1,points:0}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      player.points.should.equal 0
      game.post_action player.id, 1, {}, (status,msg,result)->
        sc.is_ok(status).should.be.ok
        result.player.points.should.equal 1
        game.post_action result.player.id, 1, {}, (status,msg,result)->
          sc.is_ok(status).should.be.ok
          result.player.points.should.equal 2
          done()

  it "can alter player state using action.on_performed",(done)->
    gamedef = {
      actions: [ {
        id:1,
        label:'an action',
        on_performed:(player,action)->player.points += 1
      } ]
    }
    game = new GameEngine(@ds,gamedef)
    game.create_player {id:1,points:0}, (status,msg,player)->
      sc.is_ok(status).should.be.ok
      player.points.should.equal 0
      game.post_action player.id, 1, {}, (status,msg,result)->
        sc.is_ok(status).should.be.ok
        result.player.points.should.equal 1
        game.post_action result.player.id, 1, {}, (status,msg,result)->
          sc.is_ok(status).should.be.ok
          result.player.points.should.equal 2
          done()
