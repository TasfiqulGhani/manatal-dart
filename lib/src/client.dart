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

  late final CandidatesResource candidates;
  late final JobsResource jobs;
  late final OrganizationsResource organizations;
  late final MatchesResource matches;
  late final ContactsResource contacts;
  late final UsersResource users;
  late final CurrenciesResource currencies;
  late final LanguagesResource languages;
  late final NationalitiesResource nationalities;
  late final IndustriesResource industries;
  late final JobPipelinesResource jobPipelines;
  late final MatchStagesResource matchStages;
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

  void close() => _transport.close();
}
