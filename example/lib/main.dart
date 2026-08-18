import 'package:flutter/material.dart';
import 'package:manatal/manatal.dart';

import 'screens/home_shell.dart';
import 'services/manatal_scope.dart';
import 'theme/manatal_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const apiKey = String.fromEnvironment('MANATAL_API_KEY');
  runApp(ManatalExampleApp(initialApiKey: apiKey.isEmpty ? null : apiKey));
}

class ManatalExampleApp extends StatefulWidget {
  const ManatalExampleApp({super.key, this.initialApiKey});

  final String? initialApiKey;

  @override
  State<ManatalExampleApp> createState() => _ManatalExampleAppState();
}

class _ManatalExampleAppState extends State<ManatalExampleApp> {
  ManatalClient? _client;

  @override
  void initState() {
    super.initState();
    if (widget.initialApiKey != null) {
      _client = ManatalClient(apiKey: widget.initialApiKey);
    }
  }

  @override
  void dispose() {
    _client?.close();
    super.dispose();
  }

  void _onConnected(ManatalClient client) {
    setState(() => _client = client);
  }

  void _disconnect() {
    _client?.close();
    setState(() => _client = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manatal Example',
      debugShowCheckedModeBanner: false,
      theme: buildManatalTheme(),
      builder: (context, child) {
        if (_client == null || child == null) return child ?? const SizedBox.shrink();
        return ManatalScope(client: _client!, child: child);
      },
      home: _client == null
          ? SetupScreen(onConnected: _onConnected)
          : HomeShell(onDisconnect: _disconnect),
    );
  }
}
