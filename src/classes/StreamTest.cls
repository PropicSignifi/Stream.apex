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
@isTest
private class StreamTest {
    private static Func assertContains = (Func)R.pipe.run(
        (Func)R.flip.run(R.contains),
        R.assert
    );

    private class TraceFunc extends Func {
        private Func f;
        private Integer count = 0;

        public TraceFunc(Func f) {
            super(-1);
            this.f = f;
        }

        public Integer getCount() {
            return this.count;
        }

        public override Object execN(List<Object> args) {
            this.count += 1;

            return f.runN(args);
        }
    }

    private static TraceFunc trace(Func f) {
        return new TraceFunc(f);
    }

    @isTest
    private static void valueSourceTest() {
        TraceFunc tf = trace(R.assertEquals.apply(1));

        Stream.of(1)
            .subscribe(tf, R.assert.apply(false), R.assert.apply(true));

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void errorSourceTest() {
        TraceFunc tf = trace(R.assertEquals.apply('error'));

        Stream.throwError('error')
            .subscribe(R.assert.apply(false), tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void emptySourceTest() {
        TraceFunc tf = trace(R.assert.apply(false));

        Stream.empty()
            .subscribe(tf, R.assert.apply(false), R.assert.apply(true));

        System.assertEquals(0, tf.getCount());
    }

    @isTest
    private static void neverSourceTest() {
        TraceFunc tf = trace(R.assert.apply(false));

        Stream.never()
            .subscribe(R.assert.apply(false), R.assert.apply(false), tf);

        System.assertEquals(0, tf.getCount());
    }

    @isTest
    private static void fromDataSourceTest() {
        TraceFunc tf = trace(R.assertEquals.apply(1));

        Stream.fromData(new List<Object>{ 1 })
            .subscribe(tf, R.assert.apply(false));

        System.assertEquals(1, tf.getCount());

        Stream.fromData(new Set<String>{ 'a' })
            .subscribe(R.assertEquals.apply('a'), R.assert.apply(false));

        Stream.fromData(new Map<String, Object>{ 'key' => 'value' })
            .subscribe(R.assertEquals.apply(new R.Pair('key', 'value')), R.assert.apply(false));
    }

    @isTest
    private static void rangeSourceTest() {
        TraceFunc tf = trace(R.assertEquals.apply(1));

        Stream.range(1, 1)
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void withSourceTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 1, 2, 3 }));

        Stream.with(1, 2, 3)
            .subscribe(tf);

        System.assertEquals(3, tf.getCount());
    }

