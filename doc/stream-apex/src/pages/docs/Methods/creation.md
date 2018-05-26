---
title: "Creation Methods"
description: "Creation Methods"
layout: "guide"
icon: "code-file"
weight: 2
---

###### {$page.description}

<article id="1">

## create

Create from stream source

```javascript
Stream.create(new CustomSource())
     .subscribe(R.debug);
```

</article>

<article id="2">

## of

Create from value

```javascript
Stream.of('abc')
     .subscribe(R.debug);
// abc
```

</article>

<article id="3">

## throwError

Create from error

```javascript
Stream.throwError('test error')
     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// (Error: , test error)
```

</article>

<article id="4">

## empty

Create an empty stream

```javascript
Stream.empty()
     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// Completed
```

</article>

<article id="5">

## never

Create a stream that does not emit error or complete event.

```javascript
Stream.never()
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
```

</article>

<article id="6">

## fromData

Create a stream from a collection

```javascript
Stream.fromData(new List<Object>{ 1, 2, 3 })
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// 3
// Completed
```

</article>

<article id="7">

## with

Create a stream from values

```javascript
Stream.with(1)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// Completed
```

| Method | Description |
| ------ | ----------- |
| with(Object) | Create a stream from one value |
| with(Object, Object) | Create a stream from two values |
| with(Object, Object, Object) | Create a stream from three values |

</article>

<article id="8">

## range

Create a stream from ranges of values

```javascript
Stream.range(1, 3)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// 3
// Completed
```

</article>

<article id="9">

## generate

Generate a stream with the Funcs

```javascript
Stream.generate(1, R.lt.apply(R.placeholder, 4), R.inc)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// 3
// Completed
```

</article>

<article id="10">

## concat

Create a stream by concatenating other streams

```javascript
Stream.concat(new List<Stream>{ Stream.of(1), Stream.of(2), Stream.of(3) })
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// 3
// Completed
```

| Method | Description |
| ------ | ----------- |
| concat(Stream) | Concat one stream |
| concat(Stream, Stream) | Concat two streams |
| concat(Stream, Stream, Stream) | Concat three streams |

</article>
