library data_loader_test.unit.core_mvc;

import 'package:test/test.dart';
import 'package:core_mvc/data_loader.dart' show DataLoader, LoaderResult, CacheKeyFn;
import 'dart:async' show Future, scheduleMicrotask;

idLoader({bool cache: true, batch: true, CacheKeyFn cacheKeyFn: null, Map cacheMap: null}) {
  final loadCalls = [];
  final identityLoader = new DataLoader((keys) async {
    loadCalls.add(keys);
    return keys.map((e) => new LoaderResult(value: e));
  }, cache: cache, batch: batch, cacheKeyFn: cacheKeyFn, cacheMap: cacheMap);
  return [ identityLoader, loadCalls ];
}

void main() {
  test('builds a really really simple data loader', () async {
    final identityLoader = new DataLoader<int, int>((keys) async => keys.map((e) => new LoaderResult<int>(value: e)));

    final future1 = identityLoader.load(1);
    expect(future1, new isInstanceOf<Future<LoaderResult<int>>>());

    final result = await future1;
    expect(result.value, equals(1));
  });

  test('supports loading multiple keys in one call', () async {
    final identityLoader = new DataLoader<int, int>((keys) async => keys.map((e) => new LoaderResult<int>(value: e)));

    final futureAll = identityLoader.loadMany([1, 2]);
    expect(futureAll, new isInstanceOf<Future<Iterable<LoaderResult<int>>>>());

    final values = (await futureAll).map((e) => e.value);

    expect(values, contains(1));
    expect(values, contains(2));

    final futureEmpty = identityLoader.loadMany([]);
    expect(futureEmpty, new isInstanceOf<Future<Iterable<LoaderResult<int>>>>());

    final empty = await futureEmpty;
    expect(empty, isEmpty);
  });

  test('batches multiple requests', () async {
    final il = idLoader();
    final DataLoader<int,int> identityLoader = il[0];
    final List<int> loadCalls = il[1];

    final future1 = identityLoader.load(1);
    final future2 = identityLoader.load(2);

    final values = (await Future.wait([ future1, future2 ])).map((LoaderResult<int> e) => e.value).toList();
    expect(values[0], equals(1));
    expect(values[1], equals(2));

    expect(loadCalls[0], orderedEquals([ 1, 2 ]));
  });

  test('coalesces identical requests', () async {
    final il = idLoader();
    final DataLoader<int,int> identityLoader = il[0];
    final List<int> loadCalls = il[1];

    final future1a = identityLoader.load(1);
    final future1b = identityLoader.load(1);

    final values = (await Future.wait([future1a, future1b])).map((LoaderResult<int> e) => e.value).toList();
    expect(values[0], 1);
    expect(values[1], 1);

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals([1]));
  });

  test('caches repeated requests', () async {
    final il = idLoader();
    final DataLoader<String,String> identityLoader = il[0];
    final List<String> loadCalls = il[1];

    final values = (await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('B'),
    ])).map((LoaderResult<String> e) => e.value).toList();

    expect(values[0], equals('A'));
    expect(values[1], equals('B'));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals(['A', 'B']));

    final values2 = (await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('C'),
    ])).map((LoaderResult<String> e) => e.value).toList();

    expect(values2[0], equals('A'));
    expect(values2[1], equals('C'));

    expect(loadCalls, hasLength(2));
    expect(loadCalls[0], orderedEquals(['A', 'B']));
    expect(loadCalls[1], orderedEquals(['C']));

    final values3 = (await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('B'),
      identityLoader.load('C'),
    ])).map((LoaderResult<String> e) => e.value).toList();

    expect(values3[0], equals('A'));
    expect(values3[1], equals('B'));
    expect(values3[2], equals('C'));

    expect(loadCalls, hasLength(2));
    expect(loadCalls[0], orderedEquals(['A', 'B']));
    expect(loadCalls[1], orderedEquals(['C']));
  });

  test('clears a single value in loader', () async {
    final il = idLoader();
    final DataLoader<String,String> identityLoader = il[0];
    final List<String> loadCalls = il[1];

    final values = (await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('B'),
    ])).map((LoaderResult<String> e) => e.value).toList();

    expect(values[0], equals('A'));
    expect(values[1], equals('B'));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals(['A', 'B']));

    identityLoader.clear('A');

    final values2 = (await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('B'),
    ])).map((LoaderResult<String> e) => e.value).toList();

    expect(values2[0], equals('A'));
    expect(values2[1], equals('B'));

    expect(loadCalls, hasLength(2));
    expect(loadCalls[0], orderedEquals(['A', 'B']));
    expect(loadCalls[1], orderedEquals(['A']));
  });

  test('clears all values in loader', () async {
    final il = idLoader();
    final DataLoader<String,String> identityLoader = il[0];
    final List<String> loadCalls = il[1];

    final values = (await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('B'),
    ])).map((LoaderResult<String> e) => e.value).toList();

    expect(values[0], equals('A'));
    expect(values[1], equals('B'));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals(['A', 'B']));

    identityLoader.clearAll();

    final values2 = (await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('B'),
    ])).map((LoaderResult<String> e) => e.value).toList();

    expect(values2[0], equals('A'));
    expect(values2[1], equals('B'));

    expect(loadCalls, hasLength(2));
    expect(loadCalls[0], orderedEquals(['A', 'B']));
    expect(loadCalls[1], orderedEquals(['A', 'B']));
  });

  test('allows priming the cache', () async {
    final il = idLoader();
    final DataLoader<String,String> identityLoader = il[0];
    final List<String> loadCalls = il[1];

    identityLoader.prime('A', new LoaderResult(value: 'A'));

    final values = (await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('B'),
    ])).map((LoaderResult<String> e) => e.value).toList();

    expect(values[0], equals('A'));
    expect(values[1], equals('B'));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals(['B']));
  });

  test('does not prime keys that already exist', () async {
    final il = idLoader();
    final DataLoader<String,String> identityLoader = il[0];
    final List<String> loadCalls = il[1];

    identityLoader.prime('A', new LoaderResult(value: 'X'));

    final a1 = (await identityLoader.load('A')).value;
    final b1 = (await identityLoader.load('B')).value;

    expect(a1, equals('X'));
    expect(b1, equals('B'));

    identityLoader.prime('A', new LoaderResult(value: 'Y'));
    identityLoader.prime('B', new LoaderResult(value: 'Y'));

    final a2 = (await identityLoader.load('A')).value;
    final b2 = (await identityLoader.load('B')).value;

    expect(a2, equals('X'));
    expect(b2, equals('B'));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals(['B']));
  });

  test('allows forcefully priming the cache', () async {
    final il = idLoader();
    final DataLoader<String,String> identityLoader = il[0];
    final List<String> loadCalls = il[1];

    identityLoader.prime('A', new LoaderResult(value: 'X'));

    final a1 = (await identityLoader.load('A')).value;
    final b1 = (await identityLoader.load('B')).value;

    expect(a1, equals('X'));
    expect(b1, equals('B'));

    identityLoader.clear('A').prime('A', new LoaderResult(value: 'Y'));
    identityLoader.clear('B').prime('B', new LoaderResult(value: 'Y'));

    final a2 = (await identityLoader.load('A')).value;
    final b2 = (await identityLoader.load('B')).value;

    expect(a2, equals('Y'));
    expect(b2, equals('Y'));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals(['B']));
  });

  test('Resolves to error to indicate failure', () async {
    final loadCalls = [];
    final DataLoader<int, int> evenLoader = new DataLoader((keys) async {
      loadCalls.add(keys);
      return keys.map((key) =>
        (key % 2 == 0) ?
          new LoaderResult(value: key) :
          new LoaderResult(error: new ArgumentError('Odd: $key')));
    });

    Error caughtError;
    try {
      await evenLoader.load(1);
    } on LoaderResult catch(result) {
      caughtError = result.error;
    }

    expect(caughtError, isArgumentError);
    expect(caughtError.toString(), endsWith('Odd: 1'));

    final value2 = (await evenLoader.load(2)).value;
    expect(value2, equals(2));

    expect(loadCalls, hasLength(2));
    expect(loadCalls[0], orderedEquals([1]));
    expect(loadCalls[1], orderedEquals([2]));
  });

  test('Can represent failures and successes simultaneously', () async {
    final loadCalls = [];
    final DataLoader<int, int> evenLoader = new DataLoader<int, int>((keys) async {
      loadCalls.add(keys);
      return keys.map((key) =>
        (key % 2 == 0) ?
          new LoaderResult(value: key) :
          new LoaderResult(error: new ArgumentError('Odd: $key')));
    });

    final future1 = evenLoader.load(1);
    final future2 = evenLoader.load(2);

    ArgumentError caughtError;
    try {
      await future1;
    } on LoaderResult catch(result) {
      caughtError = result.error;
    }

    expect(caughtError, isArgumentError);
    expect(caughtError.message, equals('Odd: 1'));

    expect((await future2).value, equals(2));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals([ 1, 2 ]));
  });

  test('Caches failed fetches', () async {
    final loadCalls = [];
    final errorLoader = new DataLoader((keys) async {
      loadCalls.add(keys);
      return keys.map((key) => new LoaderResult(error: new ArgumentError('Error: $key')));
    });

    ArgumentError caughtErrorA;
    try {
      await errorLoader.load(1);
    } on LoaderResult catch(result) {
      caughtErrorA = result.error;
    }
    expect(caughtErrorA, isArgumentError);
    expect(caughtErrorA.message, equals('Error: 1'));

    ArgumentError caughtErrorB;
    try {
      await errorLoader.load(1);
    } on LoaderResult catch(result) {
      caughtErrorB = result.error;
    }

    expect(caughtErrorB, isArgumentError);
    expect(caughtErrorB.message, equals('Error: 1'));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals([1]));
  });

  test('Handles priming the cache with an error', () async {
    final il = idLoader();
    final DataLoader<int,int> identityLoader = il[0];
    final List<int> loadCalls = il[1];

    identityLoader.prime(1, new LoaderResult(error: new ArgumentError('Error: 1')));

    ArgumentError caughtErrorA;
    try {
      await identityLoader.load(1);
    } on LoaderResult catch(result) {
      caughtErrorA = result.error;
    }

    expect(caughtErrorA, isArgumentError);
    expect(caughtErrorA.message, equals('Error: 1'));

    expect(loadCalls, hasLength(0));
  });

  test('Can clear values from cache after errors', () async {
    final loadCalls = [];
    final errorLoader = new DataLoader((keys) async {
      loadCalls.add(keys);
      return keys.map((key) =>
        new LoaderResult(error: new ArgumentError('Error: $key'))
      );
    });

    ArgumentError caughtErrorA;
    try {
      await errorLoader.load(1).catchError((error) {
        errorLoader.clear(1);
        throw error;
      });
    } on LoaderResult catch (result) {
      caughtErrorA = result.error;
    }
    expect(caughtErrorA, isArgumentError);
    expect(caughtErrorA.message, 'Error: 1');

    ArgumentError caughtErrorB;
    try {
      await errorLoader.load(1).catchError((error) {
        errorLoader.clear(1);
        throw error;
      });
    } on LoaderResult catch(result) {
      caughtErrorB = result.error;
    }
    expect(caughtErrorB, isArgumentError);
    expect(caughtErrorB.message, 'Error: 1');

    expect(loadCalls, hasLength(2));
    expect(loadCalls[0], orderedEquals([1]));
    expect(loadCalls[1], orderedEquals([1]));
  });

  test('Propagates error to all loads', () async {
    final loadCalls = [];
    final failLoader = new DataLoader((keys) async {
      loadCalls.add(keys);
      throw new ArgumentError('I am a terrible loader');
    });

    final future1 = failLoader.load(1);
    final future2 = failLoader.load(2);

    ArgumentError caughtError1;
    try {
      await future1;
    } on LoaderResult catch(result) {
      caughtError1 = result.error;
    }
    expect(caughtError1, isArgumentError);
    expect(caughtError1.message, equals('I am a terrible loader'));

    ArgumentError caughtError2;
    try {
      await future2;
    } on LoaderResult catch(result) {
      caughtError2 = result.error;
    }
    expect(caughtError2, same(caughtError1));
    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals([1,2]));
  });

  test('Accepts any kind of key', () async {
    final il = idLoader();
    final DataLoader<Object,Object> identityLoader = il[0];
    final List<List<Object>> loadCalls = il[1];

    final keyA = {};
    final keyB = {};

    final List<LoaderResult> values = await Future.wait([
      identityLoader.load(keyA),
      identityLoader.load(keyB),
    ]);

    expect(values[0].value, equals(keyA));
    expect(values[1].value, equals(keyB));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], hasLength(2));
    expect(loadCalls[0], orderedEquals([keyA, keyB]));

    identityLoader.clear(keyA);

    final List<LoaderResult> values2 = await Future.wait([
      identityLoader.load(keyA),
      identityLoader.load(keyB),
    ]);

    expect(values2, hasLength(2));
    expect(values2[0].value, equals(keyA));
    expect(values2[1].value, equals(keyB));

    expect(loadCalls, hasLength(2));
    expect(loadCalls[1], hasLength(1));
    expect(loadCalls[1], orderedEquals([keyA]));
  });

  test('May disable batching', () async {
    final il = idLoader(batch: false);
    final DataLoader<int,int> identityLoader = il[0];
    final List<List<int>> loadCalls = il[1];

    final future1 = identityLoader.load(1);
    final future2 = identityLoader.load(2);

    final values = await Future.wait([future1, future2]);
    expect(values[0].value, equals(1));
    expect(values[1].value, equals(2));

    expect(loadCalls, hasLength(2));
    expect(loadCalls[0], orderedEquals([1]));
    expect(loadCalls[1], orderedEquals([2]));
  });

  test('May disable caching', () async {
    final il = idLoader(cache: false);
    final DataLoader<String,String> identityLoader = il[0];
    final List<List<String>> loadCalls = il[1];

    final values = await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('B'),
    ]);

    expect(values[0].value, equals('A'));
    expect(values[1].value, equals('B'));

    expect(loadCalls, hasLength(1));
    expect(loadCalls[0], orderedEquals(['A','B']));

    final values2 = await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('C'),
    ]);

    expect(values2[0].value, equals('A'));
    expect(values2[1].value, equals('C'));

    expect(loadCalls, hasLength(2));
    expect(loadCalls[0], orderedEquals(['A','B']));
    expect(loadCalls[1], orderedEquals(['A','C']));

    final values3 = await Future.wait([
      identityLoader.load('A'),
      identityLoader.load('B'),
      identityLoader.load('C'),
    ]);

    expect(values3[0].value, equals('A'));
    expect(values3[1].value, equals('B'));
    expect(values3[2].value, equals('C'));

    expect(loadCalls, hasLength(3));
    expect(loadCalls[0], orderedEquals(['A','B']));
    expect(loadCalls[1], orderedEquals(['A','C']));
    expect(loadCalls[2], orderedEquals(['A','B','C']));
  });

  group('Accpets object key in custom cacheKey function', () {
    CacheKeyFn cacheKeyFn = (Map key) {
      final keys = key.keys.toList();
      keys.sort();
      return keys.map((k) => k + ':' + key[k]).join();
    };

    test('Accpets objects with a complex key', () async {
      final identityLoadCalls = [];
      final identityLoader = new DataLoader((keys) async {
        identityLoadCalls.add(keys);
        return keys.map((key) => new LoaderResult(value: key));
      }, cacheKeyFn:  cacheKeyFn);

      final key1 = {'id': '123'};
      final key2 = {'id': '123'};

      final value1 = (await identityLoader.load(key1)).value;
      final value2 = (await identityLoader.load(key2)).value;

      expect(identityLoadCalls, hasLength(1));
      expect(identityLoadCalls[0], orderedEquals([key1]));
      expect(value1, equals(key1));
      expect(value2, equals(key2));
    });

    test('Clears objects with complex key', () async {
      final identityLoadCalls = [];
      final identityLoader = new DataLoader((keys) async {
        identityLoadCalls.add(keys);
        return keys.map((key) => new LoaderResult(value: key));
      }, cacheKeyFn:  cacheKeyFn);

      final key1 = {'id': '123'};
      final key2 = {'id': '123'};

      final value1 = (await identityLoader.load(key1)).value;
      identityLoader.clear(key2);
      final value2 = (await identityLoader.load(key1)).value;

      expect(identityLoadCalls, hasLength(2));
      expect(identityLoadCalls[0], orderedEquals([key1]));
      expect(identityLoadCalls[1], orderedEquals([key1]));
      expect(value1, equals(key1));
      expect(value2, equals(key1));
    });

    test('Accepts objects with different order of keys', () async {
      final identityLoadCalls = [];
      final identityLoader = new DataLoader((keys) async {
        identityLoadCalls.add(keys);
        return keys.map((key) => new LoaderResult(value: key));
      }, cacheKeyFn:  cacheKeyFn);

      final keyA = {'a': '123', 'b': '321'};
      final keyB = {'b': '321', 'a': '123'};

      final values = await Future.wait([
        identityLoader.load(keyA),
        identityLoader.load(keyB),
      ]);

      expect(values[0].value, equals(keyA));
      expect(values[1].value, equals(values[0].value));

      expect(identityLoadCalls, hasLength(1));
      expect(identityLoadCalls[0], hasLength(1));
      expect(identityLoadCalls[0], orderedEquals([keyA]));
    });

    test('Allows priming the cache with an object key', () async {
      final il = idLoader(cacheKeyFn: cacheKeyFn);
      final DataLoader<Map,Map> identityLoader = il[0];
      final List<List<Map>> loadCalls = il[1];

      final key1 = {'id': '123'};
      final key2 = {'id': '123'};

      identityLoader.prime(key1, new LoaderResult(value: key1));

      final value1 = (await identityLoader.load(key1)).value;
      final value2 = (await identityLoader.load(key2)).value;

      expect(loadCalls, isEmpty);
      expect(value1, equals(key1));
      expect(value2, equals(key1));
    });

  });

  group('Accepts custom cacheMap instance', () {
    test('Accepts a custom cache map implementation', () async {
      final aCustomMap = new Map<String, Future<LoaderResult<String>>>();
      final identityLoadCalls = [];
      final identityLoader = new DataLoader((keys) async {
        identityLoadCalls.add(keys);
        return keys.map((key) => new LoaderResult(value: key));
      }, cacheMap: aCustomMap);

      final values = await Future.wait([
        identityLoader.load('a'),
        identityLoader.load('b'),
      ]);

      expect(values[0].value, equals('a'));
      expect(values[1].value, equals('b'));

      expect(identityLoadCalls, hasLength(1));
      expect(identityLoadCalls[0], orderedEquals(['a','b']));
      expect(aCustomMap.keys, orderedEquals(['a','b']));

      final values2 = await Future.wait([
        identityLoader.load('c'),
        identityLoader.load('b'),
      ]);

      expect(values2[0].value, equals('c'));
      expect(values2[1].value, equals('b'));

      expect(identityLoadCalls, hasLength(2));
      expect(identityLoadCalls[0], orderedEquals(['a','b']));
      expect(identityLoadCalls[1], orderedEquals(['c']));
      expect(aCustomMap.keys, orderedEquals(['a','b','c']));

      identityLoader.clear('b');
      final valueB3 = await identityLoader.load('b');

      expect(valueB3.value, equals('b'));
      expect(identityLoadCalls, hasLength(3));
      expect(identityLoadCalls[0], orderedEquals(['a','b']));
      expect(identityLoadCalls[1], orderedEquals(['c']));
      expect(identityLoadCalls[2], orderedEquals(['b']));
      expect(aCustomMap.keys, orderedEquals(['a','c','b']));

      identityLoader.clearAll();

      expect(aCustomMap.keys, hasLength(0));

    });
  });

  group('It is resilient to job queue ordering', () {
    test('batches loads occuring within futures', () async {
      final il = idLoader();
      final DataLoader<String,String> identityLoader = il[0];
      final List<List<String>> loadCalls = il[1];

      new Future.microtask(() {
        identityLoader.load('B');
      });
      new Future.microtask(() {
        identityLoader.load('C');
      });
      new Future.microtask(() {
        identityLoader.load('D');
      });

      await Future.wait([
        identityLoader.load('A'),
      ]);

      expect(loadCalls, hasLength(1));
      expect(loadCalls[0], orderedEquals(['A','B','C','D']));
    });

    test('can call a loader from a loader', () async {
      final deepLoadCalls = [];
      final deepLoader = new DataLoader<Iterable<String>, Iterable<String>>((keys) async {
        deepLoadCalls.add(keys);
        return keys.map((key) => new LoaderResult(value: key));
      });

      final aLoadCalls = [];
      final aLoader = new DataLoader<String, String>((keys) async {
        aLoadCalls.add(keys);
        return (await deepLoader.load(keys)).value.map((key) => new LoaderResult(value: key));
      });

      final bLoadCalls = [];
      final bLoader = new DataLoader<String, String>((keys) async {
        bLoadCalls.add(keys);
        return (await deepLoader.load(keys)).value.map((key) => new LoaderResult(value: key));
      });

      final values = await Future.wait([
        aLoader.load('A1'),
        bLoader.load('B1'),
        aLoader.load('A2'),
        bLoader.load('B2'),
      ]);

      expect(values[0].value, equals('A1'));
      expect(values[1].value, equals('B1'));
      expect(values[2].value, equals('A2'));
      expect(values[3].value, equals('B2'));

      expect(aLoadCalls, hasLength(1));
      expect(aLoadCalls[0], orderedEquals(['A1','A2']));

      expect(bLoadCalls, hasLength(1));
      expect(bLoadCalls[0], orderedEquals(['B1','B2']));

      expect(deepLoadCalls, hasLength(1));
      expect(deepLoadCalls[0], hasLength(2));
      expect(deepLoadCalls[0].elementAt(0), hasLength(2));
      expect(deepLoadCalls[0].elementAt(0), orderedEquals(['A1', 'A2']));
      expect(deepLoadCalls[0].elementAt(1), hasLength(2));
      expect(deepLoadCalls[0].elementAt(1), orderedEquals(['B1','B2']));
    });
  });
}
