"use strict"


chai = require "chai"

callable = require "./index.coffee"


chai.should()
{expect} = chai


describe "callable", ->
    beforeEach ->
        callable.method = "__call__"


    it "should forward args to the constructor", ->
        called = false

        class Test
            constructor: (a, b) ->
                a.should.equal("foo")
                b.should.equal("bar")
                called = true

        callable(Test, "foo", "bar").should.be.an.instanceof(Test)
        called.should.be.true


    describe "Callable", ->
        {Callable} = callable


        it "should throw an error when called without a function", ->
            fn = -> Callable("foo")
            fn.should.throw(/function/)


        it "should return a function with the correct prototype __proto__", ->
            class Test

            test = Callable(Test)
            test.should.be.a("function")
            test.should.be.an.instanceof(Test)
            expect(test::).to.not.exist

            test = new Callable(Test)
            test.should.be.a("function")
            test.should.be.an.instanceof(Test)
            expect(test::).to.not.exist


        it "should create separate instances", ->
            class Test

            a = Callable(Test)
            b = Callable(Test)
            a.should.equal(a)
            b.should.equal(b)
            a.should.not.equal(b)
            a.foo = "bar"
            b.should.not.have.property("foo")


        it "should call the constructor with the passed arguments", ->
            called = false

            class Test
                constructor: (a, b) ->
                    a.should.equal("foo")
                    b.should.equal("bar")
                    called = true

            Callable(Test, null, ["foo", "bar"])
            called.should.be.true


        it "should call the constructor in the new object's context", ->
            that = this

            Test = ->
                that.should.not.equal(this)
                that = this

            Callable(Test).should.equal(that)


        it "should correctly forward the call when invoked directly", ->
            class Test

            called = false
            that = Callable Test, (arg1, arg2) ->
                that.should.equal(this)
                arg1.should.equal("foobar")
                arg2.should.equal(true)
                called = true
                return 123
            that("foobar", true).should.equal(123)
            called.should.be.true


        it "should correctly forward the call when using Function::apply", ->
            class Test

            called = false
            that = Callable Test, ->
                that.should.equal(this)
                arguments.should.have.length(2)
                arguments[0].should.equal("foo")
                arguments[1].should.equal("bar")
                called = true
                return 1234

            Function::apply.call(that, null, ["foo", "bar"]).should.equal(1234)
            called.should.be.true


        it "should correctly forward the call when using Function::call", ->
            class Test

            called = false
            that = Callable Test, ->
                that.should.equal(this)
                arguments.should.have.length(2)
                arguments[0].should.equal("bar")
                arguments[1].should.equal("baz")
                called = true
                return 5678

            Function::call.call(that, null, "bar", "baz").should.equal(5678)
            called.should.be.true


        it "should forward the call to a local property called `method`", ->
            class Test

            called = false
            test = Callable(Test, "invoke")
            test.invoke = (arg1, arg2) ->
                arg1.should.equal("foo")
                arg2.should.equal("bar")
                called = true
                return false

            test("foo", "bar").should.be.false
            called.should.be.true


        it "should search for `method` up the prototype chain", ->
            called = false
            class Test
                invoke: ->
                    called = true

            Callable(Test, "invoke")()
            called.should.be.true


        it "should use the default `method` if not specified", ->
            called = false
            class Test
                __call__: ->
                    called = true

            Callable(Test)()
            called.should.be.true

            callable.method = "invoke"

            called = false
            class Test2
                invoke: ->
                    called = true

            Callable(Test2)()
            called.should.be.true


    describe "factory", ->
        {factory} = callable


        it "should return correct instances", ->
            class Test
            ctor = factory(Test)

            ctor().should.be.a("function")
            (new ctor()).should.be.a("function")


        it "should correctly pass constructor arguments", ->
            args = []
            Test = (current...) -> args = args.concat(current)
            ctor = factory(Test)

            a = ctor("foo", "bar")
            b = new ctor("baz")
            args.should.have.length(3)
            args[0].should.equal("foo")
            args[1].should.equal("bar")
            args[2].should.equal("baz")


        it "should use the default `method`", ->
            called = 0
            class Test
                __call__: -> called += 1
            ctor = factory(Test)

            a = ctor()
            b = new ctor()

            a()
            b()
            a()
            b()
            called.should.equal(4)


        it "should support custom functions", ->
            called = 0
            class Test
            ctor = factory(Test, -> called += 1)

            a = ctor()
            b = new ctor()

            a()
            a()
            b()
            called.should.equal(3)
