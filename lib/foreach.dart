library lambda.foreach;

import 'package:lambda/lambda.dart';

typedef ViewNode ForFragmentFactory(item);

/// A mutable indexable list that tracks changes made to it.
class TrackList {
  final _elements = [];
  final _changes = <ListChange>[];

  TrackList();

  TrackList.from(Iterable other) {
    _elements.addAll(other);
  }

  int get length => _elements.length;
  dynamic operator[](int index) => _elements[index];
  bool get isEmpty => _elements.isEmpty;
  List toList() => []..addAll(_elements);
  bool get hasChanges => _changes.isNotEmpty;
  void add(element) {
    this.insert(_elements.length, element);
  }
  void clear() {
    // TODO: be smarter
    while(_elements.length > 0) {
      removeAt(0);
    }
  }

  dynamic removeAt(int index) {
    _changes.add(
        new ListChange(ListChangeType.remove, index, _elements[index]));
    return _elements.removeAt(index);
  }

  void insert(int index, dynamic element) {
    _changes.add(
        new ListChange(ListChangeType.insert, index, element));
    _elements.insert(index, element);
  }

  operator[]=(int index, dynamic element) {
    _changes.add(
        new ListChange(ListChangeType.replace, index, _elements[index]));
    _elements[index] = element;
  }
}

enum ListChangeType {
  insert, replace, remove
}

class ListChange {
  final ListChangeType type;
  final int index;
  final dynamic element;

  const ListChange(this.type, this.index, this.element);
}

/// Like [List.indexOf] but relies on [identical] rather than `operator==` to
/// find the index of [element].
int _indexOfReference(List list, dynamic element) {
  for (int i = 0; i < list.length; i++) {
    if (identical(element, list[i])) {
      return i;
    }
  }
  return -1;
}

class For extends FragmentController<TrackList, ForFragmentFactory> {

  /// Marker that indicates that an element was used to move an existing
  /// fragment.
  static const _USED_MARKER = const Object();
  TrackList _lastSeenList;

  For(ForFragmentFactory f) : super(f);

  @override
  void render(TrackList list) {
    assert(list is TrackList);
    // TODO: improve efficiency
    if (list == null || list.isEmpty) {
      super.clear();
    } else if (_lastSeenList == null || _lastSeenList.isEmpty) {
      for (int i = 0; i < list.length; i++) {
        final fragment = fragmentFactory(list[i])..build();
        super.append(fragment);
      }
    } else if (!identical(list, _lastSeenList)) {
      // TODO: this is n^2; need to improve
      final previousFragments = <ViewNode>[]..addAll(super.fragments);
      final previousElements = this._lastSeenList.toList();
      super.clear();
      for (int i = 0; i < list.length; i++) {
        final elem = list[i];
        final existingIndex = _indexOfReference(previousElements, elem);
        if (existingIndex == -1) {
          final fragment = fragmentFactory(elem)..build();
          super.append(fragment);
        } else {
          previousElements[existingIndex] = _USED_MARKER;
          super.append(previousFragments[existingIndex]);
        }
      }
      _lastSeenList = list;
    } else if (_lastSeenList.hasChanges) {
      for (int i = 0; i < _lastSeenList._changes.length; i++) {
        // TODO: collapse removes and readds into moves
        final change = _lastSeenList._changes[i];
        if (change.type == ListChangeType.insert) {
          final fragment = fragmentFactory(change.element)..build();
          super.insert(change.index, fragment);
        } else if (change.type == ListChangeType.remove) {
          super.remove(change.index);
        } else if (change.type == ListChangeType.replace) {
          final fragment = fragmentFactory(change.element)..build();
          super.replace(change.index, fragment);
        } else {
          assert(() {
            throw 'Unsupported change type: ${change.type}';
          }());
        }
      }
    }
    _lastSeenList = list;
  }
}
