# An Example Game Definition
#===============================================================================

# An AGEISM game is defined by a simple JavaScript object (or map).

game = { }

# The root object has two properties, an array of **`actions`** that a
# player can take, and an array of **`achievements`** a player can earn.

game.actions = []
game.achievements = []

# Actions
#-------------------------------------------------------------------------------

# An `action` represents something that a player can do--a valid "move"
# in the game, so to speak.

# Each `action` must have a unique **`id`** property, and may have an array
# of **`prerequisites`** and an array of **`conditions`**.

game.actions.push {
  id: 'action-1',
  prerequisites: [],
  conditions: []
}

# An `action` can also define additional properties.  For instance,
# we may want to give each `action` a `label`:

game.actions[0].label = 'The First Action'

# The AGEISM module will generally ignore these additional
# properties, but it will copy, save and store them.  These
# additional properties can be used to store application
# or domain specific data related to a given `action`.

# ### Prerequisites ###

# A `prerequisite` must define a **`predicate`** property.
# The `predicate` is boolean-valued function that accepts a
# `player` and an `action` to evaluate . The `predicate` returns
# `true` if the given parameters meets the requirements of this
# `prerequisite` and `false` otherwise.

# For instance, the following prerequisite insists that a
# player has already performed at least one action:

game.actions[0].prerequisites.push {
  predicate: (player,action)->return player.history.length > 0
}

# Like the `actions` themselves, each `prerequisite` can define
# additional properties:
game.actions[0].prerequisites[0].label =
  'at least one prior action must be performed'

# The `prerequisites` array is optional. An `action` can be created
# with no `prerequisites`, in which case it is always available
# to any `player`.

game.actions.push { id: 'action-2' }

# An `action` is "available" to a `player` if and only if all of it's
# `prerequisites` are met.

# ### Conditions ###

# Like a `prerequisite`, a `condition`  must define a
# **`predicate`** property. The `condition`'s `predicate` is
# boolean-valued function that accepts three parameters:
#
# 1. the `player` trying to peform the action
#
# 2. the `action` type she is trying to perform
#
# 3. a collection of application-specific action `data`
#    that describes attributes of the specific instance
#    of the action being performed.
#
# As before, the `condition` `predicate` returns `true`
# *iff* the requirements of the `condition` are met by the
# given `player`,`action` and `data` tuple (and returns
# and `false` otherwise).

# For instance, the following condition requires that an
# action can only be performed on a Tuesday:

game.actions[0].conditions.push {
  label: 'Tuesday\'s only',
  predicate: (player, action, data)->
    weekday = data?.date?.getDay()
    return weekday == 2
}

# (Note that since the first parameter to both `prerequisite` and
# `condition` predicates is a `player` instance, any player-domained,
# boolean-valued function can be used as either or both. I.e, the
# "at least one prior action must be performed" predicate defined
# above could be used as a `condition`'s `predicate` as well as a
# `prerequisite`'s.)

# An `action` can be performed by a player *iff* all of its
# `prerequisites` AND `conditions` have been met.

# Achievements
#-------------------------------------------------------------------------------

# An `achievement` represents something that a player can earn, typically by
# performing `actions`.

# Each `achievement`` must have a unique **`id`** property, and may have an array
# an array of **`conditions`** that must be met in order to earn the
# `achievement`.  Like an `action`, an achievement may also have additional
# properties. These will be ignored by the AGEISM engine, but will "pass thru"
# the engine unchanged so that you can use them to associate application-specific
# information with an `achievement`, `action`, `prerequisite` or `condition`.

game.achievements.push {
  id: 0,
  label: 'Veteran Status',
  conditions: []
}

# Each `condition` of an `achievement` defines a `predicate`,
# a boolean-valued function that accepts the following parameters:
#
# 1. the `player` in question
#
# 2. the type of `action` she has most recently (just) performed
#
# 3. the application-specific action `data` associated with
#    that action.
#
# 4. the type of `achievement` that she is trying to earn
#    (or at least, that we're trying to evaluate whether or not
#    she has earned).
#
# The `condition` returns `true` *iff* its requirements are
# met by the given `player`,`action` and `data` tuple.

game.achievements[0].conditions.push {
  label: 'Ten actions taken',
  predicate: (player, action, data, achievement)->
    return player.history.length >= 10
}

# A player earns an `achievement` *iff* all of its
# `conditions` have been met.

# The Player Object
#-------------------------------------------------------------------------------

# As you've seen, the various `predicate` methods described above accept a
# `player` parameter.

# This `player` is a simple data-object containing the various attributes
# of participant in the game.  This `player` object may contain application
# specific data, but at minimum, it will *always* include a unique **`id`**,
# a **`history`** of `actions` that the player has taken and a list of
# **`achievements`** the player has earned.

# For example:

a_player = {
  id: 'player-x',
  name: 'Morgan Smith',
  history: [ {
      id: 103, action_type_id: 'action-1',
      label:'The First Action', date: 'Mon, 14 May 2012 11:19:17 GMT'
    }, {
      id: 104, action_type_id: 'action-2',
      date: 'Tue, 15 May 2012 19:11:17 GMT'
    }, {
      id: 105, action_type_id: 'action-1',
      label:'The First Action', date: 'Wed, 16 May 2012 17:11:19 GMT'
    }
  ],
  achievements: [ {
      id: 99, achievement_type_id: 0,
      label: 'Newbie Status', date: 'Mon, 14 May 2012 11:19:17 GMT'
    }
  ]
}


# (In the state-machine metaphor, this `player` object represents the
# current "state". The player-state is changed by the game engine in
# reponse to `actions` that the player might take (or experience).)

# A Complete Example
#-------------------------------------------------------------------------------

# While we assembled the game definition above in a piecemeal fasion in order
# to comment on what we were building, a game definition may typically be
# defined all at once. For instance, the following `game` is equivalent
# to the one defined above.

game = {

  actions: [ {
    id: 'action-1',
    label: 'The First Action'
    prerequisites: [ {
      label: 'at least one prior action must be performed',
      predicate: (player,action)->return player.history.length > 0
    } ],
    conditions: [ {
      label: 'Tuesday\'s only',
      predicate: (player, action, data)->
        weekday = data?.date?.getDay()
        return weekday == 2
    } ]
  }, {
    id: 'action-2'
  } ],

  achievements: [ {
    id: 0,
    label: 'Veteran Status',
    conditions: [ {
      label: 'Ten actions taken',
      predicate: (player, action, data, achievement)->
        return player.history.length >= 10
    } ]
  } ]
}

util = require('util')
console.log "GameDef",util.inspect(game,null,4)
