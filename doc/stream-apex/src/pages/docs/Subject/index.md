---
title: "Subject"
description: "Subject"
layout: "guide"
icon: "cloud"
weight: 4
---

###### {$page.description}

<article id="1">

## Stream Subject

Stream subjects can multicast events to multiple observers.

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

<article id="2">

## Methods

| Method | Description |
| ------ | ----------- |
| Subject() | Create a default subject |
| next(Object) | Send the next event |
| error(Object) | Send the error event |
| complete() | Send the complete event |

</article>
