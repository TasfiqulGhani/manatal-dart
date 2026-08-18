import 'package:flutter/material.dart';
import 'package:manatal/flutter.dart';

import '../services/manatal_scope.dart';
import '../theme/manatal_theme.dart';
import '../widgets/manatal_widgets.dart';
import 'candidate_detail_screen.dart';

class CandidatesScreen extends StatelessWidget {
  const CandidatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ManatalScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'All candidates',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ManatalColors.textPrimary,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () async {
                  final created = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => const CreateCandidateScreen(),
                    ),
                  );
                  if (created == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Candidate created')),
                    );
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            clipBehavior: Clip.antiAlias,
            child: ManatalCandidateList(
              client: client,
              pageSize: 15,
              padding: EdgeInsets.zero,
              itemBuilder: (context, candidate) {
                final name = readField(candidate, 'full_name');
                final email = readField(candidate, 'email');
                final id = readField(candidate, 'id');

                return Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CandidateDetailScreen(
                            candidateId: id,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          ManatalAvatar(label: name.isEmpty ? '?' : name),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty ? 'Unnamed candidate' : name,
                                  style: const TextStyle(
                                    color: ManatalColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (email.isNotEmpty)
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      color: ManatalColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: ManatalColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
