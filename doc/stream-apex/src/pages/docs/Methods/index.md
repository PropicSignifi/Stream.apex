---
title: "Methods"
description: "Methods"
layout: "guide"
icon: "code-file"
weight: 2
---

###### {$page.description}

<article id="1">

## Stream Method Reference

Here is the stream method reference.

```javascript
Stream.with(1, 2, 3)
    .mapBy(R.multiply.apply(2))
    .subscribe(R.debug);
```

</article>
