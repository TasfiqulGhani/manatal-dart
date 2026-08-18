import 'package:flutter_test/flutter_test.dart';
import 'package:manatal_example/main.dart';

void main() {
  testWidgets('shows setup screen when no API key', (tester) async {
    await tester.pumpWidget(const ManatalExampleApp());
    expect(find.text('Manatal Example'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
  });
}
