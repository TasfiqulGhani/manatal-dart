/// Pagination helpers for DRF page-number responses.
library;

import 'models.dart';

/// One page of results from a paginated Open API list endpoint.
class Page {
  /// Creates a page with [count], [results], and optional [next]/[previous] URLs.
  Page({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  /// Parses a DRF-style paginated JSON response.
  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      count: (json['count'] as num?)?.toInt() ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => asObject(e))
          .toList(),
    );
  }

  /// Total number of matching records across all pages.
  final int count;

  /// URL of the next page, if any.
  final String? next;

  /// URL of the previous page, if any.
  final String? previous;

  /// Records returned for this page.
  final List<dynamic> results;
}

Stream<dynamic> iterResults(
  Future<Object?> Function(String path, {Map<String, String>? params}) request,
  String path, {
  Map<String, String>? params,
  int defaultPageSize = 100,
}) async* {
  final query = Map<String, String>.from(params ?? {});
  query.putIfAbsent('page_size', () => '$defaultPageSize');

  var data = await request(path, params: query);
  var page = Page.fromJson(asObject(data).toMap());
  yield* Stream.fromIterable(page.results);

  while (page.next != null) {
    data = await request(page.next!);
    page = Page.fromJson(asObject(data).toMap());
    yield* Stream.fromIterable(page.results);
  }
}
