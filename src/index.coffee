"use strict"


Callable = (ctor, method = null, args = []) ->
    ###
    Creates a new callable object.

    Creates a new function that is updated to behave as if it was the result of
    a call to `new ctor(args...)` with the extra twist that any calls will be
    intercepted and forwarded to `obj[method]` OR directly to `method` if it is
    a function.

    `args` will be sent directly to `ctor`, which will be called in the new
    object's context prior to returning.

    *WARNING* the result of `ctor` is ignored. While this shouldn't affect most
    people, this is technically against the spec as returning an object from a
    constructor invoked with `new` should override the object that was created
    and passed as the function's context.
    ###
    if typeof ctor isnt "function"
        throw new Error("First argument must be a function")

    if not method?
        method = module.exports.method

    # create a new function that invokes `method`
    if typeof method is "string"
        obj = -> obj[method].apply(obj, arguments)
    else
        obj = -> method.apply(obj, arguments)

    # update prototype, constructor and [[prototype]]
    obj.prototype = undefined
    obj.constructor = ctor
    ### istanbul ignore next ###
    if Object.setPrototypeOf?
        Object.setPrototypeOf(obj, ctor::)
    else
        obj.__proto__ = ctor::

    # call constructor on the newly created function-object
    ctor.apply(obj, args)
    return obj


module.exports = (ctor, args...) ->
    ###
    Returns a callable object from `ctor` using the default behavior.

    The default behavior is to invoke a method called __call__ on the newly
    created object whenever it is called as a function. This can be changed by
    assigning a different value to the `method` property of this module. Doing
    that of course comes with a "if you break it, you get to keep all the
    little pieces" guarantee.

    Any additional arguments are sent to `ctor`.
    ###
    Callable(ctor, null, args)


module.exports.Callable = Callable


module.exports.factory = (ctor, method = null) ->
    ###
    Creates a new callable factory with specific behavior.

    Returns a function that can be called in lieu of a constructor (can even
    use `new`) to return instances of `ctor` that will invoke `method` when
    they are called as a function. If `method` is not provided, it will use the
    global default
    ###
    return -> Callable(ctor, method, arguments)


module.exports.method = "__call__"  # the default method to use; may be changed
