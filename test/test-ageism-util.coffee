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
#---------------------------------------------------------------------
should = should ? this.should
util = AgeismUtil = AgeismUtil ? this.AgeismUtil

describe "AgeismUtil",()->

  it 'exists',(done)->
    should.exist util
    done()

  it 'contains_id looks for elements with the specified key-value pair',(done)->
    util.contains_id( [ {a:1},{b:1},{a:2},{c:2} ], 2, 'a' ).should.be.ok
    util.contains_id( [ {a:1},{b:1},{a:2},{c:2} ], 2, 'c' ).should.be.ok
    util.contains_id( [ {a:1},{b:1},{a:2},{c:2} ], 3, 'a' ).should.not.be.ok
    util.contains_id( [ {a:1},{b:1},{a:2},{c:2} ], 2, 'b' ).should.not.be.ok
    util.contains_id( [ {a:1},{b:1},{a:2},{c:2} ], 1, 'x' ).should.not.be.ok
    done()

  it 'contains_id responds gracefully to funny input',(done)->
    util.contains_id( [], 2, 'a' ).should.not.be.ok
    util.contains_id( null, 2, 'c' ).should.not.be.ok
    util.contains_id( {a:7}, 3, 'a' ).should.not.be.ok
    util.contains_id( console.log, 3, 'a' ).should.not.be.ok
    done()

  it 'contains_id looks for "id" by default',(done)->
    util.contains_id( [ {a:1},{b:1},{a:2},{c:2} ], 2 ).should.not.be.ok
    util.contains_id( [ {id:1},{id:1},{id:2},{id:2} ], 1 ).should.be.ok
    util.contains_id( [ {id:1},{id:1},{id:2},{id:2} ], 2 ).should.be.ok
    util.contains_id( [ {id:1},{id:1},{id:2},{id:2} ], 3 ).should.not.be.ok
    done()

  it 'count_matching countselements with the specified key-value-pair',(done)->
    util.count_matching( [ {a:2},{b:1},{a:2},{c:2} ], 2, 'a' ).should.equal 2
    util.count_matching( [ {a:1},{b:1},{a:2},{c:2} ], 2, 'c' ).should.equal 1
    util.count_matching( [ {a:1},{b:1},{a:2},{c:2} ], 3, 'a' ).should.equal 0
    util.count_matching( [], 3, 'a' ).should.equal 0
    done()

  it 'get_by_id fetches elements with the specified key-value pair',(done)->
    a = { a:1, foo:'bar' }
    b = { a:1, b:2, c:3 }
    c = { c:3, id:3 }
    util.get_by_id( [ a,b,c ], 1, 'a' ).should.equal a
    should.not.exist util.get_by_id( [ a,b,c ], 2, 'a' )
    should.not.exist util.get_by_id( [ ], 2, 'a' )
    util.get_by_id( [ a,b,c ], 2, 'b' ).should.equal b
    util.get_by_id( [ a,b,c ], 3 ).should.equal c
    done()

  it 'clone shallow clones objects',(done)->
    a = { a:1, foo:'bar' }
    b = util.clone(a)
    util.count(b).should.equal util.count(a)
    for n,v of a
      b[n].should.equal v
    done()

  it 'partial_clone only clones specified properties',(done)->
    a = { a:1, foo:'bar' }
    b = util.partial_clone(a,['foo','a'])
    util.count(b).should.equal util.count(a)
    for n,v of a
      b[n].should.equal v
    b = util.partial_clone(a,['foo'])
    util.count(b).should.equal 1
    b.foo.should.equal 'bar'
    b = util.partial_clone(a,['a'])
    util.count(b).should.equal 1
    b.a.should.equal 1
    b = util.partial_clone(a,[])
    util.count(b).should.equal 0
    done()

  it 'filtered_clone doesn\'t clone specified properties',(done)->
    a = { a:1, foo:'bar' }
    b = util.filtered_clone(a,[])
    util.count(b).should.equal util.count(a)
    for n,v of a
      b[n].should.equal v
    b = util.filtered_clone(a,['foo'])
    util.count(b).should.equal 1
    b.a.should.equal 1
    b = util.filtered_clone(a,['a'])
    util.count(b).should.equal 1
    b.foo.should.equal 'bar'
    b = util.filtered_clone(a,['foo','a'])
    util.count(b).should.equal 0
    done()

  it 'count returns the number of properties in the given object',(done)->
    util.count({}).should.equal 0
    util.count({a:1}).should.equal 1
    util.count({a:1,b:2}).should.equal 2
    done()

  it 'is_empty yields true iff the given object has at least one property',(done)->
    util.is_empty({}).should.equal true
    util.is_empty({a:1}).should.equal false
    util.is_empty({a:1,b:2}).should.equal false
    done()

  describe 'predicates',()->
    it 'one_time_achievement returns false if achievement already exists',(done)->
      util.predicates.one_time_achievement( {},null,null,{id:7} ).should.be.ok
      util.predicates.one_time_achievement( {achievements:[{achievement_type_id:7}]},null,null,{id:7} ).should.not.be.ok
      done()

    it 'one_time_action returns false if action already exists',(done)->
      util.predicates.one_time_action( {},{id:7} ).should.be.ok
      util.predicates.one_time_action( {history:[{action_type_id:7}]},{id:7}).should.not.be.ok
      done()

    it 'n_time_achievement returns false if achievement already exists n times',(done)->
      g = util.predicates.higher_order.n_time_achievement
      g(1)( {},null,null,{id:7} ).should.be.ok
      g(2)( {},null,null,{id:7} ).should.be.ok
      g(1)( {achievements:[{achievement_type_id:7}]},null,null,{id:7} ).should.not.be.ok
      g(2)( {achievements:[{achievement_type_id:7}]},null,null,{id:7} ).should.be.ok
      g(3)( {achievements:[{achievement_type_id:7},{achievement_type_id:7}]},null,null,{id:7} ).should.be.ok
      g(3)( {achievements:[{achievement_type_id:7},{achievement_type_id:7},{achievement_type_id:7}]},null,null,{id:7} ).should.not.be.ok
      g(3)( {achievements:[{achievement_type_id:7},{achievement_type_id:7},{achievement_type_id:7},{achievement_type_id:7}]},null,null,{id:7} ).should.not.be.ok
      done()

    it 'n_time_action returns false if action already exists n times',(done)->
      g = util.predicates.higher_order.n_time_action
      g(1)( {},{id:7} ).should.be.ok
      g(2)( {},{id:7} ).should.be.ok
      g(1)( {history:[{action_type_id:7}]},{id:7} ).should.not.be.ok
      g(2)( {history:[{action_type_id:7}]},{id:7} ).should.be.ok
      g(3)( {history:[{action_type_id:7},{action_type_id:7}]},{id:7} ).should.be.ok
      g(3)( {history:[{action_type_id:7},{action_type_id:7},{action_type_id:7}]},{id:7} ).should.not.be.ok
      g(3)( {history:[{action_type_id:7},{action_type_id:7},{action_type_id:7},{action_type_id:7}]},{id:7} ).should.not.be.ok
      done()

    it '"or" combines predicates with a logical or',(done)->
      y = ()->return true
      n = ()->return false
      or_of = util.predicates.higher_order.or
      or_of(y)().should.be.ok
      or_of(n)().should.not.be.ok
      or_of(y,n)().should.be.ok
      or_of(n,y)().should.be.ok
      or_of(n,n)().should.not.be.ok
      or_of(n,n,n)().should.not.be.ok
      or_of(n,n,n,y)().should.be.ok
      or_of(n,n,y,n)().should.be.ok
      done()

    it '"and" combines predicates with a logical and',(done)->
      y = ()->return true
      n = ()->return false
      and_of = util.predicates.higher_order.and
      and_of(y)().should.be.ok
      and_of(n)().should.not.be.ok
      and_of(n,n)().should.not.be.ok
      and_of(n,y,n)().should.not.be.ok
      and_of(y,y)().should.be.ok
      and_of(y,y,y)().should.be.ok
      and_of(y,y,y,n)().should.not.be.ok
      and_of(y,y,n,y)().should.not.be.ok
      and_of(y,y,n,y)().should.not.be.ok
      and_of(y,n,y,y)().should.not.be.ok
      and_of(n,y,y,y)().should.not.be.ok
      done()

    it '"not" negates a predicate',(done)->
      y = ()->return true
      n = ()->return false
      not_of = util.predicates.higher_order.not
      not_of(y)().should.not.be.ok
      not_of(n)().should.be.ok
      done()
