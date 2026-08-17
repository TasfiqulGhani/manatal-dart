import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:manatal/flutter.dart';
import 'package:manatal/src/http_transport.dart';

void main() {
  testWidgets('ManatalCandidateList loads pages and paginates', (tester) async {
    final mock = MockClient((request) async {
      final page = request.url.queryParameters['page'] ?? '1';
      if (page == '2') {
        return http.Response(
          jsonEncode({
            'count': 2,
            'next': null,
            'previous': '$defaultBaseUrl/candidates/?page=1&page_size=1',
            'results': [
              {'id': 2, 'full_name': 'Bob', 'email': 'bob@example.com'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response(
        jsonEncode({
          'count': 2,
          'next': '$defaultBaseUrl/candidates/?page=2&page_size=1',
          'previous': null,
          'results': [
            {'id': 1, 'full_name': 'Alice', 'email': 'alice@example.com'},
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = ManatalClient(apiKey: 'token', httpClient: mock);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ManatalCandidateList(
            client: client,
            pageSize: 1,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Page 1 of 2 · 2 total'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Page 2 of 2 · 2 total'), findsOneWidget);

    client.close();
  });

  testWidgets('ManatalJobList supports custom itemBuilder', (tester) async {
    final mock = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'count': 1,
          'next': null,
          'previous': null,
          'results': [
            {'id': 7, 'position_name': 'Engineer'},
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = ManatalClient(apiKey: 'token', httpClient: mock);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ManatalJobList(
            client: client,
            itemBuilder: (context, job) => ListTile(
              title: Text('Custom ${job.position_name}'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Custom Engineer'), findsOneWidget);

    client.close();
  });
}
