import 'package:http/http.dart' as http;

import 'env.dart';
import 'http_transport.dart';
import 'resources/resources.dart';

/// Client for the Manatal Open API v3.
///
/// ```dart
/// final client = ManatalClient(apiKey: 'YOUR_OPEN_API_TOKEN');
/// await for (final candidate in client.candidates.list()) {
///   print(candidate.id);
/// }
/// ```
class ManatalClient {
  /// Creates a client with [apiKey], or reads `MANATAL_API_KEY` when omitted.
  ManatalClient({
    String? apiKey,
    int maxRetries = 3,
    http.Client? httpClient,
  }) {
    final key = apiKey ?? readManatalApiKeyFromEnvironment();
    if (key == null || key.isEmpty) {
      throw ArgumentError(
        'apiKey is required (pass apiKey: ... or set MANATAL_API_KEY)',
      );
    }

    _transport = HttpTransport(
      apiKey: key,
      client: httpClient,
      maxRetries: maxRetries,
    );

    candidates = CandidatesResource(this);
    jobs = JobsResource(this);
    organizations = OrganizationsResource(this);
    matches = MatchesResource(this);
    contacts = ContactsResource(this);
    users = UsersResource(this);
    currencies = CurrenciesResource(this);
    languages = LanguagesResource(this);
    nationalities = NationalitiesResource(this);
    industries = IndustriesResource(this);
    jobPipelines = JobPipelinesResource(this);
    matchStages = MatchStagesResource(this);
    skills = SkillsResource(this);
  }

  late final HttpTransport _transport;

  /// Candidate CRUD and nested candidate resources.
  late final CandidatesResource candidates;

  /// Job CRUD and nested job resources.
  late final JobsResource jobs;

  /// Organization CRUD.
  late final OrganizationsResource organizations;

  /// Match CRUD between candidates and jobs.
  late final MatchesResource matches;

  /// Contact CRUD.
  late final ContactsResource contacts;

  /// Read-only user listing.
  late final UsersResource users;

  /// Read-only currency lookup.
  late final CurrenciesResource currencies;

  /// Read-only language lookup.
  late final LanguagesResource languages;

  /// Read-only nationality lookup.
  late final NationalitiesResource nationalities;

  /// Read-only industry lookup.
  late final IndustriesResource industries;

  /// Read-only job pipeline lookup.
  late final JobPipelinesResource jobPipelines;

  /// Read-only match stage lookup.
  late final MatchStagesResource matchStages;

  /// Skill CRUD and lookup.
  late final SkillsResource skills;

  /// Send a raw request against the Open API.
  Future<Object?> request(
    String method,
    String path, {
    Map<String, String>? params,
    Object? body,
    Map<String, String>? headers,
  }) {
    return _transport.request(
      method,
      path,
      params: params,
      body: body,
      headers: headers,
    );
  }

  /// Releases the underlying HTTP client.
  void close() => _transport.close();
}
