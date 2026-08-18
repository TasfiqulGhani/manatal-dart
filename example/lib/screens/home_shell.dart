import 'package:flutter/material.dart';
import 'package:manatal/manatal.dart';

import '../theme/manatal_theme.dart';
import '../widgets/manatal_logo.dart';
import '../widgets/manatal_widgets.dart';
import 'candidates_screen.dart';
import 'candidate_detail_screen.dart';
import 'job_detail_screen.dart';
import 'jobs_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.onConnected});

  final ValueChanged<ManatalClient> onConnected;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final token = _controller.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Paste your Open API token to continue.');
      return;
    }

    final client = ManatalClient(apiKey: token);
    try {
      await client.users.listPage(page: 1, pageSize: 1);
      if (!mounted) return;
      widget.onConnected(client);
    } on ManatalException catch (e) {
      client.close();
      setState(() => _error = e.message);
    } catch (e) {
      client.close();
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: ManatalLogo(size: 72)),
                  const SizedBox(height: 20),
                  const Text(
                    'Manatal Example',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: ManatalColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect with your Open API token to explore candidates and jobs.',
                    style: TextStyle(color: ManatalColors.textSecondary),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _controller,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Open API token',
                      errorText: _error,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _connect,
                    child: const Text('Connect'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Get a token from Open API settings in Manatal.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ManatalColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.onDisconnect});

  final VoidCallback onDisconnect;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardScreen(),
      const CandidatesScreen(),
      const JobsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const ManatalLogo(size: 28),
            const SizedBox(width: 12),
            Text(_titles[_index]),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Disconnect',
            onPressed: widget.onDisconnect,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Candidates',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            selectedIcon: Icon(Icons.business_center),
            label: 'Jobs',
          ),
        ],
      ),
    );
  }

  static const _titles = ['Dashboard', 'Candidates', 'Jobs'];
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Recruitment Center',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ManatalColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.person_add_alt_1_outlined,
                title: 'New candidate',
                subtitle: 'Add to your pipeline',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreateCandidateScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.add_business_outlined,
                title: 'New job',
                subtitle: 'Open a position',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreateJobScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    ManatalLogo(size: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Built with manatal SDK',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'This demo uses the Manatal Open API to list, create, and view candidates and jobs with a UI inspired by the Manatal web app.',
                  style: TextStyle(color: ManatalColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    ManatalBadge('Open API v3', tone: ManatalBadgeTone.soft),
                    ManatalBadge('Flutter', tone: ManatalBadgeTone.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: ManatalColors.primary),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: ManatalColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
