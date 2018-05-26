---
title: "Operation Methods"
description: "Operation Methods"
layout: "guide"
icon: "code-file"
weight: 4
---

###### {$page.description}

<article id="1">

## concatOther

Concatenate the other streams

```javascript
Stream.of(1)
    .concatOther(new List<Stream>{ Stream.with(2, 3) })
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// 3
// Completed
```

| Method | Description |
| ------ | ----------- |
| concatOther(List&lt;Stream&gt;) | Concat list of streams |
| concatOther(Stream) | Concat one stream |
| concatOther(Stream, Stream) | Concat two streams |
| concatOther(Stream, Stream, Stream) | Concat three streams |

</article>

<article id="2">

## mapBy

Map the Func over the stream elements

```javascript
Stream.with(1, 2, 3)
    .mapBy(R.inc)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 2
// 3
// 4
// Completed
```

</article>

<article id="3">

## flatMap

Map the Func and flatten the stream

```javascript
Stream.with(1, 2, 3)
    .flatMap(Stream.Funcs.ofData.apply(4))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 4
// 4
// 4
// Completed
```

</article>

<article id="4">

## mapTo

Map the element to the value

```javascript
Stream.with(1, 2, 3)
    .mapTo(4)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 4
// 4
// 4
// Completed
```

</article>

<article id="5">

## filter

Filter the stream

```javascript
Stream.with(1, 2, 3)
    .filter(R.equals.apply(2))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 2
// Completed
```

</article>

<article id="6">

## scan

Similar to 'reduce', but emit the intermediate results

```javascript
Stream.with(1, 2, 3)
    .scan(R.add, 0)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 3
// 6
// Completed
```

</article>

<article id="7">

## reduce

Reduce over the stream elements

```javascript
Stream.with(1, 2, 3)
    .reduce(R.add, 0)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 6
// Completed
```

</article>

<article id="8">

## catchError

Catch the error and return the recovered value

```javascript
Stream.throwError('error')
    .catchError(R.constant.apply('success'))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// success
// Completed
```

</article>

<article id="9">

## count

Get the count of the stream items

```javascript
Stream.with(1, 2, 3)
    .count()
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 3
// Completed
```

| Method | Description |
| ------ | ----------- |
| count() | Count all |
| count(Func) | Count all that matches the predicate |

</article>

<article id="10">

## defaultIfEmpty

Set the default value if the stream is empty

```javascript
Stream.empty()
    .defaultIfEmpty(1)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// Completed
```

</article>

<article id="11">

## distinct

Get a stream of distinct values, according to the key calculated by the Func

```javascript
Stream.with(1, 2, 3)
    .distinct(R.mod.apply(R.placeholder, 2))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// Completed
```

| Method | Description |
| ------ | ----------- |
| distinct() | Get a stream of distinct values |
| distinct(Func) | Get distinct values based on the compare Func that returns Boolean |

</article>

<article id="12">

## distinctUntilChanged

Get a stream of values, distinct from the last one

```javascript
Stream.with(1, 2, 1)
    .distinctUntilChanged(R.equals, R.identity)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// 1
// Completed
```

| Method | Description |
| ------ | ----------- |
| distinctUntilChanged(Func, Func) | Get distinct values based on compare Func and selector Func |
| distinctUntilChanged(Func) | Get distinct values based on selector Func |
| distinctUntilChanged() | Get distinct values |

</article>

<article id="13">

## distinctUntilKeyChanged

Get a stream of values, distinct from the last one by key value

```javascript
Stream.with(new Map<String, Object>{ 'name' => 'a' }, new Map<String, Object>{ 'name' => 'a' })
    .distinctUntilKeyChanged('name', R.equals)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// {name=a}
// Completed
```

| Method | Description |
| ------ | ----------- |
| distinctUntilKeyChanged(String, Func) | Get distinct values based on key and compare Func |
| distinctUntilKeyChanged(String) | Get distinct values based on key |

</article>

<article id="14">

## elementAt

Get the Nth element, return default value if not found

```javascript
Stream.with(1, 2, 3)
    .elementAt(3, 4)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 4
// Completed
```

| Method | Description |
| ------ | ----------- |
| elementAt(Integer, Object) | Get element at the index with default value |
| elementAt(Integer) | Get element at the index |

</article>

<article id="15">

## every

Check if every element matches the predicate

```javascript
Stream.with(1, 2, 3)
    .every(R.lt.apply(R.placeholder, 4))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// true
// Completed
```

</article>

<article id="16">

## join

Flatten nested Streams

```javascript
Stream.with(1, Stream.of(2), 3)
    .join()
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// 3
// Completed
```

</article>

<article id="17">

## finalize

Register a Func that will be called either after completion or error

```javascript
Stream.with(1, 2, 3)
    .finalize(R.debug.apply(4))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// 3
// 4
// Completed
```

</article>

<article id="18">

## find

Find the first element that matches the predicate

```javascript
Stream.with(1, 2, 3)
    .find(R.equals.apply(2))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 2
// Completed
```

