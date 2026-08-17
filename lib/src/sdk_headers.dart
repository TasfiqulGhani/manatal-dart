import 'version.dart';

const sdkName = 'manatal-dart';
const sdkLanguage = 'dart';

/// Headers attached to every SDK request for server-side analytics.
Map<String, String> buildSdkHeaders(String apiKey) => {
      'Authorization': 'Token $apiKey',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'User-Agent': '$sdkName/$packageVersion',
      'X-Manatal-SDK': sdkName,
      'X-Manatal-SDK-Version': packageVersion,
      'X-Manatal-SDK-Language': sdkLanguage,
    };
