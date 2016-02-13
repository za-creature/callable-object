# callable-object

[![Circle CI](https://circleci.com/gh/za-creature/callable-object/tree/master.svg?style=shield)](https://circleci.com/gh/za-creature/callable-object/tree/master)
[![Dependencies](https://david-dm.org/za-creature/callable-object.svg)](https://david-dm.org/za-creature/callable-object)
[![Dev Dependencies](https://david-dm.org/za-creature/callable-object/dev-status.svg)](https://david-dm.org/za-creature/callable-object#info=devDependencies)
[![Coverage Status](https://coveralls.io/repos/github/za-creature/callable-object/badge.svg?branch=master)](https://coveralls.io/github/za-creature/callable-object?branch=master)

Ever find yourself missing Python's [`__call__`](https://docs.python.org/3/reference/datamodel.html#object.__call__) or PHP's [`__invoke`](http://php.net/manual/ro/language.oop5.magic.php#object.invoke)? Me too.

## Table of Contents

* [Installation](#installation-)
* [Usage](#usage-)
    * [Override `__call__`](#override-__call__-)
    * [Object factory](#object-factory-)
    * [Factory with hidden function](#factory-with-hidden-function-)
* [How it works](#how-it-works-)
* [Performance](#performance-)
    * [Object creation](#object-creation-)
    * [Invocation](#invocation-)
    * [Interpretation](#interpretation-)
* [API](#api-)
* [License: MIT](#license-)

## Installation [↑](#table-of-contents)

```bash
npm install callable-object
```

## Usage [↑](#table-of-contents)

```js
const callable = require("callable-object");


class Test {
    constructor(name) {
        this.name = name;
    },
    __call__(arg) {
        return `${arg} from ${this.name}`;
    }
}


const foo = callable(Test, "foo");
const bar = callable(Test, "bar");

console.log(foo("hello"));
console.log(bar("hello"));
console.log(foo("goodbye"));
console.log(bar("goodbye"));
```

Will print out:

```
hello from foo
hello from bar
goodbye from foo
goodbye from bar
```

### Override `__call__` [↑](#table-of-contents)

```js
callable.method = "whatAreYouNutsThereAreNoUnderscoresInJavascript";


class Test {
    whatAreYouNutsThereAreNoUnderscoresInJavascript() {
        return "hello world";
    }
}


console.log(callable(Test)());  // hello world
```

### Object factory [↑](#table-of-contents)

```js
class LazyNumber {
    construct(value) {
        this.value = value;
    },
    invoke() {
        return this.value;
    }
}


LazyNumberFactory = callable.factory(LazyNumber, "invoke");


const answerToLifeTheUniverseAndEverything = LazyNumberFactory(42);
const squareRootOfNine = new LazyNumberFactory(3); // new is optional

console.log(answerToLifeTheUniverseAndEverything()); // 42
console.log(squareRootOfNine()); // 3
```

### Factory with hidden function [↑](#table-of-contents)

```js
function LazyNumber(value) {
    this.value = value;
}


LazyNumberFactory = callable.factory(LazyNumber, function() {
    return this.value;
})
```

## How it works [↑](#table-of-contents)

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

## Performance [↑](#table-of-contents)

Results [were measured](benchmark/index.coffee) on a Intel i7-2600 @ 3.4GHz with
16GB of DDR3-1600 CL9 under Node.JS v4.2.6. Throughput numbers are expressed in
operations per second (ops).

### Object creation [↑](#table-of-contents)

No constructor arguments

| Test description       | Throughput | Error  | Percent of best |
| ---------------------- | ---------: | -----: | --------------: |
| new Class()            | 22,510,357 | ±0.83% |         100.00% |
| Object.create(Class::) |  7,227,079 | ±1.07% |          32.11% |
| callable(Class)        |     82,981 | ±3.20% |           0.37% |
| ClassFactory()         |     84,268 | ±3.59% |           0.37% |
| new ClassFactory()     |     86,179 | ±3.15% |           0.38% |

5 constructor arguments

| Test description       | Throughput | Error  | Percent of best |
| ---------------------- | ---------: | -----: | --------------: |
| new Class()            | 17,069,221 | ±0.63% |         100.00% |
| Object.create(Class::) |  6,365,882 | ±1.05% |          37.29% |
| callable(Class)        |     67,656 | ±1.92% |           0.40% |
| ClassFactory()         |     88,792 | ±2.64% |           0.52% |
| new ClassFactory()     |     87,260 | ±2.83% |           0.51% |

10 constructor arguments

| Test description       | Throughput | Error  | Percent of best |
| ---------------------- | ---------: | -----: | --------------: |
| new Class()            | 14,578,849 | ±1.24% |         100.00% |
| Object.create(Class::) |  6,041,883 | ±1.09% |          41.44% |
| callable(Class)        |     64,257 | ±1.84% |           0.44% |
| ClassFactory()         |     88,469 | ±2.39% |           0.61% |
| new ClassFactory()     |     87,123 | ±2.73% |           0.60% |

### Invocation [↑](#table-of-contents)

No arguments

| Test description       | Throughput | Error  | Percent of best |
| ---------------------- | ---------: | -----: | --------------: |
| instance.baz()         | 36,369,977 | ±0.47% |         100.00% |
| instance()             | 27,966,934 | ±1.30% |          76.90% |

5 arguments

| Test description       | Throughput | Error  | Percent of best |
| ---------------------- | ---------: | -----: | --------------: |
| instance.baz()         | 26,831,639 | ±0.60% |         100.00% |
| instance()             | 22,229,576 | ±0.82% |          82.85% |

10 arguments

| Test description       | Throughput | Error  | Percent of best |
| ---------------------- | ---------: | -----: | --------------: |
| instance.baz()         | 22,671,310 | ±0.78% |         100.00% |
| instance()             | 20,173,956 | ±0.79% |          88.98% |

### Interpretation [↑](#table-of-contents)

While the object creation performance is abysmal by most standards (200x
slowdown), the nature of the benchmark needs to be taken into account: the test
created an object and called its constructor, which stored the arguments it was
called with (so that the JIT can't optimize them out).

As the number of arguments (and thus the total amount of work performed by the
benchmark) increased, the throughput started dropping, whereas the throughput
of creating instances of callable classes remained relatively constant,
signaling that most of the time was spent with the object creation itself and
not running constructor code. As such, this 200x slowdown can be considered a
worst-case scenario, with real worlds results most likely being closer to 10x -
50x due to the extra work generally performed by the constructor.

With regards to the invocation itself, a similar trend is noticeable but with
the performance difference essentially becoming negligible as the amount of
useful work performed by the function itself increases.

## API [↑](#table-of-contents)

```js
callable(ctor, [args...])
```

Returns a callable object from `ctor` using the default behavior.

The default behavior is to invoke a method called `__call__` on the newly
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

## License [↑](#table-of-contents)

callable-object is licensed under the [MIT license](LICENSE.md).
