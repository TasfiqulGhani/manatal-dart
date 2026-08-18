import 'package:flutter/material.dart';
import 'package:manatal/manatal.dart';

import '../services/manatal_scope.dart';
import '../widgets/manatal_widgets.dart';

class CandidateDetailScreen extends StatefulWidget {
  const CandidateDetailScreen({super.key, required this.candidateId});

  final String candidateId;

  @override
  State<CandidateDetailScreen> createState() => _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends State<CandidateDetailScreen> {
  dynamic _candidate;
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
      final data = await ManatalScope.of(context).candidates.retrieve(
            int.tryParse(widget.candidateId) ?? widget.candidateId,
          );
      if (!mounted) return;
      setState(() {
        _candidate = data;
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
        title: const Text('Candidate'),
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
        title: 'Could not load candidate',
        subtitle: message,
        action: FilledButton(onPressed: _load, child: const Text('Retry')),
      );
    }

    final name = readField(_candidate, 'full_name');
    final email = readField(_candidate, 'email');
    final phone = readField(_candidate, 'phone_number');
    final id = readField(_candidate, 'id');
    final created = readField(_candidate, 'created_at');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ManatalAvatar(label: name, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Candidate' : name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const ManatalBadge('Candidate', tone: ManatalBadgeTone.soft),
                    ],
                  ),
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
                  'Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Divider(height: 24),
                DetailField(label: 'ID', value: id),
                DetailField(label: 'Email', value: email),
                DetailField(label: 'Phone', value: phone),
                DetailField(label: 'Created', value: created),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CreateCandidateScreen extends StatefulWidget {
  const CreateCandidateScreen({super.key});

  @override
  State<CreateCandidateScreen> createState() => _CreateCandidateScreenState();
}

class _CreateCandidateScreenState extends State<CreateCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await ManatalScope.of(context).candidates.create({
        'full_name': _name.text.trim(),
        'email': _email.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phone_number': _phone.text.trim(),
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
      appBar: AppBar(title: const Text('Create candidate')),
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
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Full name *'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email *'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
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
                  : const Text('Create candidate'),
            ),
          ],
        ),
      ),
    );
  }
}
