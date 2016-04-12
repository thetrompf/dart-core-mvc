library data_loader;
import 'dart:async';
import 'dart:collection';

typedef Future<Iterable<LoaderResult<V>>> BatchLoadFn<K, V>(Iterable<K> keys);
typedef Object CacheKeyFn(Object key);
typedef void Resolver<V>(LoaderResult<V> value);
typedef void Rejector<V>(LoaderResult<V> error);

class LoaderResult<V> {
  final Error error;
  final V value;

  bool get isError => value == null && error != null;
  bool get isValue => value != null && error == null;

  const LoaderResult({this.value: null, this.error: null});
}

class QueueItem<K, V> {
  final K key;
  final Resolver<V> resolve;
  final Rejector<V> reject;

  QueueItem({this.key, this.resolve, this.reject});
}

class LoaderQueue<K, V> extends ListBase<QueueItem<K, V>> {

  final List<QueueItem<K, V>> _list;
  LoaderQueue() : _list = <QueueItem<K, V>>[];

  @override
  int get length => _list.length;
  void set length(int len) {
    _list.length = len;
  }

  @override
  QueueItem<K, V> operator [](int index) => _list[index];

  @override
  void operator []=(int index, QueueItem<K, V> value) {
    _list[index] = value;
  }
}

class DataLoader<K, V> {

  final BatchLoadFn _batchLoadFn;
  bool cache;
  bool batch;
  final CacheKeyFn _cacheKeyFn;
  Map<K, Future<LoaderResult<V>>> _futureCache;
  LoaderQueue<K, V> _queue;

  DataLoader(batchLoadFn, {this.batch: true, this.cache: true, cacheKeyFn, Map<K, Future<LoaderResult<V>>> cacheMap}) :
      _batchLoadFn = batchLoadFn ?? null,
      _cacheKeyFn = cacheKeyFn ?? null,
      _futureCache = cacheMap ?? <K, Future<LoaderResult<V>>>{},
      _queue = new LoaderQueue<K, V>()
  {
    if(_batchLoadFn == null) {
      throw new ArgumentError(
        'DataLoader must be constructed with a function which accepts '
        'Iterable<key> and returns Future<Iterable<LoaderResult<V>>>, but got: $batchLoadFn'
      );
    }

  }

  Future<LoaderResult<V>> load(K key) {
    if(key == null) {
      throw new ArgumentError(
        'The loader.load() function must be called with a value, '
        'but got: {$key}'
      );
    }

    final shouldBatch = batch;
    final shouldCache = cache;
    final cacheKey = _cacheKeyFn == null ? key : _cacheKeyFn(key);

    if(shouldCache) {
      final cachedFuture = _futureCache.containsKey(cacheKey) ? _futureCache[cacheKey] : null;
      if(cachedFuture != null) {
        return cachedFuture;
      }
    }

    final completer = new Completer<LoaderResult<V>>();
    _queue.add(new QueueItem(key: key, resolve: completer.complete, reject: completer.completeError));

    if(_queue.length == 1) {
      if(shouldBatch) {
        scheduleMicrotask(() => dispatchQueue());
      } else {
        dispatchQueue();
      }
    }

    if(shouldCache) {
      _futureCache[cacheKey] = completer.future;
    }

    return completer.future;
  }

  Future<Iterable<LoaderResult<V>>> loadMany(Iterable<K> keys) {
    return Future.wait(keys.map((K key) => load(key)));
  }

  DataLoader<K, V> clear(K key) {
    final cacheKey = _cacheKeyFn == null ? key : _cacheKeyFn(key);
    _futureCache.remove(cacheKey);
    return this;
  }

  DataLoader<K, V> clearAll() {
    _futureCache.clear();
    return this;
  }

  DataLoader<K, V> prime(K key, LoaderResult<V> value) {
    final cacheKey = _cacheKeyFn == null ? key : _cacheKeyFn(key);
    if(!_futureCache.containsKey(cacheKey)) {
      _futureCache[cacheKey] = value.isError ? new Future.error(value) : new Future.value(value);
    }
    return this;
  }

  void dispatchQueue() {
    final queue = _queue;
    _queue = new LoaderQueue<K, V>();

    final keys = queue.map((QueueItem<K, V> item) => item.key);

    final Future<Iterable<LoaderResult<V>>> batchFuture = _batchLoadFn(keys);

    if(batchFuture is! Future) {
      failedDispatch(queue, new ArgumentError(
        'DataLoader must be constructed with a function which accepts '
        'Iterable<key> and returns Future<Iterable<LoaderResult<value>>>, but the function did '
        'not return a Future: $batchFuture'
      ));
      return;
    }

    batchFuture.then((Iterable<LoaderResult<V>> values) {
      if(values.length != keys.length) {
        throw new ArgumentError(
          'DataLoader must be constructed with a function which accepts '
          'Iterable<key> and returns Future<Iterable<LoaderResult<value>>>, but the function did '
          'not return of a List of the same length as the List of keys'
          ''
          'Keys: $keys'
          ''
          'Values: $values'
        );
      }

      final valuesList = values.toList(growable: false);
      int i = 0;
      queue.forEach((QueueItem<K, V> item) {
        final value = valuesList[i++];
        if(value.isError) {
          item.reject(value);
        } else {
          item.resolve(value);
        }
      });
    }).catchError((error) => failedDispatch(queue, error));

  }

  void failedDispatch(LoaderQueue<K, V> queue, Error error) {
    queue.forEach((QueueItem<K, V> item) {
      clear(item.key);
      item.reject(new LoaderResult<V>(error: error));
    });
  }

}

