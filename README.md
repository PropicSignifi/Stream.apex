# Stream.apex
Stream.apex is a library that streamlines your Funcs in Apex.

## Why Stream.apex?
In Stream.apex, a stream is an event-driven list of objects. We can chain operations on the stream, and the stream will emit events through all the operations one by one. In this way, streams do not create intermediate lists like most other list operations will do, and it is more efficient.

## Dependencies
Stream.apex has a dependency over [R.apex](https://github.com/Click-to-Cloud/R.apex/).

Please include it before including Stream.apex.

## Preliminary Knowledge
Stream.apex is a compliment to how lists are processed in R.apex, and it requires a fair amount of knowledge on R.apex. If you want to go deeper with Stream.apex, please do check out [R.apex](https://github.com/Click-to-Cloud/R.apex/).

## Functional Reactive Programming
Due to the limitations of Salesforce Apex, instances of streams cannot be shared across different execution contexts. So asynchronous streams will basically be impossible to build. In Stream.apex, we support only synchronous streams.

For details on Functional Reactive Programming, please read the documentations on [RxJs](http://reactivex.io/rxjs).

## Examples
### Create Streams
We have various ways to create streams in Stream.apex.

```java
Stream.of(1); // Create a stream with element 1
Stream.with(1, 2, 3); // Create a stream with elements 1, 2, 3
Stream.fromData(new List<Object>{ 1, 2, 3}); // Create a stream with a list of elements
Stream.range(1, 3); // Create a stream that start at 1 and creates 3 numbers
Stream.empty(); // Create an empty stream
Stream.throwError('error'); // Create a stream that throws error
```

### Subscription
After streams are created, you can subscribe them to receive emitted events.

```java
Stream.with(1, 2, 3)
    .subscribe(R.debug, R.debug.apply('Error'), R.debug.apply('Completed'));
```

Here we subscribed the stream with three callback Funcs, `onNext`, `onError` and `onComplete`.

When streams are emitting events, we can received these events from `onNext`.

When streams complete their work, they will call `onComplete` at last.

When an error is met, streams will call `onError` to notify.

These three functions actuall consist of the `observer` object, and streams are
just `observables`.

### Lazy Streams
Streams are lazy and will not emit events until you actually subscribe them.

```java
Stream.with(1, 2, 3) // Will not emit events
    .subscribe(R.debug); // Will emit events
```

This kind of streams have the data within them, and when one observer subscribes them, they will emit data to this observer, including all the events. When a new observer subscribes, the same data will be emitted. Hence streams are just like working only for these subscribed observers alone. They unicast events to observers and are called **cold streams**.

### Stream Operations
We have operations for streams that can be chained easily to build our logic.

```java
Stream.with(1, 2, 3)
    .mapBy(R.inc)
    .startWith(Stream.of(1))
    .subscribe(R.debug);
// 1, 2, 3, 4
```

Here we created a stream with 1, 2, 3 and incremented each element with 1. Besides, we prepended a new stream of 1 to the stream. So finally we got 1, 2, 3, 4.

Each stream operation will create a new stream, and these streams are subscribed in a chain, so that the events from the top of the chain can flow to the bottom, calling each operation. That means, the list of elements are not processed as a whole from one operation to another. Instead, each element of the list gets processed from one operation to another. The next element will not start processing until the previous element is finished. They are driven by events and therefore are called **reactive**.

### Subjects
Subjects are actually another kind of streams, hot streams. They work quite similar to lazy streams, except that they do not maintain the events inside them. To be more clearly, subjects receive events and then emit them to all the registered observers. When one observer subscribes the subject, the subject will not emit the previously emittd events to the new observer. It will only emit the events fired after the observer subscribed.

Subjects can multicast events to observers, and they are called **hot streams**.

```java
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
