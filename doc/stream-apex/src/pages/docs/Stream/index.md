---
title: "Streams"
description: "Streams"
layout: "guide"
icon: "flash"
weight: 1
---

###### {$page.description}

<article id="1">

## What is a Stream?

In a functional reactive world, streams are lists of events over time. But in Apex, with code
running in its own execution context, we can hardly build an asynchronous stream. So in Stream.apex,
we have only synchronous streams, which are just lists.

R.apex has already tons of functions to operate on lists, and then what is the point to build a stream?

Well, streams are actully event-driven lists. In R.apex, we do a `map` on the list, and get a new list. Then
we operate on the new list, and continue. In Stream.apex, event-driven lists are different. Streams do not
need to create any intermediate lists because they just work in place. When an element in a list is processed, it is
treated as an event, and passed through all the operations in the stream chains. This goes on until this single element is fully
processed, before the next element gets fired. In this way, streams are modelled like event-driven lists, and each stream
receives events and notifies events.

</article>

<article id="2">

## Subscription

In Stream.apex, streams are just `observables` that emit events. We have `observers` that
receive these events.

Here is how we build an observer with Funcs.

```javascript
Stream.Observer ob = new Stream.FuncObserver(new OnNextFunc(), new OnErrorFunc(), new OnCompleteFunc());
```

Then we subscribe this observer to the observable.

```javascript
Stream.with(1, 2, 3)
    .subscribe(ob);
```

The observer may have `onNext`, `onError` and `onComplete` implemented to handle stream events.

For simplicity's sake, we can also subscribe using Funcs directly.

```javascript
Stream.with(1, 2, 3)
    .subscribe(R.debug, R.debug, R.debug);
```

</article>

<article id="3">

## Lazy Stream

Streams are lazy in that they only emit values when an observer subscribes them. To check more on lazy streams,
please refer to [RxJs](http://reactivex.io);

</article>

<article id="4">

## Stream Operations

Streams are still built in a functional reactive style. We can chain streams using the fluent API like this:

```javascript
Stream.with(1, 2, 3)
    .startWith(Stream.of(0))
    .concatOther(Stream.range(4, 2))
    .filter(R.lt.apply(R.placeholder, 4))
    .mapBy(R.inc)
    .subscribe(R.debug);
```

</article>

<article id="5">

## Stream Subjects

Stream subjects are hot streams that can multicast events. We can use stream subjects like this:

```javascript
Stream.Subject s = new Stream.Subject();
s.subscribe(R.debug.apply('No.1'));
s.subscribe(R.debug.apply('No.2'));

s.next(1);
s.next(2);

// No.1, 1
// No.2, 1
// No.1, 2
// No.2, 2
```

</article>
