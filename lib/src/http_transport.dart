import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'models.dart';
import 'sdk_headers.dart';
import 'throttle.dart';

const defaultBaseUrl = 'https://api.manatal.com/open/v3';
const _transientStatus = {502, 503, 504};
const _idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'DELETE'};

double? parseRetryAfter(Map<String, String> headers) {
  final value = headers['retry-after'] ?? headers['Retry-After'];
  if (value == null) return null;
  return double.tryParse(value)?.clamp(0, double.infinity);
}

Never raiseForStatus(http.Response response, {double? retryAfter}) {
  Object? body;
  try {
    body = jsonDecode(response.body);
  } catch (_) {
    body = response.body;
  }

  String message;
  if (body is Map && body['detail'] is String) {
    message = body['detail'] as String;
  } else {
    message = 'HTTP ${response.statusCode} error';
  }

  final headers = response.headers;
  final status = response.statusCode;

  switch (status) {
    case 401:
      throw AuthenticationException(
        message,
        statusCode: status,
        body: body,
        headers: headers,
      );
    case 403:
      throw ForbiddenException(
        message,
        statusCode: status,
        body: body,
        headers: headers,
      );
    case 404:
      throw NotFoundException(
        message,
        statusCode: status,
        body: body,
        headers: headers,
      );
    case 400:
      throw ValidationException(
        message,
        statusCode: status,
        body: body,
        headers: headers,
      );
    case 429:
      throw RateLimitException(
        message,
        statusCode: status,
        body: body,
        headers: headers,
        retryAfter: retryAfter ?? parseRetryAfter(headers),
      );
    default:
      throw ApiException(
        message,
        statusCode: status,
        body: body,
        headers: headers,
      );
  }
}

class HttpTransport {
  HttpTransport({
    required this.apiKey,
    http.Client? client,
    this.maxRetries = 3,
    RateLimiter? rateLimiter,
  })  : _client = client ?? http.Client(),
        rateLimiter = rateLimiter ?? RateLimiter();

  final String apiKey;
  final int maxRetries;
  final RateLimiter rateLimiter;
  final http.Client _client;

  Map<String, String> get _defaultHeaders => buildSdkHeaders(apiKey);

  void close() => _client.close();

  Future<Object?> request(
    String method,
    String urlOrPath, {
    Map<String, String>? params,
    Object? body,
    Map<String, String>? headers,
  }) async {
    final methodUpper = method.toUpperCase();
    var attempt = 0;

    while (true) {
      await rateLimiter.acquire();

      final uri = _resolveUri(urlOrPath, params);
      final mergedHeaders = {..._defaultHeaders, ...?headers};

      final response = await _send(methodUpper, uri, mergedHeaders, body);

      if (_shouldRetry(methodUpper, response.statusCode, attempt)) {
        final wait = parseRetryAfter(response.headers) ??
            (1 << attempt).toDouble().clamp(1, 30);
        attempt += 1;
        if (attempt > maxRetries) {
          raiseForStatus(response, retryAfter: wait);
        }
        await Future<void>.delayed(
            Duration(milliseconds: (wait * 1000).round()));
        continue;
      }

      if (response.statusCode == 204) return null;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        raiseForStatus(response);
      }

      if (response.body.isEmpty) return null;
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        return wrapValue(jsonDecode(response.body));
      }
      return response.body;
    }
  }

  Uri _resolveUri(String urlOrPath, Map<String, String>? params) {
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      final uri = Uri.parse(urlOrPath);
      return params == null ? uri : uri.replace(queryParameters: params);
    }
    final path = urlOrPath.startsWith('/') ? urlOrPath : '/$urlOrPath';
    return Uri.parse('$defaultBaseUrl$path').replace(queryParameters: params);
  }

  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, String> headers,
    Object? body,
  ) {
    final encoded = body == null ? null : jsonEncode(body);
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: encoded);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: encoded);
      case 'DELETE':
        return _client.delete(uri, headers: headers);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  bool _shouldRetry(String method, int status, int attempt) {
    if (attempt >= maxRetries) return false;
    if (status == 429) return true;
    if (_transientStatus.contains(status) &&
        _idempotentMethods.contains(method)) {
      return true;
    }
    return false;
  }
}
