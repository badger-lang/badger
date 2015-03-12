part of badger.common;

abstract class DelegatingIterable<E> implements Iterable<E> {
  Iterable<E> get delegate;

  bool any(bool test(E element)) => delegate.any(test);

  bool contains(Object element) => delegate.contains(element);

  E elementAt(int index) => delegate.elementAt(index);

  bool every(bool test(E element)) => delegate.every(test);

  Iterable expand(Iterable f(E element)) => delegate.expand(f);

  E get first => delegate.first;

  E firstWhere(bool test(E element), {E orElse()}) =>
  delegate.firstWhere(test, orElse: orElse);

  fold(initialValue, combine(previousValue, E element)) =>
  delegate.fold(initialValue, combine);

  void forEach(void f(E element)) => delegate.forEach(f);

  bool get isEmpty => delegate.isEmpty;

  bool get isNotEmpty => delegate.isNotEmpty;

  Iterator<E> get iterator => delegate.iterator;

  String join([String separator = ""]) => delegate.join(separator);

  E get last => delegate.last;

  E lastWhere(bool test(E element), {E orElse()}) =>
  delegate.lastWhere(test, orElse: orElse);

  int get length => delegate.length;

  Iterable map(f(E element)) => delegate.map(f);

  E reduce(E combine(E value, E element)) => delegate.reduce(combine);

  E get single => delegate.single;

  E singleWhere(bool test(E element)) => delegate.singleWhere(test);

  Iterable<E> skip(int n) => delegate.skip(n);

  Iterable<E> skipWhile(bool test(E value)) => delegate.skipWhile(test);

  Iterable<E> take(int n) => delegate.take(n);

  Iterable<E> takeWhile(bool test(E value)) => delegate.takeWhile(test);

  List<E> toList({bool growable: true}) => delegate.toList(growable: growable);

  Set<E> toSet() => delegate.toSet();

  Iterable<E> where(bool test(E element)) => delegate.where(test);
}

abstract class DelegatingMap<K, V> implements Map<K, V> {
  Map<K, V> get delegate;

  V operator [](Object key) => delegate[key];

  void operator []=(K key, V value) {
    delegate[key] = value;
  }

  void addAll(Map<K, V> other) => delegate.addAll(other);

  void clear() => delegate.clear();

  bool containsKey(Object key) => delegate.containsKey(key);

  bool containsValue(Object value) => delegate.containsValue(value);

  void forEach(void f(K key, V value)) => delegate.forEach(f);

  bool get isEmpty => delegate.isEmpty;

  bool get isNotEmpty => delegate.isNotEmpty;

  Iterable<K> get keys => delegate.keys;

  int get length => delegate.length;

  V putIfAbsent(K key, V ifAbsent()) => delegate.putIfAbsent(key, ifAbsent);

  V remove(Object key) => delegate.remove(key);

  Iterable<V> get values => delegate.values;
}

abstract class DelegatingList<E> extends DelegatingIterable<E> implements List<E> {
  List<E> get delegate;

  E operator [](int index) => delegate[index];

  void operator []=(int index, E value) {
    delegate[index] = value;
  }

  void add(E value) => delegate.add(value);

  void addAll(Iterable<E> iterable) => delegate.addAll(iterable);

  Map<int, E> asMap() => delegate.asMap();

  void clear() => delegate.clear();

  void fillRange(int start, int end, [E fillValue]) =>
  delegate.fillRange(start, end, fillValue);

  Iterable<E> getRange(int start, int end) => delegate.getRange(start, end);

  int indexOf(E element, [int start = 0]) => delegate.indexOf(element, start);

  void insert(int index, E element) => delegate.insert(index, element);

  void insertAll(int index, Iterable<E> iterable) =>
  delegate.insertAll(index, iterable);

  int lastIndexOf(E element, [int start]) =>
  delegate.lastIndexOf(element, start);

  void set length(int newLength) {
    delegate.length = newLength;
  }

  bool remove(Object value) => delegate.remove(value);

  E removeAt(int index) => delegate.removeAt(index);

  E removeLast() => delegate.removeLast();

  void removeRange(int start, int end) => delegate.removeRange(start, end);

  void removeWhere(bool test(E element)) => delegate.removeWhere(test);

  void replaceRange(int start, int end, Iterable<E> iterable) =>
  delegate.replaceRange(start, end, iterable);

  void retainWhere(bool test(E element)) => delegate.retainWhere(test);

  Iterable<E> get reversed => delegate.reversed;

  void setAll(int index, Iterable<E> iterable) =>
  delegate.setAll(index, iterable);

  void setRange(int start, int end, Iterable<E> iterable,
                [int skipCount = 0]) =>
  delegate.setRange(start, end, iterable, skipCount);

  void shuffle([Random random]) => delegate.shuffle(random);

  void sort([int compare(E a, E b)]) => delegate.sort(compare);

  List<E> sublist(int start, [int end]) => delegate.sublist(start, end);
}

abstract class DelegatingQueue<E> extends DelegatingIterable<E> implements Queue<E> {
  Queue<E> get delegate;

  void add(E value) => delegate.add(value);

  void addAll(Iterable<E> iterable) => delegate.addAll(iterable);

  void addFirst(E value) => delegate.addFirst(value);

  void addLast(E value) => delegate.addLast(value);

  void clear() => delegate.clear();

  bool remove(Object object) => delegate.remove(object);

  E removeFirst() => delegate.removeFirst();

  E removeLast() => delegate.removeLast();

  void removeWhere(bool test(E element)) => delegate.removeWhere(test);

  void retainWhere(bool test(E element)) => delegate.retainWhere(test);
}

abstract class DelegatingSet<E> extends DelegatingIterable<E> implements Set<E> {
  Set<E> get delegate;

  bool add(E value) => delegate.add(value);

  void addAll(Iterable<E> elements) => delegate.addAll(elements);

  void clear() => delegate.clear();

  bool containsAll(Iterable<Object> other) => delegate.containsAll(other);

  Set<E> difference(Set<E> other) => delegate.difference(other);

  Set<E> intersection(Set<Object> other) => delegate.intersection(other);

  E lookup(Object object) => delegate.lookup(object);

  bool remove(Object value) => delegate.remove(value);

  void removeAll(Iterable<Object> elements) => delegate.removeAll(elements);

  void removeWhere(bool test(E element)) => delegate.removeWhere(test);

  void retainAll(Iterable<Object> elements) => delegate.retainAll(elements);

  void retainWhere(bool test(E element)) => delegate.retainWhere(test);

  Set<E> union(Set<E> other) => delegate.union(other);
}
