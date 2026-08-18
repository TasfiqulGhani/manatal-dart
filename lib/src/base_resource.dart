import 'client.dart';
import 'defaults.dart';
import 'models.dart';
import 'pagination.dart';

typedef PathId = Object;

class Resource {
  Resource(this.client, this.path);

  final ManatalClient client;
  final String path;

  String get collection => path.endsWith('/') ? path : '$path/';

  String item(PathId id) => '$collection$id/';

  Future<Page> listPage({
    int page = 1,
    int? pageSize,
    Map<String, String>? filters,
  }) async {
    final params = <String, String>{
      'page': '$page',
      ...?filters,
    };
    params['page_size'] = '${pageSize ?? defaultPageSize}';
    final data = await client.request('GET', collection, params: params);
    return Page.fromJson(asObject(data).toMap());
  }

  Stream<dynamic> list({Map<String, String>? filters}) {
    return iterResults(
      (path, {params}) => client.request('GET', path, params: params),
      collection,
      params: filters,
      defaultPageSize: defaultPageSize,
    );
  }

  Future<dynamic> retrieve(PathId id) async {
    final data = await client.request('GET', item(id));
    return asObject(data);
  }

  Future<dynamic> create(Map<String, dynamic> data) async {
    final result = await client.request('POST', collection, body: data);
    return asObject(result);
  }

  Future<dynamic> update(PathId id, Map<String, dynamic> data) async {
    final result = await client.request('PATCH', item(id), body: data);
    return asObject(result);
  }

  Future<void> delete(PathId id) async {
    await client.request('DELETE', item(id));
  }
}

class NestedResource {
  NestedResource(
    this.client,
    String parentPath,
    PathId parentId,
    String nested,
  ) : _base =
            '${parentPath.endsWith('/') ? parentPath : '$parentPath/'}$parentId/${nested.replaceAll(RegExp(r'^/|/$'), '')}/';

  final ManatalClient client;
  final String _base;

  String _item(PathId id) => '$_base$id/';

  Future<Page> listPage({
    int page = 1,
    int? pageSize,
    Map<String, String>? filters,
  }) async {
    final params = <String, String>{
      'page': '$page',
      ...?filters,
    };
    params['page_size'] = '${pageSize ?? defaultPageSize}';
    final data = await client.request('GET', _base, params: params);
    return Page.fromJson(asObject(data).toMap());
  }

  Stream<dynamic> list({Map<String, String>? filters}) {
    return iterResults(
      (path, {params}) => client.request('GET', path, params: params),
      _base,
      params: filters,
      defaultPageSize: defaultPageSize,
    );
  }

  Future<dynamic> retrieve(PathId id) async {
    final data = await client.request('GET', _item(id));
    return asObject(data);
  }

  Future<dynamic> create(Map<String, dynamic> data) async {
    final result = await client.request('POST', _base, body: data);
    return asObject(result);
  }

  Future<dynamic> update(PathId id, Map<String, dynamic> data) async {
    final result = await client.request('PATCH', _item(id), body: data);
    return asObject(result);
  }

  Future<void> delete(PathId id) async {
    await client.request('DELETE', _item(id));
  }
}

class ReadOnlyResource extends Resource {
  ReadOnlyResource(super.client, super.path);

  @override
  Future<dynamic> create(Map<String, dynamic> data) {
    throw UnsupportedError('$path does not support create');
  }

  @override
  Future<dynamic> update(PathId id, Map<String, dynamic> data) {
    throw UnsupportedError('$path does not support update');
  }

  @override
  Future<void> delete(PathId id) {
    throw UnsupportedError('$path does not support delete');
  }
}
