---
title: "Functions"
description: "Functions"
layout: "guide"
icon: "code-file"
weight: 2
---

###### {$page.description}

<article id="1">

## create

Create from stream source

```javascript
Stream s = (Stream)Stream.Funcs.create.run(new CustomSource());
```

</article>

<article id="2">

## ofData

Create from value

```javascript
Stream s = (Stream)Stream.Funcs.ofData.run('abc');
```

</article>

<article id="3">

## throwError

Create from error

```javascript
Stream s = (Stream)Stream.Funcs.throwError.run('error');
```

</article>

<article id="4">

## empty

Create an empty stream

```javascript
Stream s = (Stream)Stream.Funcs.empty.run();
```

</article>

<article id="5">

## never

Create a stream that does not emit error or complete event.

```javascript
Stream s = (Stream)Stream.Funcs.never.run();
```

</article>

<article id="6">

## fromData

Create a stream from a collection

```javascript
Stream s = (Stream)Stream.Funcs.fromData.run(new List<Object>{ 1, 2, 3 });
```

</article>

<article id="7">

## with

Create a stream from values

```javascript
Stream s = (Stream)Stream.Funcs.with.run(1, 2, 3);
```

</article>

<article id="8">

## range

Create a stream from ranges of values

```javascript
Stream s = (Stream)Stream.Funcs.range.run(1, 4);
```

</article>

<article id="9">

## generate

Generate a stream with the Funcs

```javascript
Stream s = (Stream)Stream.Funcs.generate.run(0, R.lt.apply(R.placeholder, 3), R.inc);
```

</article>

<article id="10">

## concat

Create a stream by concatenating other streams

```javascript
Stream s = (Stream)Stream.Funcs.concat.run(new List<Stream>{ Stream.of(1), Stream.of(2) });
```

</article>
