import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:manatal/manatal.dart';
import 'package:test/test.dart';

import 'package:manatal/src/http_transport.dart';
import 'package:manatal/src/sdk_headers.dart';

void main() {
  test('sends Token authorization header', () async {
    late http.Request captured;
    final mock = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'count': 0,
          'next': null,
          'previous': null,
          'results': [],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = ManatalClient(
      apiKey: 'secret-token',
      httpClient: mock,
    );

    await client.candidates.list().length;
    expect(captured.headers['Authorization'], 'Token secret-token');
    expect(captured.headers['User-Agent'], '$sdkName/$packageVersion');
    expect(captured.headers['X-Manatal-SDK'], sdkName);
    expect(captured.headers['X-Manatal-SDK-Version'], packageVersion);
    expect(captured.headers['X-Manatal-SDK-Language'], sdkLanguage);
    client.close();
  });

  test('list follows next page URL', () async {
    final mock = MockClient((request) async {
      if (request.url.queryParameters['page'] == '2') {
        return http.Response(
          jsonEncode({
            'count': 2,
            'next': null,
            'previous': '$defaultBaseUrl/candidates/?page=1',
            'results': [
              {'id': 2},
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        jsonEncode({
          'count': 2,
          'next': '$defaultBaseUrl/candidates/?page=2&page_size=100',
          'previous': null,
          'results': [
            {'id': 1},
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = ManatalClient(
      apiKey: 'k',
      httpClient: mock,
    );

    final ids = <int>[];
    await for (final row in client.candidates.list()) {
      ids.add(row.id as int);
    }
    expect(ids, [1, 2]);
    client.close();
  });

  test('create returns ManatalObject', () async {
    final mock = MockClient((request) async {
      return http.Response(
        jsonEncode({'id': 9, 'position_name': 'Engineer'}),
        201,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = ManatalClient(
      apiKey: 'k',
      httpClient: mock,
    );

    final job = await client.jobs.create({
      'organization': 1,
      'position_name': 'Engineer',
    });
    expect(job, isA<ManatalObject>());
    expect(job.id, 9);
    expect(job.position_name, 'Engineer');
    client.close();
  });

  test('maps 404 to NotFoundException', () async {
    final mock = MockClient((request) async {
      return http.Response(
        jsonEncode({'detail': 'Not found.'}),
        404,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = ManatalClient(
      apiKey: 'k',
      httpClient: mock,
    );

    expect(
      () => client.jobs.retrieve(404),
      throwsA(isA<NotFoundException>()),
    );
    client.close();
  });
}
