---
title: "Create Streams"
description: "Create Streams"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 3
---

## {$page.title}

We have various ways to create streams in Stream.apex.

```javascript
Stream.of(1); // Create a stream with element 1
Stream.with(1, 2, 3); // Create a stream with elements 1, 2, 3
Stream.fromData(new List<Object>{ 1, 2, 3}); // Create a stream with a list of elements
Stream.range(1, 3); // Create a stream that start at 1 and creates 3 numbers
Stream.empty(); // Create an empty stream
Stream.throwError('error'); // Create a stream that throws error
```
