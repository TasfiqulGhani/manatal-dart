import 'dart:io' show Platform;

String? readManatalApiKeyFromEnvironment() =>
    Platform.environment['MANATAL_API_KEY'];
