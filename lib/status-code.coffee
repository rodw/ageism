# # StatusCode
# enumerates status codes used in various AGEISM callback methods.

# The codes are loosely modeled on the HTTP status codes.
# In particular, the status codes follow the Nxx semantics
# of HTTP:
#
#  - ***2xx*** codes represent success
#  - ***4xx*** codes represent failure due to an error on the caller's part (bad request)
#  - ***5xx*** codes represent failure due to an error on the callee's side of things
#          (i.e., the request may have been fine, but we ran into an error executing it).

# ## `StatusCode`
# is a "hash" that acts a singleton object.
StatusCode = {
  # ### `REJECTED`
  # indicates that the given request was denied because some precondition was not met.
  # (Note this isn't quite what HTTP means by `412 Precondition Failed`, but is close enough.)
  REJECTED: 412,

  # ### `NOT_FOUND`
  # indicates that some required resource is missing.
  NOT_FOUND: 404,

  # ### `OK`
  # a generic "it's all good" status.
  OK: 200,

  # ### `CREATED`
  # a new entity was successfully created.
  CREATED: 201,

  # ### `BAD_REQUEST`
  # a generic "bad request" status.
  BAD_REQUEST: 400,

  # ### `ERROR`
  # a generic "something is broken" status.
  ERROR:    500,

  # ### `is_ok`
  # returns `true` iff the given code is in the *2xx* range.
  is_ok:(code)->return 200 <= code <= 299
}

# We "export" the module in node.js and browser friendly way.
exports = exports ? this
exports.StatusCode = StatusCode
