---
title: "Subscription Methods"
description: "Subscription Methods"
layout: "guide"
icon: "code-file"
weight: 3
---

###### {$page.description}

<article id="1">

## subscribe

Subscribe an observer to the stream
If the stream is cold, it will emit all the events to this observer
If the stream is hot, it will emit events only when they come, to
this observer and previous observers

```javascript
Stream.of('abc')
     .subscribe(new Stream.FuncObserver(R.debug));
// abc
```

| Method | Description |
| ------ | ----------- |
| subscribe(Observer) | Subscribe an observer |
| subscribe(Func, Func, Func) | Subscribe with onNext, onError and onComplete |
| subscribe(Func, Func) | Subscribe with onNext, onError |
| subscribe(Func) | Subscribe with onNext |

</article>
