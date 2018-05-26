---
title: "Subscription"
description: "Subscription"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 4
---

## {$page.title}

After streams are created, you can subscribe them to receive emitted events.

```javascript
Stream.with(1, 2, 3)
    .subscribe(R.debug, R.debug.apply('Error'), R.debug.apply('Completed'));
```

Here we subscribed the stream with three callback Funcs, `onNext`, `onError` and `onComplete`.

When streams are emitting events, we can received these events from `onNext`.

When streams complete their work, they will call `onComplete` at last.

When an error is met, streams will call `onError` to notify.

These three functions actuall consist of the observer object, and streams are just observables.
