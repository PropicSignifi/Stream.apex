---
title: "Lazy Streams"
description: "Lazy Streams"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 5
---

## {$page.title}

Streams are lazy and will not emit events until you actually subscribe them.

```javascript
Stream.with(1, 2, 3) // Will not emit events
    .subscribe(R.debug); // Will emit events
```

This kind of streams have the data within them, and when one observer subscribes them, they will emit data to this observer, including all the events. When a new observer subscribes, the same data will be emitted. Hence streams are just like working only for these subscribed observers alone. They unicast events to observers and are called **cold streams**.
