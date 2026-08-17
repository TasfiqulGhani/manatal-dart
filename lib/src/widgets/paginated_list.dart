import 'package:flutter/material.dart' hide Page;

import '../client.dart';
import '../exceptions.dart';
import '../pagination.dart';

/// Loads one page of results for [ManatalPaginatedList].
typedef ManatalPageLoader = Future<Page> Function(
  ManatalClient client,
  int page,
  int pageSize,
);

/// Builds a list row for one API object.
typedef ManatalItemBuilder = Widget Function(
  BuildContext context,
  dynamic item,
);

/// How [ManatalPaginatedList] loads additional pages.
enum ManatalPaginationMode {
  /// Previous / next page controls.
  pages,

  /// Loads the next page when the user scrolls near the bottom.
  infinite,
}

/// Paginated list widget backed by the Manatal Open API.
class ManatalPaginatedList extends StatefulWidget {
  const ManatalPaginatedList({
    super.key,
    required this.client,
    required this.loadPage,
    required this.itemBuilder,
    this.pageSize = 20,
    this.filters,
    this.mode = ManatalPaginationMode.pages,
    this.padding,
    this.separatorBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.paginationBuilder,
    this.shrinkWrap = false,
    this.physics,
  });

  final ManatalClient client;
  final ManatalPageLoader loadPage;
  final ManatalItemBuilder itemBuilder;
  final int pageSize;
  final Map<String, String>? filters;
  final ManatalPaginationMode mode;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
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
  State<ManatalPaginatedList> createState() => _ManatalPaginatedListState();
}

class _ManatalPaginatedListState extends State<ManatalPaginatedList> {
  final _scrollController = ScrollController();

  int _page = 1;
  int _count = 0;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;
  List<dynamic> _items = const [];
  String? _nextUrl;

  @override
  void initState() {
    super.initState();
    if (widget.mode == ManatalPaginationMode.infinite) {
      _scrollController.addListener(_onScroll);
    }
    _loadInitial();
  }

  @override
  void didUpdateWidget(covariant ManatalPaginatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.client != widget.client ||
        oldWidget.pageSize != widget.pageSize ||
        oldWidget.filters != widget.filters ||
        oldWidget.loadPage != widget.loadPage ||
        oldWidget.mode != widget.mode) {
      _resetAndReload();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _totalPages {
    if (_count == 0 || widget.pageSize <= 0) return 1;
    return (_count / widget.pageSize).ceil().clamp(1, 1 << 30);
  }

  Future<void> _resetAndReload() async {
    setState(() {
      _page = 1;
      _items = const [];
      _nextUrl = null;
      _error = null;
      _loading = true;
      _loadingMore = false;
    });
    await _loadPage(page: 1, append: false);
  }

  Future<void> _loadInitial() => _loadPage(page: 1, append: false);

  Future<void> _loadPage({required int page, required bool append}) async {
    if (append) {
      if (_loadingMore || _nextUrl == null) return;
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final result = await widget.loadPage(
        widget.client,
        page,
        widget.pageSize,
      );

      if (!mounted) return;
      setState(() {
        _page = page;
        _count = result.count;
        _nextUrl = result.next;
        _items = append ? [..._items, ...result.results] : result.results;
        _error = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (widget.mode != ManatalPaginationMode.infinite) return;
    if (!_scrollController.hasClients || _loading || _loadingMore) return;
    if (_nextUrl == null) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadPage(page: _page + 1, append: true);
    }
  }

  void _goToPreviousPage() {
    if (_page <= 1) return;
    _loadPage(page: _page - 1, append: false);
  }

  void _goToNextPage() {
    if (_nextUrl == null && _page >= _totalPages) return;
    _loadPage(page: _page + 1, append: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!) ??
          _DefaultErrorView(
            error: _error!,
            onRetry: _resetAndReload,
          );
    }

    if (_items.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No results'));
    }

    final listPadding = widget.padding ?? EdgeInsets.zero;
    final itemCount = _items.length + (_loadingMore ? 1 : 0);

    final listView = ListView.separated(
      controller: widget.mode == ManatalPaginationMode.infinite
          ? _scrollController
          : null,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: listPadding,
      itemCount: itemCount,
      separatorBuilder: (context, index) {
        if (index >= _items.length - 1) {
          return const SizedBox.shrink();
        }
        return widget.separatorBuilder?.call(context, index) ??
            const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, _items[index]);
      },
    );

    if (widget.mode == ManatalPaginationMode.infinite) {
      return listView;
    }

    final pagination = widget.paginationBuilder?.call(
          context,
          _page,
          _totalPages,
          _count,
          _page > 1 ? _goToPreviousPage : null,
          _nextUrl != null ? _goToNextPage : null,
        ) ??
        _DefaultPaginationControls(
          page: _page,
          totalPages: _totalPages,
          count: _count,
          onPrevious: _page > 1 ? _goToPreviousPage : null,
          onNext: _nextUrl != null ? _goToNextPage : null,
        );

    if (widget.shrinkWrap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          listView,
          pagination,
        ],
      );
    }

    return Column(
      children: [
        Expanded(child: listView),
        pagination,
      ],
    );
  }
}

class _DefaultPaginationControls extends StatelessWidget {
  const _DefaultPaginationControls({
    required this.page,
    required this.totalPages,
    required this.count,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final int count;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 2,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  'Page $page of $totalPages · $count total',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultErrorView extends StatelessWidget {
  const _DefaultErrorView({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is ManatalException
        ? (error as ManatalException).message
        : error.toString();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
