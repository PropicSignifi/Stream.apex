---
title: "Subjects"
description: "Subjects"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 7
---

## {$page.title}

Subjects are actually another kind of streams, hot streams. They work quite similar to lazy streams, except that they do not maintain the events inside them. To be more clearly, subjects receive events and then emit them to all the registered observers. When one observer subscribes the subject, the subject will not emit the previously emittd events to the new observer. It will only emit the events fired after the observer subscribed.

Subjects can multicast events to observers, and they are called **hot streams**.

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
