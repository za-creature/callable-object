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


new Suite()
    .add "new Class()", ->
        obj = new Class()
    .add "Object.create(Class::)", ->
        obj = Object.create({}, Class::)
        Class.call(obj)
        obj
    .add "callable(Class)", ->
        obj = callable(Class)
    .add "ClassFactory()", ->
        obj = ClassFactory()
    .add "new ClassFactory()", ->
        obj = new ClassFactory()

    .add "new Class(5 args)", ->
        obj = new Class("a", "b", "c", "d", "e")
    .add "Object.create(Class::, 5 args)", ->
        obj = Object.create({}, Class::)
        Class.call(obj, "a", "b", "c", "d", "e")
        obj
    .add "callable(Class, 5 args)", ->
        obj = callable(Class, "a", "b", "c", "d", "e")
    .add "ClassFactory(5 args)", ->
        obj = ClassFactory("a", "b", "c", "d", "e")
    .add "new ClassFactory(5 args)", ->
        obj = new ClassFactory("a", "b", "c", "d", "e")

    .add "instance.baz()", ->
        result = instance.baz()
    .add "instance()", ->
        result = instance()
    .add "instance.baz(5 args)", ->
        result = instance.baz("a", "b", "c", "d", "e")
    .add "instance(5 args)", ->
        result = instance("a", "b", "c", "d", "e")
    .add "instance.baz(10 args)", ->
        result = instance.baz("a", "b", "c", "d", "e", 1, 2, 3, 4, 5)
    .add "instance(10 args)", ->
        result = instance("a", "b", "c", "d", "e", 1, 2, 3, 4, 5)

    .on "cycle", (event) ->
        console.log(String(event.target))
    .run()
