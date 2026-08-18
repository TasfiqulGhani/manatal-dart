import 'package:flutter/widgets.dart';
import 'package:manatal/manatal.dart';

class ManatalScope extends InheritedWidget {
  const ManatalScope({
    super.key,
    required this.client,
    required super.child,
  });

  final ManatalClient client;

  static ManatalClient of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ManatalScope>();
    assert(scope != null, 'ManatalScope not found');
    return scope!.client;
  }

  @override
  bool updateShouldNotify(ManatalScope oldWidget) =>
      oldWidget.client != client;
}
