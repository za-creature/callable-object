"use strict"


{Suite} = require "benchmark"

callable = require "./index.coffee"


class Class
    constructor: ->
        @foo = "bar"
        @ctor_args = arguments
        undefined

    baz: ->
        @last_args = arguments
        1 + 1


ClassFactory = callable.factory(Class)
instance = callable.Callable(Class, "baz", [])


bench = (name) ->
    return new Suite()
        .on "complete", ->
            best = @filter("fastest")[0]

            console.log(name)
            for test in this
                console.log([
                    test.name,
                    test.hz.toFixed(0),
                    "±" + test.stats.rme.toFixed(2) + "%",
                    (100 * test.hz / best.hz).toFixed(2) + "%"
                ].join(" | "))
            console.log()


bench("Object creation, no args")
    .add "new Class()", ->
        obj = new Class()
    .add "Object.create(Class::)", ->
        obj = Object.create(Class::)
        Class.call(obj)
        obj
    .add "callable(Class)", ->
        obj = callable(Class)
    .add "ClassFactory()", ->
        obj = ClassFactory()
    .add "new ClassFactory()", ->
        obj = new ClassFactory()
    .run()
    

bench("Object creation, 5 args")
    .add "new Class()", ->
        obj = new Class("a", "b", "c", "d", "e")
    .add "Object.create(Class::)", ->
        obj = Object.create(Class::)
        Class.call(obj, "a", "b", "c", "d", "e")
        obj
    .add "callable(Class)", ->
        obj = callable(Class, "a", "b", "c", "d", "e")
    .add "ClassFactory()", ->
        obj = ClassFactory("a", "b", "c", "d", "e")
    .add "new ClassFactory()", ->
        obj = new ClassFactory("a", "b", "c", "d", "e")
    .run()


bench("Object creation, 10 args")
    .add "new Class()", ->
        obj = new Class("a", "b", "c", "d", "e", 1, 2, 3, 4, 5)
    .add "Object.create(Class::)", ->
        obj = Object.create(Class::)
        Class.call(obj, "a", "b", "c", "d", "e", 1, 2, 3, 4, 5)
        obj
    .add "callable(Class)", ->
        obj = callable(Class, "a", "b", "c", "d", "e", 1, 2, 3, 4, 5)
    .add "ClassFactory()", ->
        obj = ClassFactory("a", "b", "c", "d", "e", 1, 2, 3, 4, 5)
    .add "new ClassFactory()", ->
        obj = new ClassFactory("a", "b", "c", "d", "e", 1, 2, 3, 4, 5)
    .run()


bench("Invocation, no args")
    .add "instance.baz()", ->
        result = instance.baz()
    .add "instance()", ->
        result = instance()
    .run()


bench("Invocation, 5 args")
    .add "instance.baz()", ->
        result = instance.baz("a", "b", "c", "d", "e")
    .add "instance()", ->
        result = instance("a", "b", "c", "d", "e")
    .run()


bench("Invocation, 10 args")
    .add "instance.baz()", ->
        result = instance.baz("a", "b", "c", "d", "e", 1, 2, 3, 4, 5)
    .add "instance()", ->
        result = instance("a", "b", "c", "d", "e", 1, 2, 3, 4, 5)
    .run()
