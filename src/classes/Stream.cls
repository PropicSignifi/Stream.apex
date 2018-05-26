/**
 * MIT License
 *
 * Copyright (c) 2018 Click to Cloud Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 **/
/**
 * Synchronous streams in Apex
 *
 * A stream is a series of events over a period of time in functional reactive programming
 * However, in Apex, code runs in its own execution context and hardly shares variables with
 * each other, which renders asynchronous streams unavailable here
 *
 * In Stream.apex, we only have synchronous streams and even then, streams are a powerful tool
 *
 * Unlike how R.apex handles collections, streams are more efficient, as them do not generate
 * intermediate collection objects
 *
 * Instead, streams handle items from collections one by one, completing each item with all registered
 * operators in the chain before continuing to the next
 *
 * Also, streams are divided into hot streams and cold streams
 *
 * Cold streams are those when you subscribe them, they emit all the events to you
 * Basically cold streams are unicast
 *
 * Hot streams are those when you subscribe them, they will emit the events only when they receive some
 * Basically hot streams are multicast, and can emit events to different subscribers, like Subjects
 *
 * Example:
 * Stream.with(1, 2, 3)
 *      .mapBy(R.inc)
 *      .pairwise()
 *      .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
 * // Pair:[fst=2, snd=3]
 * // Pair:[fst=3, snd=4]
 * // Completed
 **/
