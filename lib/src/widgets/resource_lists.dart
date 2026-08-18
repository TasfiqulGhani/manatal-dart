import 'package:flutter/material.dart';

import '../client.dart';
import '../models.dart';
import 'paginated_list.dart';

String _readField(dynamic item, String key) {
  final value = item is ManatalObject ? item[key] : item[key];
  return value?.toString() ?? '';
}

/// Paginated list of candidates from the Manatal Open API.
class ManatalCandidateList extends StatelessWidget {
  /// Creates a candidate list backed by [client].
  const ManatalCandidateList({
    super.key,
    required this.client,
    this.itemBuilder,
    this.pageSize = 20,
    this.filters,
    this.mode = ManatalPaginationMode.pages,
    this.padding,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.paginationBuilder,
    this.shrinkWrap = false,
    this.physics,
  });

  /// Manatal client used to load candidate pages.
  final ManatalClient client;
  final ManatalItemBuilder? itemBuilder;
  final int pageSize;

  /// Optional query parameters sent to the candidates list endpoint.
  final Map<String, String>? filters;
  final ManatalPaginationMode mode;
  final EdgeInsetsGeometry? padding;

  /// Widget shown when the list has no results.
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Widget shown when loading a page fails.
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(
    BuildContext context,
    int page,
    int totalPages,
    int count,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
  )? paginationBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ManatalPaginatedList(
      client: client,
      pageSize: pageSize,
      filters: filters,
      mode: mode,
      padding: padding,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      paginationBuilder: paginationBuilder,
      shrinkWrap: shrinkWrap,
      physics: physics,
      loadPage: (client, page, pageSize) => client.candidates.listPage(
        page: page,
        pageSize: pageSize,
        filters: filters,
      ),
      itemBuilder: itemBuilder ??
          (context, candidate) {
            final name = _readField(candidate, 'full_name');
            final email = _readField(candidate, 'email');
            return ListTile(
              title: Text(name.isEmpty ? 'Candidate' : name),
              subtitle: email.isEmpty ? null : Text(email),
            );
          },
    );
  }
}

/// Paginated list of jobs from the Manatal Open API.
class ManatalJobList extends StatelessWidget {
  const ManatalJobList({
    super.key,
    required this.client,
    this.itemBuilder,
    this.pageSize = 20,
    this.filters,
    this.mode = ManatalPaginationMode.pages,
    this.padding,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.paginationBuilder,
    this.shrinkWrap = false,
    this.physics,
  });

  final ManatalClient client;
  final ManatalItemBuilder? itemBuilder;
  final int pageSize;
  final Map<String, String>? filters;
  final ManatalPaginationMode mode;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(
    BuildContext context,
    int page,
    int totalPages,
    int count,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
  )? paginationBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ManatalPaginatedList(
      client: client,
      pageSize: pageSize,
      filters: filters,
      mode: mode,
      padding: padding,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      paginationBuilder: paginationBuilder,
      shrinkWrap: shrinkWrap,
      physics: physics,
      loadPage: (client, page, pageSize) => client.jobs.listPage(
        page: page,
        pageSize: pageSize,
        filters: filters,
      ),
      itemBuilder: itemBuilder ??
          (context, job) {
            final title = _readField(job, 'position_name');
            final status = _readField(job, 'status');
            return ListTile(
              title: Text(title.isEmpty ? 'Job' : title),
              subtitle: status.isEmpty ? null : Text(status),
            );
          },
    );
  }
}

/// Paginated list of organizations from the Manatal Open API.
class ManatalOrganizationList extends StatelessWidget {
  const ManatalOrganizationList({
    super.key,
    required this.client,
    this.itemBuilder,
    this.pageSize = 20,
    this.filters,
    this.mode = ManatalPaginationMode.pages,
    this.padding,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.paginationBuilder,
    this.shrinkWrap = false,
    this.physics,
  });

  final ManatalClient client;
  final ManatalItemBuilder? itemBuilder;
  final int pageSize;
  final Map<String, String>? filters;
  final ManatalPaginationMode mode;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(
    BuildContext context,
    int page,
    int totalPages,
    int count,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
  )? paginationBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ManatalPaginatedList(
      client: client,
      pageSize: pageSize,
      filters: filters,
      mode: mode,
      padding: padding,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      paginationBuilder: paginationBuilder,
      shrinkWrap: shrinkWrap,
      physics: physics,
      loadPage: (client, page, pageSize) => client.organizations.listPage(
        page: page,
        pageSize: pageSize,
        filters: filters,
      ),
      itemBuilder: itemBuilder ??
          (context, organization) {
            final name = _readField(organization, 'name');
            return ListTile(
              title: Text(name.isEmpty ? 'Organization' : name),
            );
          },
    );
  }
}

/// Paginated list of matches from the Manatal Open API.
class ManatalMatchList extends StatelessWidget {
  const ManatalMatchList({
    super.key,
    required this.client,
    this.itemBuilder,
    this.pageSize = 20,
    this.filters,
    this.mode = ManatalPaginationMode.pages,
    this.padding,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.paginationBuilder,
    this.shrinkWrap = false,
    this.physics,
  });

  final ManatalClient client;
  final ManatalItemBuilder? itemBuilder;
  final int pageSize;
  final Map<String, String>? filters;
  final ManatalPaginationMode mode;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(
    BuildContext context,
    int page,
    int totalPages,
    int count,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
  )? paginationBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ManatalPaginatedList(
      client: client,
      pageSize: pageSize,
      filters: filters,
      mode: mode,
      padding: padding,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      paginationBuilder: paginationBuilder,
      shrinkWrap: shrinkWrap,
      physics: physics,
      loadPage: (client, page, pageSize) => client.matches.listPage(
        page: page,
        pageSize: pageSize,
        filters: filters,
      ),
      itemBuilder: itemBuilder ??
          (context, match) {
            final candidate = _readField(match, 'candidate');
            final job = _readField(match, 'job');
            return ListTile(
              title: Text('Match #$candidate → #$job'),
            );
          },
    );
  }
}
