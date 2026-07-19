import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../settings/presentation/widgets/settings_section.dart';
import '../../domain/entities/faq_entry.dart';
import '../widgets/faq_tile.dart';

/// Help & Support screen, reached from Profile → Help & Support. Matches
/// the reference screen: a search field, a "Quick Help" FAQ list, and a
/// Contact Us card with the support email.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _contactSupport() async {
    await Clipboard.setData(const ClipboardData(text: AppConstants.supportEmail));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppConstants.supportEmail} copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = FaqContent.entries.where((entry) {
      if (_query.trim().isEmpty) return true;
      return entry.question.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.xxxl,
          ),
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.lgRadius,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Quick Help',
              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.ink500),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Center(
                  child: Column(
                    children: [
                      const Mascot(pose: MascotPose.sad, size: 88),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No results for "$_query"',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink500),
                      ),
                    ],
                  ),
                ),
              )
            else
              SettingsSection(
                title: '',
                children: [for (final entry in filtered) FaqTile(entry: entry)],
              ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Contact Us',
              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.ink500),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _contactSupport,
              borderRadius: AppRadius.xlRadius,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.xlRadius,
                ),
                child: Row(
                  children: [
                    const Mascot(pose: MascotPose.wink, size: 52, animated: false),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Still stuck?', style: theme.textTheme.titleMedium),
                          Text(
                            AppConstants.supportEmail,
                            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.ink500),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
