/// API response objects with property and map access.
library;

dynamic wrapValue(dynamic value) {
  if (value is ManatalObject) return value;
  if (value is Map) {
    return ManatalObject(Map<String, dynamic>.from(value));
  }
  if (value is List) {
    return value.map(wrapValue).toList();
  }
  return value;
}

ManatalObject asObject(dynamic value) {
  if (value is ManatalObject) return value;
  if (value is Map<String, dynamic>) return ManatalObject(value);
  if (value is Map) return ManatalObject(Map<String, dynamic>.from(value));
  throw StateError('Expected a JSON object response');
}

/// JSON object that supports both `job.id` and `job['id']`.
///
/// Resource methods return `dynamic` values that are [ManatalObject] at runtime,
/// so property access works without extra casts:
///
/// ```dart
/// final job = await client.jobs.create({...});
/// print(job.id);
/// print(job['id']);
/// ```
class ManatalObject {
  ManatalObject([Map<String, dynamic>? data])
      : _data = Map<String, dynamic>.from(
          (data ?? {}).map((key, value) => MapEntry(key, wrapValue(value))),
        );

  final Map<String, dynamic> _data;

  dynamic operator [](Object key) => _data[key.toString()];

  void operator []=(Object key, dynamic value) {
    _data[key.toString()] = wrapValue(value);
  }

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(_data);

  bool containsKey(Object key) => _data.containsKey(key.toString());

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      final key = _symbolToKey(invocation.memberName);
      if (_data.containsKey(key)) {
        return _data[key];
      }
    }
    throw NoSuchMethodError.withInvocation(this, invocation);
  }

  @override
  String toString() => 'ManatalObject($_data)';

  static String _symbolToKey(Symbol symbol) {
    final text = symbol.toString();
    const prefix = 'Symbol("';
    if (text.startsWith(prefix) && text.endsWith('")')) {
      return text.substring(prefix.length, text.length - 2);
    }
    return text;
  }
}
