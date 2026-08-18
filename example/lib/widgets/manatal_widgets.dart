import 'package:flutter/material.dart';

import '../theme/manatal_theme.dart';

class ManatalBadge extends StatelessWidget {
  const ManatalBadge(this.label, {super.key, this.tone = ManatalBadgeTone.blue});

  final String label;
  final ManatalBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      ManatalBadgeTone.blue => (
          bg: ManatalColors.stageBlue,
          fg: Colors.white,
        ),
      ManatalBadgeTone.navy => (
          bg: ManatalColors.stageNavy,
          fg: Colors.white,
        ),
      ManatalBadgeTone.soft => (
          bg: ManatalColors.primaryLight,
          fg: ManatalColors.primaryDark,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: colors.fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

enum ManatalBadgeTone { blue, navy, soft }

class ManatalAvatar extends StatelessWidget {
  const ManatalAvatar({
    super.key,
    required this.label,
    this.size = 36,
  });

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(label);
    final color = _colorFor(label);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts =
        value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _colorFor(String value) {
    const palette = [
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
      Color(0xFF059669),
      Color(0xFFEA580C),
      Color(0xFFDB2777),
    ];
    return palette[value.hashCode.abs() % palette.length];
  }
}

class DetailField extends StatelessWidget {
  const DetailField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ManatalColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              color: ManatalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ManatalColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ManatalColors.textSecondary),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

String readField(dynamic item, String key) {
  if (item == null) return '';
  final value = item[key];
  return value?.toString() ?? '';
}
