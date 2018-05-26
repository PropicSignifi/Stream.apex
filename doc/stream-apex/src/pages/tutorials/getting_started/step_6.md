---
title: "Stream Operations"
description: "Stream Operations"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 6
---

## {$page.title}

We have operations for streams that can be chained easily to build our logic.

```javascript
Stream.with(1, 2, 3)
    .mapBy(R.inc)
    .startWith(Stream.of(1))
    .subscribe(R.debug);
// 1, 2, 3, 4
```

Here we created a stream with 1, 2, 3 and incremented each element with 1. Besides, we prepended a new stream of 1 to the stream. So finally we got 1, 2, 3, 4.

Each stream operation will create a new stream, and these streams are subscribed in a chain, so that the events from the top of the chain can flow to the bottom, calling each operation. That means, the list of elements are not processed as a whole from one operation to another. Instead, each element of the list gets processed from one operation to another. The next element will not start processing until the previous element is finished. They are driven by events and therefore are called **reactive**.