</article>

<article id="19">

## findIndex

Find the index of the first element that matches the predicate

```javascript
Stream.with(1, 2, 3)
    .findIndex(R.equals.apply(2))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// Completed
```

</article>

<article id="20">

## first

Find the first element that matches the predicate, otherwise return the default value

```javascript
Stream.with(1, 2, 3)
    .first(R.equals.apply(4), 4)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 4
// Completed
```

| Method | Description |
| ------ | ----------- |
| first(Func, Object) | Find the first matching with default value |
| first(Func) | Find the first matching |

</article>

<article id="21">

## last

Find the last element that matches the predicate, otherwise return the default value

```javascript
Stream.with(1, 2, 3)
    .last(R.equals.apply(4), 4)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 4
// Completed
```

| Method | Description |
| ------ | ----------- |
| last(Func, Object) | Find the last matching with default value |
| last(Func) | Find the last matching |

</article>

<article id="22">

## groupBy

Group the elements into a map

```javascript
Stream.with(1, 2, 3)
    .groupBy(R.mod.apply(R.placeholder, 2))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// {0=(2), 1=(1, 3)}
// Completed
```

</article>

<article id="23">

## ignoreElements

Create a stream that ignores all elements

```javascript
Stream.with(1, 2, 3)
    .ignoreElements()
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// Completed
```

</article>

<article id="24">

## isEmpty

Check if the stream is empty

```javascript
Stream.with(1, 2, 3)
    .isEmpty()
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// false
// Completed
```

</article>

<article id="25">

## max

Get the max element according to the comparator Func that returns an Integer

```javascript
Stream.with(1, 2, 3)
    .max(R.compare)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 3
// Completed
```

| Method | Description |
| ------ | ----------- |
| max(Func) | Get max value with the comparator Func returning Integer |
| max() | Get the max value |

</article>

<article id="26">

## min

Get the min element according to the comparator Func that returns an Integer

```javascript
Stream.with(1, 2, 3)
    .min(R.compare)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 3
// Completed
```

| Method | Description |
| ------ | ----------- |
| min(Func) | Get min value with the comparator Func returning Integer |
| min() | Get the min value |

</article>

<article id="27">

## onErrorResumeNext

Like 'concat', but continue to the next stream only when the first stream has errors

```javascript
Stream.throwError('error')
    .onErrorResumeNext(new List<Stream>{ Stream.of('success') })
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// success
// Completed
```

</article>

<article id="28">

## pairwise

Make pairs from adjacent stream items

```javascript
Stream.with(1, 2, 3)
    .pairwise()
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// Pair:[fst=1, snd=2]
// Pair:[fst=2, snd=3]
// Completed
```

</article>

<article id="29">

## pluck

Pluck the value from the stream elements

```javascript
Stream.with(new Map<String, Object>{ 'name' => 'a' })
    .pluck('name')
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// a
// Completed
```

</article>

<article id="30">

## repeat

Repeat the stream for N times

```javascript
Stream.with(1, 2, 3)
    .repeat(2)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// 3
// 1
// 2
// 3
// Completed
```

</article>

<article id="31">

## single

Get the single element from the stream that matches the predicate

```javascript
Stream.with(1, 2, 3)
    .single(R.equals.apply(2))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 2
// Completed
```

</article>

<article id="32">

## skip

Skip N elements from the stream

```javascript
Stream.with(1, 2, 3)
    .skip(2)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 3
// Completed
```

</article>

<article id="33">

## skipLast

Skip N elements from the last of the stream

```javascript
Stream.with(1, 2, 3)
    .skipLast(2)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// Completed
```

</article>

<article id="34">

## skipWhile

Skip elements while the predicate is true

```javascript
Stream.with(1, 2, 3)
    .skipWhile(R.lt.apply(R.placeholder, 3))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 3
// Completed
```

</article>

<article id="35">

## take

Take the first N elements from the stream

```javascript
Stream.with(1, 2, 3)
    .take(2)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// Completed
```

</article>

<article id="36">

## takeLast

Take the last N elements from the stream

```javascript
Stream.with(1, 2, 3)
    .takeLast(2)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 2
// 3
// Completed
```

</article>

<article id="37">

## takeWhile

Take elements while the predicate is true

```javascript
Stream.with(1, 2, 3)
    .takeWhile(R.lt.apply(R.placeholder, 3))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 2
// Completed
```

</article>

<article id="38">

## startWith

Append the other stream to the stream

```javascript
Stream.with(1, 2, 3)
    .startWith(Stream.of(0))
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 0
// 1
// 2
// 3
// Completed
```

</article>

<article id="39">

## tap

Pass the value through the Func

```javascript
Stream.with(1, 2, 3)
    .tap(R.debug)
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// 1
// 1
// 2
// 2
// 3
// 3
// Completed
```

</article>

<article id="40">

## toArray

Convert the strema elements to a list

```javascript
Stream.with(1, 2, 3)
    .toArray()
    .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
// (1, 2, 3)
// Completed
```

</article>
