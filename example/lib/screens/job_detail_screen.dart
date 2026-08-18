import 'package:flutter/material.dart';
import 'package:manatal/manatal.dart';

import '../services/manatal_scope.dart';
import '../widgets/manatal_widgets.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  dynamic _job;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ManatalScope.of(context).jobs.retrieve(
            int.tryParse(widget.jobId) ?? widget.jobId,
          );
      if (!mounted) return;
      setState(() {
        _job = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      final message = _error is ManatalException
          ? (_error as ManatalException).message
          : _error.toString();
      return EmptyState(
        title: 'Could not load job',
        subtitle: message,
        action: FilledButton(onPressed: _load, child: const Text('Retry')),
      );
    }

    final title = readField(_job, 'position_name');
    final orgId = readField(_job, 'organization');
    final location = readField(_job, 'city');
    final headcount = readField(_job, 'headcount');
    final salary = readField(_job, 'salary_min');
    final salaryMax = readField(_job, 'salary_max');
    final currency = readField(_job, 'currency');
    final stage = readField(_job, 'job_pipeline_stage_name');
    final status = readField(_job, 'status');
    final id = readField(_job, 'id');

    final salaryText = salary.isEmpty && salaryMax.isEmpty
        ? 'Negotiable'
        : [
            if (salary.isNotEmpty) salary,
            if (salaryMax.isNotEmpty) salaryMax,
            if (currency.isNotEmpty) currency,
          ].join(' ');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Job' : title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (stage.isNotEmpty)
                      ManatalBadge(stage, tone: ManatalBadgeTone.blue)
                    else if (status.isNotEmpty)
                      ManatalBadge(status, tone: ManatalBadgeTone.navy),
                    ManatalBadge('Open job', tone: ManatalBadgeTone.soft),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Divider(height: 24),
                DetailField(label: 'ID', value: id),
                DetailField(label: 'Organization ID', value: orgId),
                DetailField(label: 'Location', value: location),
                DetailField(label: 'Headcount', value: headcount),
                DetailField(label: 'Salary', value: salaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _headcount = TextEditingController(text: '1');
  final _city = TextEditingController();
  bool _submitting = false;
  bool _loadingOrgs = true;
  List<dynamic> _organizations = const [];
  String? _selectedOrgId;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  @override
  void dispose() {
    _title.dispose();
    _headcount.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizations() async {
    try {
      final page = await ManatalScope.of(context).organizations.listPage(
            page: 1,
            pageSize: 50,
          );
      if (!mounted) return;
      setState(() {
        _organizations = page.results;
        _loadingOrgs = false;
        if (_organizations.isNotEmpty) {
          _selectedOrgId = readField(_organizations.first, 'id');
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingOrgs = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOrgId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an organization')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ManatalScope.of(context).jobs.create({
        'organization': int.tryParse(_selectedOrgId!) ?? _selectedOrgId,
        'position_name': _title.text.trim(),
        if (_headcount.text.trim().isNotEmpty)
          'headcount': int.tryParse(_headcount.text.trim()) ?? 1,
        if (_city.text.trim().isNotEmpty) 'city': _city.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ManatalException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create job')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: 'Position name *',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_loadingOrgs)
                      const LinearProgressIndicator()
                    else if (_organizations.isEmpty)
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Organization ID *',
                          helperText:
                              'No organizations returned — enter an ID manually',
                        ),
                        onChanged: (v) => _selectedOrgId = v.trim(),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      )
                    else
                      DropdownButtonFormField<String>(
                        key: ValueKey(_selectedOrgId),
                        initialValue: _selectedOrgId,
                        decoration: const InputDecoration(
                          labelText: 'Organization *',
                        ),
                        items: _organizations
                            .map(
                              (org) => DropdownMenuItem<String>(
                                value: readField(org, 'id'),
                                child: Text(
                                  readField(org, 'name').isEmpty
                                      ? 'Organization ${readField(org, 'id')}'
                                      : readField(org, 'name'),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedOrgId = value),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _headcount,
                      decoration: const InputDecoration(labelText: 'Headcount'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _city,
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create job'),
            ),
          ],
        ),
      ),
    );
  }
}