    @isTest
    private static void generateSourceTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 1, 2, 3 }));

        Stream.generate(1, R.lt.apply(R.placeholder, 4), R.inc)
            .subscribe(tf);

        System.assertEquals(3, tf.getCount());
    }

    @isTest
    private static void concatSourceTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 1, 2, 3, 4, 5, 6 }));

        Stream.concat(Stream.with(1, 2, 3), Stream.with(4, 5, 6))
            .subscribe(tf);

        System.assertEquals(6, tf.getCount());
    }

    @isTest
    private static void mapTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 2, 3, 4 }));

        Stream.with(1, 2, 3)
            .mapBy(R.inc)
            .subscribe(tf);

        System.assertEquals(3, tf.getCount());
    }

    @isTest
    private static void filterTest() {
        TraceFunc tf = trace(R.assertEquals.apply(2));

        Stream.with(1, 2, 3)
            .filter(R.equals.apply(2))
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void scanTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 1, 3, 6 }));

        Stream.with(1, 2, 3)
            .scan(R.add, 0)
            .subscribe(tf);

        System.assertEquals(3, tf.getCount());
    }

    @isTest
    private static void reduceTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 6 }));

        Stream.with(1, 2, 3)
            .reduce(R.add, 0)
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void catchErrorTest() {
        TraceFunc tf = trace(R.assertEquals.apply('success'));

        Stream.throwError('error')
            .catchError(R.constant.apply('success'))
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void countTest() {
        TraceFunc tf = trace(R.assertEquals.apply(1));

        Stream.with(1, 2, 3)
            .count(R.equals.apply(2))
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void defaultIfEmptyTest() {
        TraceFunc tf = trace(R.assertEquals.apply('a'));

        Stream.empty()
            .defaultIfEmpty('a')
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void distinctTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 1, 2 }));

        Stream.with(1, 2, 2)
            .distinct()
            .subscribe(tf);

        System.assertEquals(2, tf.getCount());
    }

    @isTest
    private static void distinctUntilKeyChangedTest() {
        TraceFunc tf = trace(R.assertEquals.apply(new Map<String, Object>{ 'name' => 'a' }));

        Stream.with(new Map<String, Object>{ 'name' => 'a' }, new Map<String, Object>{ 'name' => 'a' })
            .distinctUntilKeyChanged('name')
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void elementAtTest() {
        TraceFunc tf = trace(R.assertEquals.apply(2));

        Stream.with(1, 2, 3)
            .elementAt(1)
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void everyTest() {
        TraceFunc tf = trace(R.assertEquals.apply(true));

        Stream.with(1, 2, 3)
            .every(R.gt.apply(R.placeholder, 0))
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void joinTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 1, 2, 3 }));

        Stream.with(1, Stream.with(2), 3)
            .join()
            .subscribe(tf);

        System.assertEquals(3, tf.getCount());
    }

    @isTest
    private static void finalizeTest() {
        TraceFunc tf = trace(R.debug.apply('finalize'));

        Stream.with(1, 2, 3)
            .finalize(tf)
            .subscribe(R.debug);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void findTest() {
        TraceFunc tf = trace(R.equals.apply(2));

        Stream.with(1, 2, 3)
            .find(R.equals.apply(2))
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void findIndexTest() {
        TraceFunc tf = trace(R.equals.apply(1));

        Stream.with(1, 2, 3)
            .findIndex(R.equals.apply(2))
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void firstTest() {
        TraceFunc tf = trace(R.equals.apply(4));

        Stream.with(1, 2, 3)
            .first(R.equals.apply(4), 4)
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void lastTest() {
        TraceFunc tf = trace(R.equals.apply(4));

        Stream.with(1, 2, 3)
            .last(R.equals.apply(4), 4)
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void subjectTest() {
        TraceFunc tf = trace(R.equals.apply(1));

        Stream.Subject s = new Stream.Subject();
        s.subscribe(tf);

        s.next(1);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void groupByTest() {
        TraceFunc tf = trace(R.debug);

        Stream.with(1, 2, 3)
            .groupBy(R.identity)
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void ignoreElementsTest() {
        TraceFunc tf = trace(R.debug);

        Stream.with(1, 2, 3)
            .ignoreElements()
            .subscribe(tf);

        System.assertEquals(0, tf.getCount());
    }

    @isTest
    private static void isEmptyTest() {
        TraceFunc tf = trace(R.assert);

        Stream.empty()
            .isEmpty()
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void maxTest() {
        TraceFunc tf = trace(R.assertEquals.apply(3));

        Stream.with(1, 2, 3)
            .max()
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void minTest() {
        TraceFunc tf = trace(R.assertEquals.apply(1));

        Stream.with(1, 2, 3)
            .min()
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void onErrorResumeNextTest() {
        TraceFunc tf = trace(R.assertEquals.apply('success'));

        Stream.throwError('error')
            .onErrorResumeNext(new List<Stream>{ Stream.of('success') })
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void pairwiseTest() {
        TraceFunc tf = trace(R.debug);

        Stream.with(1, 2, 3)
            .pairwise()
            .subscribe(tf);

        System.assertEquals(2, tf.getCount());
    }

    @isTest
    private static void repeatTest() {
        TraceFunc tf = trace(R.debug);

        Stream.with(1, 2, 3)
            .repeat(2)
            .subscribe(tf);

        System.assertEquals(6, tf.getCount());
    }

    @isTest
    private static void skipTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 2, 3 }));

        Stream.with(1, 2, 3)
            .skip(1)
            .subscribe(tf);

        System.assertEquals(2, tf.getCount());
    }

    @isTest
    private static void skipLastTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 1, 2 }));

        Stream.with(1, 2, 3)
            .skipLast(1)
            .subscribe(tf);

        System.assertEquals(2, tf.getCount());
    }

    @isTest
    private static void skipWhileTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 3 }));

        Stream.with(1, 2, 3)
            .skipWhile(R.lt.apply(R.placeholder, 3))
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void takeTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 1 }));

        Stream.with(1, 2, 3)
            .take(1)
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void takeLastTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 3 }));

        Stream.with(1, 2, 3)
            .takeLast(1)
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }

    @isTest
    private static void takeWhileTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 1, 2 }));

        Stream.with(1, 2, 3)
            .takeWhile(R.lt.apply(R.placeholder, 3))
            .subscribe(tf);

        System.assertEquals(2, tf.getCount());
    }

    @isTest
    private static void startWithTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{ 0, 1, 2, 3 }));

        Stream.with(1, 2, 3)
            .startWith(Stream.of(0))
            .subscribe(tf);

        System.assertEquals(4, tf.getCount());
    }

    @isTest
    private static void tapTest() {
        TraceFunc tf = trace(R.debug);

        Stream.with(1, 2, 3)
            .tap(tf)
            .subscribe(tf);

        System.assertEquals(6, tf.getCount());
    }

    @isTest
    private static void toArrayTest() {
        TraceFunc tf = trace(R.assertEquals.apply(new List<Object>{ 1, 2, 3 }));

        Stream.with(1, 2, 3)
            .toArray()
            .subscribe(tf);

        System.assertEquals(1, tf.getCount());
    }
}
