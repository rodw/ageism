# # AgeismUtil
# contains various utility functions shared by the AGEISM module.

# ## `AgeismUtil`
# is a "hash" that acts a singleton object.
AgeismUtil = {
  rename_key:(map,old_name,new_name)->
    map = @clone(map)
    map[new_name] = map[old_name]
    delete map.old_name
    return map

  # ### `contains_id`
  # yields `true` iff `list` contains an element *e* such that `e.id == id` (otherwise `false`).
  contains_id:(list,id,fld='id')->
    if list?
      for elt in list
        if elt[fld]? && elt[fld] == id
          return true
    return false

  count_matching:(list,value,fld)->
    count = 0
    if list?
      for elt in list
        count += 1 if elt[fld]? && elt[fld] == value
    return count

  # ### `get_by_id`
  # returns the first element *e* in `list` such that `e.id == id` (otherwise `null`).
  get_by_id:(list,id,fld='id')->
    for elt in list
      if elt[fld]? && elt[fld] == id
        return elt
    return null

  # ### `clone`
  # returns a "shallow" clone of the given `object`
  clone:(object)->
    cloned = {}
    for n,v of object
      cloned[n] = v if object.hasOwnProperty n
    return cloned

  # ### `partial_clone`
  # returns a "shallow" clone of the specified `properties` of the given `object`.
  partial_clone:(object,properties)->
    cloned = {}
    for n in properties
      cloned[n] = object[n] if object.hasOwnProperty n
    return cloned

  # ### `filtered_clone`
  # returns a "shallow" clone of the specified `object`, excluding any
  # properties enumerated in the given `filter`
  filtered_clone:(object,filter)->
    cloned = {}
    for n,v of object
      cloned[n] = object[n] if filter.indexOf(n) == -1 && object.hasOwnProperty n
    return cloned


  # ### `count`
  # returns the number of properties in the given `object`
  count:(object)->
    c = 0
    if object?
      for n,v of object
        c += 1 if object.hasOwnProperty n
    return c

  # ### `is_empty`
  # yields `true` iff the given `object` has at least one property (otherwise `false`)
  is_empty:(object)->
    for n,v of object
      return false if object.hasOwnProperty n
    return true

  predicates: {
    one_time_achievement:(player,action,data,achievement)->
      return !AgeismUtil.contains_id(player.achievements,achievement.id,'achievement_type_id')
    one_time_action:(player,action)->
      return !AgeismUtil.contains_id(player.history,action.id,'action_type_id')
    higher_order: {
      n_time_achievement:(n)->
        f =(player,action,data,achievement)->
          return AgeismUtil.count_matching(player.achievements,achievement.id,'achievement_type_id') < n
        return f
      n_time_action:(n)->
        f =(player,action)->
          return AgeismUtil.count_matching(player.history,action.id,'action_type_id') < n
        return f
      or:()->
        functions = arguments
        return (player,action,data,achievement)->
          for f in functions
            if f(player,action,data,achievement)
              return true
          return false
      and:()->
        functions = arguments
        return (player,action,data,achievement)->
          for f in functions
            if !f(player,action,data,achievement)
              return false
          return true
      not:(f)->
        return (player,action,data,achievement)->
          return !f(player,action,data,achievement)
    }
  }
}

# We "export" the module in node.js and browser friendly way.
exports = exports ? this
exports.AgeismUtil = AgeismUtil