public virtual class Stream implements Observable {
    // Exposed Funcs
    public static F Funcs = new F();

    // The source of events
    protected Source src = null;

    // Registered observers
    protected List<Observer> observers = null;

    // Whether the stream has been terminated, either completed or with error
    protected Boolean terminated = false;

    // Whether the stream will send events to multiple subscribers
    // Cold streams unicast while hot streams multicast
    protected Boolean multicast = false;

    /**
     * Construct a stream with a stream source
     *
     * @param src The stream source
     * */
    protected Stream(Stream.Source src) {
        this.src = src;
        this.observers = new List<Observer>();
        this.terminated = false;
    }

    /**
     * Create a stream from the stream source
     *
     * Example:
     * Stream.create(new CustomSource())
     *      .subscribe(R.debug);
     *
     * @param src The stream source
     * @return Stream
     * */
    public static Stream create(Stream.Source src) {
        return (Stream)Funcs.create.run(src);
    }

    /**
     * Create a stream from a value
     *
     * Example:
     * Stream.of('abc')
     *      .subscribe(R.debug);
     * // abc
     *
     * @param value The value to be passed into the stream
     * @return Stream
     * */
    public static Stream of(Object value) {
        return (Stream)Funcs.ofData.run(value);
    }

    /**
     * Create a stream that throws an error
     *
     * Example:
     * Stream.throwError('test error')
     *      .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // (Error: , test error)
     *
     * @param error The error object
     * @return Stream
     * */
    public static Stream throwError(Object error) {
        return (Stream)Funcs.throwError.run(error);
    }

    /**
     * Create an empty stream
     *
     * Example:
     * Stream.empty()
     *      .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // Completed
     *
     * @return Stream
     * */
    public static Stream empty() {
        return (Stream)Funcs.empty.run();
    }

    /**
     * Create a stream that ends without emitting error or complete
     *
     * Example:
     * Stream.never()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     *
     * @return Stream
     * */
    public static Stream never() {
        return (Stream)Funcs.never.run();
    }

    /**
     * Create a stream from the collection(list, set or map)
     *
     * Example:
     * Stream.fromData(new List<Object>{ 1, 2, 3 })
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param collection The collection object
     * @return Stream
     * */
    public static Stream fromData(Object collection) {
        return (Stream)Funcs.fromData.run(collection);
    }

    /**
     * Create a stream that emits one object
     *
     * Example:
     * Stream.with(1)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // Completed
     *
     * @param obj1 The first object
     * @return Stream
     * */
    public static Stream with(Object obj1) {
        return (Stream)Funcs.with.run(obj1);
    }

    /**
     * Create a stream that emits two objects
     *
     * Example:
     * Stream.with(1, 2)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // Completed
     *
     * @param obj1 The first object
     * @param obj2 The second object
     * @return Stream
     * */
    public static Stream with(Object obj1, Object obj2) {
        return (Stream)Funcs.with.run(obj1, obj2);
    }

    /**
     * Create a stream that emits three objects
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param obj1 The first object
     * @param obj2 The second object
     * @param obj3 The third object
     * @return Stream
     * */
    public static Stream with(Object obj1, Object obj2, Object obj3) {
        return (Stream)Funcs.with.run(obj1, obj2, obj3);
    }

    /**
     * Create a stream that emits N integers, starting from the first one
     *
     * Example:
     * Stream.range(1, 3)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param first The first integer
     * @param count The total integers
     * @return Stream
     * */
    public static Stream range(Integer first, Integer count) {
        return (Stream)Funcs.range.run(first, count);
    }

    /**
     * Create a stream according to the conditions
     *
     * Example:
     * Stream.generate(1, R.lt.apply(R.placeholder, 4), R.inc)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param initial The initial value
     * @param endCheck The Func to check when the generator stops
     * @param nextVal The Func to generate the next value
     * @return Stream
     * */
    public static Stream generate(Object initial, Func endCheck, Func nextVal) {
        return (Stream)Funcs.generate.run(initial, endCheck, nextVal);
    }

    /**
     * Create a stream that concatenates the list of streams
     *
     * Example:
     * Stream.concat(new List<Stream>{ Stream.of(1), Stream.of(2), Stream.of(3) })
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param streams The list of streams
     * @return Stream
     * */
    public static Stream concat(List<Stream> streams) {
        return (Stream)Funcs.concat.run(streams);
    }

    /**
     * Create a stream that concatenates one stream
     *
     * Example:
     * Stream.concat(Stream.with(1, 2, 3))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param s1 The first stream
     * @return Stream
     * */
    public static Stream concat(Stream s1) {
        return (Stream)Funcs.concat.run(s1);
    }

    /**
     * Create a stream that concatenates two streams
     *
     * Example:
     * Stream.concat(Stream.with(1, 2), Stream.with(3))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param s1 The first stream
     * @param s2 The second stream
     * @return Stream
     * */
    public static Stream concat(Stream s1, Stream s2) {
        return (Stream)Funcs.concat.run(s1, s2);
    }

    /**
     * Create a stream that concatenates three streams
     *
     * Example:
     * Stream.concat(Stream.with(1), Stream.with(2), Stream.with(3))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param s1 The first stream
     * @param s2 The second stream
     * @param s3 The third stream
     * @return Stream
     * */
    public static Stream concat(Stream s1, Stream s2, Stream s3) {
        return (Stream)Funcs.concat.run(s1, s2, s3);
    }

    /**
     * Subscribe an observer to the stream
     * If the stream is cold, it will emit all the events to this observer
     * If the stream is hot, it will emit events only when they come, to
     * this observer and previous observers
     *
     * Example:
     * Stream.of('abc')
     *      .subscribe(new Stream.FuncObserver(R.debug));
     * // abc
     *
     * @param ob The observer
     * */
    public void subscribe(Stream.Observer ob) {
        if(ob != null) {
            this.observers.add(ob);

            if(!this.multicast) {
                try {
                    if(this.src != null) {
                        this.src.execute(this);
                    }
                }
                catch(Exception e) {
                    this.onError(e);
                }
            }
        }
    }

    /**
     * Subscribe an observer to the stream
     * If the stream is cold, it will emit all the events to this observer
     * If the stream is hot, it will emit events only when they come, to
     * this observer and previous observers
     *
     * Example:
     * Stream.of('abc')
     *      .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // abc
     *
     * @param next The onNext Func to handle the next event
     * @param error The onError Func to handle the error case
     * @param complete The onComplete Func to handle the complete event
     * */
    public void subscribe(Func next, Func error, Func complete) {
        this.subscribe(new FuncObserver(next, error, complete));
    }

    /**
     * Subscribe an observer to the stream
     * If the stream is cold, it will emit all the events to this observer
     * If the stream is hot, it will emit events only when they come, to
     * this observer and previous observers
     *
     * Example:
     * Stream.of('abc')
     *      .subscribe(R.debug, R.debug.apply('Error: '));
     * // abc
     *
     * @param next The onNext Func to handle the next event
     * @param error The onError Func to handle the error case
     * */
    public void subscribe(Func next, Func error) {
        this.subscribe(new FuncObserver(next, error));
    }

    /**
     * Subscribe an observer to the stream
     * If the stream is cold, it will emit all the events to this observer
     * If the stream is hot, it will emit events only when they come, to
     * this observer and previous observers
     *
     * Example:
     * Stream.of('abc')
     *      .subscribe(R.debug);
     * // abc
     *
     * @param next The onNext Func to handle the next event
     * */
    public void subscribe(Func next) {
        this.subscribe(new FuncObserver(next));
    }

    /**
     * Concatenate the other streams
     *
     * Example:
     * Stream.of(1)
     *     .concatOther(new List<Stream>{ Stream.with(2, 3) })
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param streams The other streams
     * @return Stream
     * */
    public Stream concatOther(List<Stream> streams) {
        List<Stream> allStreams = new List<Stream>{ this };
        if(streams != null && !streams.isEmpty()) {
            allStreams.addAll(streams);
        }

        return concat(allStreams);
    }

    /**
     * Concatenate the other streams
     *
     * Example:
     * Stream.of(1)
     *     .concatOther(Stream.with(2, 3))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param s1 The first stream
     * @return Stream
     * */
    public Stream concatOther(Stream s1) {
        return this.concatOther(new List<Stream>{ s1 });
    }

    /**
     * Concatenate the other streams
     *
     * Example:
     * Stream.of(1)
     *     .concatOther(Stream.with(2), Stream.with(3))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param s1 The first stream
     * @param s2 The second stream
     * @return Stream
     * */
    public Stream concatOther(Stream s1, Stream s2) {
        return this.concatOther(new List<Stream>{ s1, s2 });
    }

    /**
     * Concatenate the other streams
     *
     * Example:
     * Stream.of(1)
     *     .concatOther(Stream.with(2), Stream.with(3), Stream.with(4))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // 4
     * // Completed
     *
     * @param s1 The first stream
     * @param s2 The second stream
     * @param s3 The third stream
     * @return Stream
     * */
    public Stream concatOther(Stream s1, Stream s2, Stream s3) {
        return this.concatOther(new List<Stream>{ s1, s2, s3 });
    }

    /**
     * Map the Func over the stream elements
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .mapBy(R.inc)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 2
     * // 3
     * // 4
     * // Completed
     *
     * @param f The mapping Func
     * @return Stream
     * */
    public Stream mapBy(Func f) {
        return create(new MapSource(this, f));
    }

    /**
     * Map the Func and flatten the stream
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .flatMap(Stream.Funcs.ofData.apply(4))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 4
     * // 4
     * // 4
     * // Completed
     *
     * @param f The mapping Func
     * @return Stream
     * */
    public Stream flatMap(Func f) {
        return this.mapBy(f).join();
    }

    /**
     * Map the element to the value
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .mapTo(4)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 4
     * // 4
     * // 4
     * // Completed
     *
     * @param value The value to map to
     * @return Stream
     * */
    public Stream mapTo(Object value) {
        return this.mapBy(R.constant.apply(value));
    }

    /**
     * Filter the stream
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .filter(R.equals.apply(2))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 2
     * // Completed
     *
     * @param f The fitler Func
     * @return Stream
     * */
    public Stream filter(Func f) {
        return create(new FilterSource(this, f));
    }

    /**
     * Similar to 'reduce', but emit the intermediate results
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .scan(R.add, 0)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 3
     * // 6
     * // Completed
     *
     * @param f The reducer
     * @param initial The initial value
     * @return Stream
     * */
    public Stream scan(Func f, Object initial) {
        return create(new ScanSource(this, f, initial));
    }

    /**
     * Reduce over the stream elements
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .reduce(R.add, 0)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 6
     * // Completed
     *
     * @param f The reducer
     * @param initial The initial value
     * @return Stream
     * */
    public Stream reduce(Func f, Object initial) {
        return create(new ReduceSource(this, f, initial));
    }

    /**
     * Catch the error and return the recovered value
     *
     * Example:
     * Stream.throwError('error')
     *     .catchError(R.constant.apply('success'))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // success
     * // Completed
     *
     * @param recover The recover Func
     * @return Stream
     * */
    public Stream catchError(Func recover) {
        return create(new CatchErrorSource(this, recover));
    }

    /**
     * Get the count of the stream items
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .count()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 3
     * // Completed
     *
     * @return Stream
     * */
    public Stream count() {
        return this.count(null);
    }

    /**
     * Get the count of the stream items
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .count(R.equals.apply(2))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // Completed
     *
     * @param pred The predicate Func
     * @return Stream
     * */
    public Stream count(Func pred) {
        return create(new CountSource(this, pred));
    }

    /**
     * Set the default value if the stream is empty
     *
     * Example:
     * Stream.empty()
     *     .defaultIfEmpty(1)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // Completed
     *
     * @param value The default value
     * @return Stream
     * */
    public Stream defaultIfEmpty(Object value) {
        return create(new DefaultIfEmptySource(this, value));
    }

    /**
     * Get a stream of distinct values, according to the key calculated by the Func
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .distinct(R.mod.apply(R.placeholder, 2))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // Completed
     *
     * @param f The key Func
     * @return Stream
     * */
    public Stream distinct(Func f) {
        return create(new DistinctSource(this, f));
    }

    /**
     * Get a stream of distinct values
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .distinct()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @return Stream
     * */
    public Stream distinct() {
        return this.distinct(null);
    }

    /**
     * Get a stream of values, distinct from the last one
     *
     * Example:
     * Stream.with(1, 2, 1)
     *     .distinctUntilChanged(R.equals, R.identity)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 1
     * // Completed
     *
     * @param compare The compare Func that returns Boolean
     * @param selector The selector Func that gets the key
     * @return Stream
     * */
    public Stream distinctUntilChanged(Func compare, Func selector) {
        return create(new DistinctUntilChangedSource(this, compare, selector));
    }

    /**
     * Get a stream of values, distinct from the last one
     *
     * Example:
     * Stream.with(1, 2, 1)
     *     .distinctUntilChanged(R.identity)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 1
     * // Completed
     *
     * @param selector The selector Func that gets the key
     * @return Stream
     * */
    public Stream distinctUntilChanged(Func selector) {
        return this.distinctUntilChanged(null, selector);
    }

    /**
     * Get a stream of values, distinct from the last one
     *
     * Example:
     * Stream.with(1, 2, 1)
     *     .distinctUntilChanged()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 1
     * // Completed
     *
     * @return Stream
     * */
    public Stream distinctUntilChanged() {
        return this.distinctUntilChanged(null);
    }

    /**
     * Get a stream of values, distinct from the last one by key value
     *
     * Example:
     * Stream.with(new Map<String, Object>{ 'name' => 'a' }, new Map<String, Object>{ 'name' => 'a' })
     *     .distinctUntilKeyChanged('name', R.equals)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // {name=a}
     * // Completed
     *
     * @param key The key of the object
     * @param compare The compare Func that returns Boolean
     * @return Stream
     * */
    public Stream distinctUntilKeyChanged(String key, Func compare) {
        return this.distinctUntilChanged(compare, R.prop.apply(key));
    }

    /**
     * Get a stream of values, distinct from the last one by key value
     *
     * Example:
     * Stream.with(new Map<String, Object>{ 'name' => 'a' }, new Map<String, Object>{ 'name' => 'a' })
     *     .distinctUntilKeyChanged('name')
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // {name=a}
     * // Completed
     *
     * @param key The key of the object
     * @return Stream
     * */
    public Stream distinctUntilKeyChanged(String key) {
        return this.distinctUntilKeyChanged(key, null);
    }

    /**
     * Get the Nth element, return default value if not found
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .elementAt(3, 4)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 4
     * // Completed
     *
     * @param index The index of the element
     * @param defaultValue The default value if not found
     * @return Stream
     * */
    public Stream elementAt(Integer index, Object defaultValue) {
        return create(new ElementAtSource(this, index, defaultValue));
    }

    /**
     * Get the Nth element
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .elementAt(2)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 3
     * // Completed
     *
     * @param index The index of the element
     * @return Stream
     * */
    public Stream elementAt(Integer index) {
        return this.elementAt(index, null);
    }

    /**
     * Check if every element matches the predicate
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .every(R.lt.apply(R.placeholder, 4))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // true
     * // Completed
     *
     * @param pred The predicate
     * @return Stream
     * */
    public Stream every(Func pred) {
        return create(new EverySource(this, pred));
    }

    /**
     * Flatten nested Streams
     *
     * Example:
     * Stream.with(1, Stream.of(2), 3)
     *     .join()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @return Stream
     * */
    public Stream join() {
        return create(new JoinSource(this));
    }

    /**
     * Register a Func that will be called either after completion or error
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .finalize(R.debug.apply(4))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // 4
     * // Completed
     *
     * @param f The finalizing Func
     * @return Stream
     * */
    public Stream finalize(Func f) {
        return create(new FinalizeSource(this, f));
    }

    /**
     * Find the first element that matches the predicate
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .find(R.equals.apply(2))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 2
     * // Completed
     *
     * @param pred The predicate
     * @return Stream
     * */
    public Stream find(Func pred) {
        return create(new FindSource(this, pred));
    }

    /**
     * Find the index of the first element that matches the predicate
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .findIndex(R.equals.apply(2))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // Completed
     *
     * @param pred The predicate
     * @return Stream
     * */
    public Stream findIndex(Func pred) {
        return create(new FindIndexSource(this, pred));
    }

    /**
     * Find the first element that matches the predicate, otherwise return the default value
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .first(R.equals.apply(4), 4)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 4
     * // Completed
     *
     * @param pred The predicate
     * @param defaultValue The default value
     * @return Stream
     * */
    public Stream first(Func pred, Object defaultValue) {
        return create(new FirstSource(this, pred, defaultValue));
    }

    /**
     * Find the first element that matches the predicate
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .first(R.equals.apply(4))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // null
     * // Completed
     *
     * @param pred The predicate
     * @return Stream
     * */
    public Stream first(Func pred) {
        return this.first(pred, null);
    }

    /**
     * Find the last element that matches the predicate, otherwise return the default value
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .last(R.equals.apply(4), 4)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 4
     * // Completed
     *
     * @param pred The predicate
     * @param defaultValue The default value
     * @return Stream
     * */
    public Stream last(Func pred, Object defaultValue) {
        return create(new LastSource(this, pred, defaultValue));
    }

    /**
     * Find the last element that matches the predicate
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .last(R.equals.apply(4))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // null
     * // Completed
     *
     * @param pred The predicate
     * @return Stream
     * */
    public Stream last(Func pred) {
        return this.last(pred, null);
    }

    /**
     * Group the elements into a map
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .groupBy(R.mod.apply(R.placeholder, 2))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // {0=(2), 1=(1, 3)}
     * // Completed
     *
     * @param f The key Func
     * @return Stream
     * */
    public Stream groupBy(Func f) {
        return create(new GroupBySource(this, f));
    }

    /**
     * Create a stream that ignores all elements
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .ignoreElements()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // Completed
     *
     * @return Stream
     * */
    public Stream ignoreElements() {
        return create(new IgnoreElementsSource(this));
    }

    /**
     * Check if the stream is empty
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .isEmpty()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // false
     * // Completed
     *
     * @return Stream
     * */
    public Stream isEmpty() {
        return this.count().mapBy(R.equals.apply(0));
    }

    /**
     * Get the max element according to the comparator Func that returns an Integer
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .max(R.compare)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 3
     * // Completed
     *
     * @param comparator The comparator Func
     * @return Stream
     * */
    public Stream max(Func comparator) {
        return create(new MaxSource(this, comparator));
    }

    /**
     * Get the max element
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .max()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 3
     * // Completed
     *
     * @return Stream
     * */
    public Stream max() {
        return this.max(null);
    }

    /**
     * Get the min element according to the comparator Func that returns an Integer
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .min(R.compare)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // Completed
     *
     * @param comparator The comparator Func
     * @return Stream
     * */
    public Stream min(Func comparator) {
        return create(new MinSource(this, comparator));
    }

    /**
     * Get the min element
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .min()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // Completed
     *
     * @return Stream
     * */
    public Stream min() {
        return this.min(null);
    }

    /**
     * Like 'concat', but continue to the next stream only when the first stream has errors
     *
     * Example:
     * Stream.throwError('error')
     *     .onErrorResumeNext(new List<Stream>{ Stream.of('success') })
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // success
     * // Completed
     *
     * @param streams The following streams
     * @return Stream
     * */
    public Stream onErrorResumeNext(List<Stream> streams) {
        List<Stream> allStreams = new List<Stream>();
        allStreams.add(this);
        if(streams != null && !streams.isEmpty()) {
            allStreams.addAll(streams);
        }

        return create(new ResumeSource(allStreams));
    }

    /**
     * Make pairs from adjacent stream items
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .pairwise()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // Pair:[fst=1, snd=2]
     * // Pair:[fst=2, snd=3]
     * // Completed
     *
     * @return Stream
     * */
    public Stream pairwise() {
        return create(new PairwiseSource(this));
    }

    /**
     * Pluck the value from the stream elements
     *
     * Example:
     * Stream.with(new Map<String, Object>{ 'name' => 'a' })
     *     .pluck('name')
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // a
     * // Completed
     *
     * @param property The property name
     * @return Stream
     * */
    public Stream pluck(String property) {
        return this.mapBy(R.prop.apply(property));
    }

    /**
     * Repeat the stream for N times
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .repeat(2)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // 3
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param n The repeating times
     * @return Stream
     * */
    public Stream repeat(Integer n) {
        return create(new RepeatSource(this, n));
    }

    /**
     * Get the single element from the stream that matches the predicate
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .single(R.equals.apply(2))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 2
     * // Completed
     *
     * @param pred The predicate
     * @return Stream
     * */
    public Stream single(Func pred) {
        return this.find(pred);
    }

    /**
     * Skip N elements from the stream
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .skip(2)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 3
     * // Completed
     *
     * @param n The N elements
     * @return Stream
     * */
    public Stream skip(Integer n) {
        return create(new SkipSource(this, n));
    }

    /**
     * Skip N elements from the last of the stream
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .skipLast(2)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // Completed
     *
     * @param n The N elements
     * @return Stream
     * */
    public Stream skipLast(Integer n) {
        return create(new SkipLastSource(this, n));
    }

    /**
     * Skip elements while the predicate is true
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .skipWhile(R.lt.apply(R.placeholder, 3))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 3
     * // Completed
     *
     * @param pred The predicate
     * @return Stream
     * */
    public Stream skipWhile(Func pred) {
        return create(new SkipWhileSource(this, pred));
    }

    /**
     * Take the first N elements from the stream
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .take(2)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // Completed
     *
     * @param n The N elements
     * @return Stream
     * */
    public Stream take(Integer n) {
        return create(new TakeSource(this, n));
    }

    /**
     * Take the last N elements from the stream
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .takeLast(2)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 2
     * // 3
     * // Completed
     *
     * @param n The N elements
     * @return Stream
     * */
    public Stream takeLast(Integer n) {
        return create(new TakeLastSource(this, n));
    }

    /**
     * Take elements while the predicate is true
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .takeWhile(R.lt.apply(R.placeholder, 3))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 2
     * // Completed
     *
     * @param pred The predicate
     * @return Stream
     * */
    public Stream takeWhile(Func pred) {
        return create(new TakeWhileSource(this, pred));
    }

    /**
     * Append the other stream to the stream
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .startWith(Stream.of(0))
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 0
     * // 1
     * // 2
     * // 3
     * // Completed
     *
     * @param other The other stream
     * @return Stream
     * */
    public Stream startWith(Stream other) {
        if(other == null) {
            return this;
        }

        List<Stream> streams = new List<Stream>{ other, this };
        return concat(streams);
    }

    /**
     * Pass the value through the Func
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .tap(R.debug)
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // 1
     * // 1
     * // 2
     * // 2
     * // 3
     * // 3
     * // Completed
     *
     * @param f The Func
     * @return Stream
     * */
    public Stream tap(Func f) {
        return create(new TapSource(this, f));
    }

    /**
     * Convert the strema elements to a list
     *
     * Example:
     * Stream.with(1, 2, 3)
     *     .toArray()
     *     .subscribe(R.debug, R.debug.apply('Error: '), R.debug.apply('Completed'));
     * // (1, 2, 3)
     * // Completed
     *
     * @return Stream
     * */
    public Stream toArray() {
        return create(new ToArraySource(this));
    }

    void onNext(Object value) {
        if(this.terminated) {
            return;
        }

        for(Observer ob : this.observers) {
            ob.onNext(value);
        }
    }

    void onError(Object error) {
        if(this.terminated) {
            return;
        }

        for(Observer ob : this.observers) {
            ob.onError(error);
        }

        this.terminated = true;
    }

    void onComplete() {
        if(this.terminated) {
            return;
        }

        for(Observer ob : this.observers) {
            ob.onComplete();
        }

        this.terminated = true;
    }

    /**
     * A subject is a hot stream that can multicast events to multiple observers
     *
     * Example:
     * Stream.Subject s = new Stream.Subject();
     * s.subscribe(...);
     * s.next('a');
     * s.complete();
     * */
    public class Subject extends Stream {
        /**
         * Create a default subject
         * */
        public Subject() {
            super(null);

            this.multicast = true;
        }

        /**
         * Send an event to the subject
         *
         * @param value The event value
         * */
        public void next(Object value) {
            super.onNext(value);
        }

        /**
         * Send an error to the subject
         *
         * @param error The error
         * */
        public void error(Object error) {
            super.onError(error);
        }

        /**
         * Mark the subject as complete
         * */
        public void complete() {
            super.onComplete();
        }
    }

    /**
     * The source of the stream
     * */
    private virtual class Source {

        /**
         * When executed, emit events to the stream
         * */
        public virtual void execute(Stream s) {
        }
    }

    private class ValueSource extends Source {
        private Object value;

        public ValueSource(Object value) {
            this.value = value;
        }

        public override void execute(Stream s) {
            s.onNext(this.value);
            s.onComplete();
        }
    }

    private class ErrorSource extends Source {
        private Object error;

        public ErrorSource(Object error) {
            this.error = error;
        }

        public override void execute(Stream s) {
            s.onError(this.error);
        }
    }

    private class EmptySource extends Source {
        public EmptySource() {
        }

        public override void execute(Stream s) {
            s.onComplete();
        }
    }

    private class NeverSource extends Source {
        public NeverSource() {
        }

        public override void execute(Stream s) {
        }
    }

    private class DataSource extends Source {
        private Object collection;

        public DataSource(Object collection) {
            this.collection = collection;
        }

        public override void execute(Stream s) {
            if((Boolean)R.isListLike.run(this.collection)) {
                List<Object> mList = (List<Object>)R.toList.run(this.collection);
                for(Object val : mList) {
                    s.onNext(val);
                }
            }
            else if((Boolean)R.isSetLike.run(this.collection)) {
                Set<String> mSet = (Set<String>)R.toSet.run(this.collection);
                for(String val : mSet) {
                    s.onNext(val);
                }
            }
            else if((Boolean)R.isMapLike.run(this.collection)) {
                Map<String, Object> mMap = (Map<String, Object>)R.toMap.run(this.collection);
                for(String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    R.Pair pair = new R.Pair(key, val);
                    s.onNext(pair);
                }
            }
            else {
                s.onNext(this.collection);
            }

            s.onComplete();
        }
    }

    private class RangeSource extends Source {
        private Integer first = 0;
        private Integer count = 0;

        public RangeSource(Integer first, Integer count) {
            this.first = first;
            this.count = count;
        }

        public override void execute(Stream s) {
            Integer i = 0;
            while(i < count) {
                s.onNext(this.first + i);

                i += 1;
            }

            s.onComplete();
        }
    }

    private class GenerateSource extends Source {
        private Object initial;
        private Func endCheck;
        private Func nextVal;

        public GenerateSource(Object initial, Func endCheck, Func nextVal) {
            this.initial = initial;
            this.endCheck = endCheck;
            this.nextVal = nextVal;
        }

        public override void execute(Stream s) {
            Object curr = this.initial;
            while(true) {
                Boolean pass = false;
                if(this.endCheck != null) {
                    pass = (Boolean)this.endCheck.run(curr);
                }

                if(pass) {
                    s.onNext(curr);
                }
                else {
                    break;
                }

                if(this.nextVal != null) {
                    curr = this.nextVal.run(curr);
                }
            }

            s.onComplete();
        }
    }

    /**
     * The default source that also works as an observer
     *
     * Extend from this source
     *
     * */
    public virtual class ObserverSource extends Source implements Observer {
        protected Stream target;
        protected Stream prev;

        public ObserverSource(Stream prev) {
            this.prev = prev;
        }

        public ObserverSource() {
            this(null);
        }

        public virtual override void execute(Stream s) {
            this.target = s;
            if(this.prev == null) {
                this.prev = this.target;
            }
            this.prev.subscribe(this);
        }

        public virtual void onNext(Object value) {
            this.target.onNext(value);
        }

        public virtual void onError(Object error) {
            this.target.onError(error);
        }

        public virtual void onComplete() {
            this.target.onComplete();
        }
    }

    private class ToArraySource extends ObserverSource {
        private List<Object> items;

        public ToArraySource(Stream prev) {
            super(prev);
            this.items = new List<Object>();
        }

        public override void onNext(Object value) {
            this.items.add(value);
        }

        public override void onComplete() {
            super.onNext(this.items);
            super.onComplete();
        }
    }

    private class TapSource extends ObserverSource {
        private Func f;

        public TapSource(Stream prev, Func f) {
            super(prev);
            this.f = f;
        }

        public override void onNext(Object value) {
            if(this.f != null) {
                this.f.run(value);
            }

            super.onNext(value);
        }
    }

    private class TakeWhileSource extends ObserverSource {
        private Func pred;

        public TakeWhileSource(Stream prev, Func pred) {
            super(prev);
            this.pred = pred;
        }

        public override void onNext(Object value) {
            Boolean take = true;
            if(this.pred != null) {
                take = (Boolean)this.pred.run(value);
            }

            if(take) {
                super.onNext(value);
            }
        }
    }

    private class TakeSource extends ObserverSource {
        private Integer count = 0;
        private Integer take = 0;

        public TakeSource(Stream prev, Integer take) {
            super(prev);
            this.take = take;
        }

        public override void onNext(Object value) {
            if(this.count < this.take) {
                this.count += 1;
                super.onNext(value);
            }
        }
    }

    private class TakeLastSource extends ObserverSource {
        private Integer take = 0;
        private List<Object> cache = null;

        public TakeLastSource(Stream prev, Integer take) {
            super(prev);
            this.take = take;
            this.cache = new List<Object>();
        }

        public override void onNext(Object value) {
            if(this.cache.size() < this.take) {
                this.cache.add(value);
            }
            else {
                this.cache.add(value);
                this.cache.remove(0);
            }
        }

        public override void onComplete() {
            for(Object item : this.cache) {
                super.onNext(item);
            }

            super.onComplete();
        }
    }

    private class SkipWhileSource extends ObserverSource {
        private Func pred;

        public SkipWhileSource(Stream prev, Func pred) {
            super(prev);
            this.pred = pred;
        }

        public override void onNext(Object value) {
            Boolean skip = false;
            if(this.pred != null) {
                skip = (Boolean)this.pred.run(value);
            }

            if(!skip) {
                super.onNext(value);
            }
        }
    }

    private class SkipSource extends ObserverSource {
        private Integer count = 0;
        private Integer skip = 0;

        public SkipSource(Stream prev, Integer skip) {
            super(prev);
            this.skip = skip;
        }

        public override void onNext(Object value) {
            if(this.count < this.skip) {
                this.count += 1;
            }
            else {
                super.onNext(value);
            }
        }
    }

    private class SkipLastSource extends ObserverSource {
        private Integer skip = 0;
        private List<Object> cache = null;

        public SkipLastSource(Stream prev, Integer skip) {
            super(prev);
            this.skip = skip;
            this.cache = new List<Object>();
        }

        public override void onNext(Object value) {
            if(this.cache.size() < this.skip) {
                this.cache.add(value);
            }
            else {
                this.cache.add(value);
                super.onNext(this.cache.remove(0));
            }
        }
    }

    private class RepeatSource extends ObserverSource {
        private Integer n = 0;
        private List<Object> items = null;

        public RepeatSource(Stream prev, Integer n) {
            super(prev);
            this.n = n;
            this.items = new List<Object>();
        }

        public override void onNext(Object value) {
            this.items.add(value);
            super.onNext(value);
        }

        public override void onComplete() {
            for(Integer i = 1; i < this.n; i++) {
                for(Object item : this.items) {
                    super.onNext(item);
                }
            }

            super.onComplete();
        }
    }

    private class PairwiseSource extends ObserverSource {
        private Object last;

        public PairwiseSource(Stream prev) {
            super(prev);
        }

        public override void onNext(Object value) {
            if(this.last == null) {
                this.last = value;
            }
            else {
                R.Pair pair = new R.Pair(this.last, value);
                this.last = value;
                super.onNext(pair);
            }
        }
    }

    private class MinSource extends ObserverSource {
        private Func comparator;
        private Object min;

        public MinSource(Stream prev, Func comparator) {
            super(prev);
            this.comparator = comparator;

            if(this.comparator == null) {
                this.comparator = R.compare;
            }
        }

        public override void onNext(Object value) {
            if(this.min == null) {
                this.min = value;
            }
            else {
                this.min = (Integer)this.comparator.run(this.min, value) > 0 ? value : this.min;
            }
        }

        public override void onComplete() {
            super.onNext(this.min);
            super.onComplete();
        }
    }

    private class MaxSource extends ObserverSource {
        private Func comparator;
        private Object max;

        public MaxSource(Stream prev, Func comparator) {
            super(prev);
            this.comparator = comparator;

            if(this.comparator == null) {
                this.comparator = R.compare;
            }
        }

        public override void onNext(Object value) {
            if(this.max == null) {
                this.max = value;
            }
            else {
                this.max = (Integer)this.comparator.run(this.max, value) < 0 ? value : this.max;
            }
        }

        public override void onComplete() {
            super.onNext(this.max);
            super.onComplete();
        }
    }

    private class IgnoreElementsSource extends ObserverSource {
        public IgnoreElementsSource(Stream prev) {
            super(prev);
        }

        public override void onNext(Object value) {
        }
    }

    private class GroupBySource extends ObserverSource {
        private Func f;
        private Map<String, List<Object>> groups = null;

        public GroupBySource(Stream prev, Func f) {
            super(prev);
            this.f = f;
            this.groups = new Map<String, List<Object>>();
        }

        public override void onNext(Object value) {
            String key = (String)R.toString.run(value);
            if(this.f != null) {
                key = (String)R.toString.run(this.f.run(value));
            }

            List<Object> keyGroup = this.groups.get(key);
            if(keyGroup == null) {
                keyGroup = new List<Object>();
                this.groups.put(key, keyGroup);
            }

            keyGroup.add(value);
        }

        public override void onComplete() {
            super.onNext(this.groups);
            super.onComplete();
        }
    }

    private class LastSource extends ObserverSource {
        private Func pred;
        private Object defaultValue;
        private Boolean found = false;
        private Object foundValue = null;

        public LastSource(Stream prev, Func pred, Object defaultValue) {
            super(prev);
            this.pred = pred;
            this.defaultValue = defaultValue;
        }

        public override void onNext(Object value) {
            if(this.pred != null) {
                Boolean pass = (Boolean)this.pred.run(value);
                if(pass) {
                    this.found = true;
                    this.foundValue = value;
                }
            }
            else {
                super.onNext(value);
            }
        }

        public override void onComplete() {
            if(!this.found) {
                super.onNext(this.defaultValue);
            }
            else {
                super.onNext(this.foundValue);
            }

            super.onComplete();
        }
    }

    private class FirstSource extends ObserverSource {
        private Func pred;
        private Object defaultValue;
        private Boolean found = false;

        public FirstSource(Stream prev, Func pred, Object defaultValue) {
            super(prev);
            this.pred = pred;
            this.defaultValue = defaultValue;
        }

        public override void onNext(Object value) {
            if(this.pred != null) {
                Boolean pass = (Boolean)this.pred.run(value);
                if(pass) {
                    this.found = true;
                    super.onNext(value);
                    this.onComplete();
                }
            }
            else {
                super.onNext(value);
            }
        }

        public override void onComplete() {
            if(!this.found) {
                super.onNext(this.defaultValue);
            }

            super.onComplete();
        }
    }

    private class FindSource extends ObserverSource {
        private Func pred;

        public FindSource(Stream prev, Func pred) {
            super(prev);
            this.pred = pred;
        }

        public override void onNext(Object value) {
            if(this.pred != null) {
                Boolean pass = (Boolean)this.pred.run(value);
                if(pass) {
                    super.onNext(value);
                    super.onComplete();
                }
            }
            else {
                super.onNext(value);
            }
        }
    }

    private class FindIndexSource extends ObserverSource {
        private Func pred;
        private Integer index = -1;

        public FindIndexSource(Stream prev, Func pred) {
            super(prev);
            this.pred = pred;
        }

        public override void onNext(Object value) {
            if(this.pred != null) {
                this.index += 1;
                Boolean pass = (Boolean)this.pred.run(value);
                if(pass) {
                    super.onNext(this.index);
                    super.onComplete();
                }
            }
            else {
                super.onNext(value);
            }
        }
    }

    private class FinalizeSource extends ObserverSource {
        private Func f;

        public FinalizeSource(Stream prev, Func f) {
            super(prev);
            this.f = f;
        }

        public override void onError(Object error) {
            if(this.f != null) {
                this.f.run();
            }

            super.onError(error);
        }

        public override void onComplete() {
            if(this.f != null) {
                this.f.run();
            }

            super.onComplete();
        }
    }

    private class JoinSource extends ObserverSource {
        private Integer depth = 0;

        public JoinSource(Stream prev) {
            super(prev);
        }

        public override void onNext(Object value) {
            if(value instanceof Stream) {
                Stream child = (Stream)value;
                depth += 1;
                child.subscribe(this);
            }
            else {
                super.onNext(value);
            }
        }

        public override void onComplete() {
            if(depth != 0) {
                depth -= 1;
            }
            else {
                super.onComplete();
            }
        }
    }

    private class EverySource extends ObserverSource {
        private Func pred;
        private Boolean pass = true;

        public EverySource(Stream prev, Func pred) {
            super(prev);
            this.pred = pred;
        }

        public override void onNext(Object value) {
            if(this.pred != null && pass) {
                pass = (Boolean)this.pred.run(value);
            }
        }

        public override void onComplete() {
            super.onNext(this.pass);
            super.onComplete();
        }
    }

    private class ElementAtSource extends ObserverSource {
        private Integer index;
        private Object defaultValue;
        private Integer curr = 0;
        private Boolean found = false;

        public ElementAtSource(Stream prev, Integer index, Object defaultValue) {
            super(prev);
            this.index = index;
            this.defaultValue = defaultValue;
        }

        public override void onNext(Object value) {
            if(this.index == this.curr) {
                Object retValue = value;
                this.found = true;
                if(retValue == null) {
                    retValue = this.defaultValue;
                }
                super.onNext(retValue);
            }

            this.curr += 1;
        }

        public override void onComplete() {
            if(!this.found) {
                super.onNext(this.defaultValue);
            }

            super.onComplete();
        }
    }

    private class DistinctUntilChangedSource extends ObserverSource {
        private Func compare;
        private Func selector;
        private Object last;

        public DistinctUntilChangedSource(Stream prev, Func compare, Func selector) {
            super(prev);
            this.compare = compare;
            this.selector = selector;
        }

        public override void onNext(Object value) {
            Object key = value;
            if(this.selector != null) {
                key = this.selector.run(value);
            }

            Boolean equals = (key == this.last);

            if(this.compare != null) {
                equals = (Boolean)this.compare.run(key, this.last);
            }

            if(!equals) {
                this.last = key;
                super.onNext(value);
            }
        }
    }

    private class DistinctSource extends ObserverSource {
        private Func f;
        private Set<Object> keys = new Set<Object>();

        public DistinctSource(Stream prev, Func f) {
            super(prev);
            this.f = f;
        }

        public override void onNext(Object value) {
            Object key = value;
            if(this.f != null) {
                key = this.f.run(value);
            }

            if(!this.keys.contains(key)) {
                this.keys.add(key);
                super.onNext(value);
            }
        }
    }

    private class DefaultIfEmptySource extends ObserverSource {
        private Object value;
        private Integer count = 0;

        public DefaultIfEmptySource(Stream prev, Object value) {
            super(prev);
            this.value = value;
        }

        public override void onNext(Object value) {
            this.count += 1;
            super.onNext(value);
        }

        public override void onComplete() {
            if(this.count == 0) {
                super.onNext(this.value);
            }

            super.onComplete();
        }
    }

    private class CountSource extends ObserverSource {
        private Integer count = 0;
        private Func pred;

        public CountSource(Stream prev, Func pred) {
            super(prev);
            this.pred = pred;
        }

        public override void onNext(Object value) {
            Boolean pass = true;
            if(this.pred != null) {
                pass = (Boolean)this.pred.run(value);
            }

            if(pass) {
                this.count += 1;
            }
        }

        public override void onComplete() {
            super.onNext(this.count);
            super.onComplete();
        }
    }

    private class CatchErrorSource extends ObserverSource {
        private Func recover;

        public CatchErrorSource(Stream prev, Func recover) {
            super(prev);
            this.recover = recover;
        }

        public override void onError(Object error) {
            if(this.recover != null) {
                Object value = this.recover.run(error);

                super.onNext(value);
            }

            super.onComplete();
        }
    }

    private class ReduceSource extends ObserverSource {
        private Func f;
        private Object curr;

        public ReduceSource(Stream prev, Func f, Object initial) {
            super(prev);
            this.f = f;
            this.curr = initial;
        }

        public override void onNext(Object value) {
            if(this.f != null) {
                this.curr = this.f.run(this.curr, value);
            }
        }

        public override void onComplete() {
            super.onNext(this.curr);
            super.onComplete();
        }
    }

    private class ScanSource extends ObserverSource {
        private Func f;
        private Object curr;

        public ScanSource(Stream prev, Func f, Object initial) {
            super(prev);
            this.f = f;
            this.curr = initial;
        }

        public override void onNext(Object value) {
            Object newValue = value;
            if(this.f != null) {
                this.curr = this.f.run(this.curr, value);
                newValue = this.curr;
            }

            super.onNext(newValue);
        }
    }

    private class MapSource extends ObserverSource {
        private Func f;

        public MapSource(Stream prev, Func f) {
            super(prev);
            this.f = f;
        }

        public override void onNext(Object value) {
            Object newValue = value;
            if(this.f != null) {
                newValue = this.f.run(value);
            }

            super.onNext(newValue);
        }
    }

    private class FilterSource extends ObserverSource {
        private Func f;

        public FilterSource(Stream prev, Func f) {
            super(prev);
            this.f = f;
        }

        public override void onNext(Object value) {
            Boolean pass = true;
            if(this.f != null) {
                pass = (Boolean)this.f.run(value);
            }

            if(pass) {
                super.onNext(value);
            }
        }
    }

    private class ResumeSource extends ObserverSource {
        private List<Stream> streams;
        private Integer index = 0;

        public ResumeSource(List<Stream> streams) {
            this.streams = streams;
        }

        public override void execute(Stream s) {
            this.target = s;

            if(!this.streams.isEmpty()) {
                Stream input = this.streams.get(0);
                this.index += 1;
                input.subscribe(this);
            }
        }

        public override void onError(Object error) {
            if(this.index < this.streams.size()) {
                Stream input = this.streams.get(this.index);
                this.index += 1;
                input.subscribe(this);
            }
            else {
                super.onError(error);
            }
        }
    }

    private class ConcatSource extends ObserverSource {
        private List<Stream> streams;
        private Integer index;

        public ConcatSource(List<Stream> streams) {
            this.streams = streams;
        }

        public override void execute(Stream s) {
            this.target = s;

            for(Integer i = 0; i < this.streams.size(); i++) {
                this.index = i;
                Stream input = this.streams.get(i);
                input.subscribe(this);
            }
        }

        public override void onComplete() {
            if(this.index == this.streams.size() - 1) {
                super.onComplete();
            }
        }
    }

    /**
     * An observable that emits events and notifies any observers
     * */
    public interface Observable {
        /**
         * Subscribes any observer
         *
         * Emits all events if the scream is cold
         *
         * @param ob The observer
         * */
        void subscribe(Observer ob);
    }

    public interface Observer {
        void onNext(Object value);

        void onError(Object error);

        void onComplete();
    }

    public class FuncObserver implements Observer {
        private Func next;
        private Func error;
        private Func complete;

        public FuncObserver(Func next, Func error, Func complete) {
            this.next = next;
            this.error = error;
            this.complete = complete;
        }

        public FuncObserver(Func next, Func error) {
            this(next, error, null);
        }

        public FuncObserver(Func next) {
            this(next, null);
        }

        public void onNext(Object value) {
            if(this.next != null) {
                this.next.run(value);
            }
        }

        public void onError(Object error) {
            if(this.error != null) {
                this.error.run(error);
            }
        }

        public void onComplete() {
            if(this.complete != null) {
                this.complete.run();
            }
        }
    }

    public class F {
        public Func create = new CreateFunc();
        public Func ofData = new OfFunc();
        public Func throwError = new ThrowErrorFunc();
        public Func empty = new EmptyFunc();
        public Func never = new NeverFunc();
        public Func fromData = new FromFunc();
        public Func with = new WithFunc();
        public Func range = new RangeFunc();
        public Func generate = new GenerateFunc();
        public Func concat = new ConcatFunc();
    }

    private class ConcatFunc extends Func {
        public ConcatFunc() {
            super(-1);
        }

        public override Object exec(Object arg) {
            if(arg instanceof List<Stream>) {
                List<Stream> streams = (List<Stream>)arg;

                return new Stream(new ConcatSource(streams));
            }
            else if(arg instanceof Stream) {
                return this.exec(new List<Stream>{ (Stream)arg });
            }
            else {
                return arg;
            }
        }

        public override Object exec(Object arg1, Object arg2) {
            return this.exec(new List<Stream>{ (Stream)arg1, (Stream)arg2 });
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            return this.exec(new List<Stream>{ (Stream)arg1, (Stream)arg2, (Stream)arg3 });
        }
    }

    private class GenerateFunc extends Func {
        public GenerateFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Object initial = arg1;
            Func endCheck = (Func)R.toFunc.run(arg2);
            Func nextVal = (Func)R.toFunc.run(arg3);

            return new Stream(new GenerateSource(initial, endCheck, nextVal));
        }
    }

    private class RangeFunc extends Func {
        public RangeFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Integer first = (Integer)R.toInteger.run(arg1);
            Integer count = (Integer)R.toInteger.run(arg2);

            return new Stream(new RangeSource(first, count));
        }
    }

    private class WithFunc extends Func {
        public WithFunc() {
            super(-1);
        }

        public override Object execN(List<Object> args) {
            return Funcs.fromData.run(args);
        }
    }

    private class FromFunc extends Func {
        public FromFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Object collection = arg;
            return new Stream(new DataSource(collection));
        }
    }

    private class NeverFunc extends Func {
        public NeverFunc() {
            super(0);
        }

        public override Object exec() {
            return new Stream(new NeverSource());
        }
    }

    private class EmptyFunc extends Func {
        public EmptyFunc() {
            super(0);
        }

        public override Object exec() {
            return new Stream(new EmptySource());
        }
    }

    private class ThrowErrorFunc extends Func {
        public ThrowErrorFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Object error = arg;
            return new Stream(new ErrorSource(error));
        }
    }

    private class OfFunc extends Func {
        public OfFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Object value = arg;
            return new Stream(new ValueSource(value));
        }
    }

    private class CreateFunc extends Func {
        public CreateFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Source src = (Source)arg;

            return new Stream(src);
        }
    }
}
