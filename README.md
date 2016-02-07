# callable-object

Ever find yourself missing Python's [`__call__`](https://docs.python.org/3/reference/datamodel.html#object.__call__) or PHP's [`__invoke`](http://php.net/manual/ro/language.oop5.magic.php#object.invoke)? Me too.

## Installation

```bash
npm install callable-object
```

## Usage

### Basic

```js
callable = require("callable-object");


class Test {
    constructor(name) {
        this.name = name
    },
    __call__(arg) {
        return `${arg} from ${this.name}`
    }
}


const foo = callable(Test, "foo");
const bar = callable(Test, "bar");

console.log(foo("hello"))
console.log(bar("hello"))
console.log(foo("goodbye"))
console.log(bar("goodbye"))
```

Will print out:

```
hello from foo
hello from bar
goodbye from foo
goodbye from bar
```

### Override __call__

```js
callable.method = "whatAreYouNutsThereAreNoUnderscoresInJavascript"


class Test {
    whatAreYouNutsThereAreNoUnderscoresInJavascript() {
        return "hello world"
    }
}
```

### Factory

```js
class LazyNumber {
    construct(value) {
        this.value = value
    },
    invoke() {
        return this.value
    }
}


LazyNumberFactory = callable.factory(LazyNumber, "invoke")


const answerToLifeTheUniverseAndEverything = LazyNumberFactory(42);
const squareRootOfNine = new LazyNumberFactory(3); // new is optional

console.log(answerToLifeTheUniverseAndEverything()) // 42
console.log(squareRootOfNine()) // 3
```

### Factory with hidden function

```js
class LazyNumber {
    construct(value) {
        this.value = value
    }
}


LazyNumberFactory = callable.factory(LazyNumber, function() {
    return this.value
})
```

## How?

It works by creating a function that proxies to `this.__call__` (or wherever),
changing said function's prototype then invokes the constructor on it. This has
a few limitations:

1. It requires either `setPrototypeOf` or `__proto__`, so IE11, EDGE and recent
   versions of the evergreens only (oh, and of course Node.JS)
2. Since it expects the constructor to mutate `this` (which is a function), it 
   does not support the part of the JS spec where a constructor may return a
   new object that will be used in favor of `this` when returning to the
   caller. Ironically, the implementation itself uses this part of the spec to
   support the `new callable()` syntax.
3. Due to the way JS engines currently optimize the code, `setPrototypeOf` is
   rather slow. Not slow enough to discourage usage, but maybe don't create new
   callable objects in your critical code paths.

##  API

```js
callable(ctor, [args...])
```

Returns a callable object from `ctor` using the default behavior.

The default behavior is to invoke a method called __call__ on the newly
created object whenever it is called as a function. This can be changed by
assigning a different value to the `method` property of this module. Doing
that of course comes with a "if you break it, you get to keep all the
little pieces" guarantee.

Any additional arguments are sent to `ctor`.

```js
callable.Callable(ctor, method = null, args = [])
```

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

```js
callable.factory(ctor, method = null)
```

Creates a new callable factory with specific behavior.

Returns a function that can be called in lieu of a constructor (can even
use `new`) to return instances of `ctor` that will invoke `method` when
they are called as a function. If `method` is not provided, it will use the
global default

## License

callable-object is licensed under the [MIT license](LICENSE.md).
