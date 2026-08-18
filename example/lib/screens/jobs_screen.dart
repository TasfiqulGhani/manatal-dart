import 'package:flutter/material.dart';
import 'package:manatal/flutter.dart';

import '../services/manatal_scope.dart';
import '../theme/manatal_theme.dart';
import '../widgets/manatal_widgets.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

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
                  'All jobs',
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
                      builder: (_) => const CreateJobScreen(),
                    ),
                  );
                  if (created == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job created')),
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
            child: ManatalJobList(
              client: client,
              pageSize: 15,
              padding: EdgeInsets.zero,
              itemBuilder: (context, job) {
                final title = readField(job, 'position_name');
                var org = readField(job, 'organization_name');
                if (org.isEmpty) {
                  final orgObj = job['organization'];
                  if (orgObj is Map) {
                    final nested = orgObj['name'];
                    if (nested != null) org = nested.toString();
                  }
                }
                var stage = readField(job, 'job_pipeline_stage_name');
                if (stage.isEmpty) stage = readField(job, 'status');
                final id = readField(job, 'id');

                return Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => JobDetailScreen(jobId: id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ManatalAvatar(
                            label: org.isEmpty ? title : org,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.isEmpty ? 'Untitled job' : title,
                                  style: const TextStyle(
                                    color: ManatalColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (org.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      org,
                                      style: const TextStyle(
                                        color: ManatalColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                if (stage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: ManatalBadge(
                                      stage,
                                      tone: ManatalBadgeTone.blue,
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
