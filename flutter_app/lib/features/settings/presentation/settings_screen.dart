import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/core/widgets/app_scaffold.dart';
import 'package:lupilup_flutter/core/widgets/section_card.dart';
import 'package:lupilup_flutter/features/auth/data/auth_repository.dart';
import 'package:lupilup_flutter/features/onboarding/logic/ravelry_onboarding_controller.dart';
import 'package:lupilup_flutter/features/settings/data/settings_repository.dart';
import 'package:lupilup_flutter/features/settings/data/user_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentUserSettingsProvider);

    return AppScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: settings.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => Center(
          child: Text('Could not load settings: $error'),
        ),
        data: (value) {
          if (value == null) {
            return const Center(child: Text('No settings yet.'));
          }

          return ListView(
            children: [
              const _SettingsHeader(),
              const SizedBox(height: 20),
              SectionCard(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SettingsSectionTitle(
                      icon: Icons.straighten_rounded,
                      title: 'Unit system',
                      subtitle: 'Pick the measurements that feel natural when logging yarn.',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F4F0),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFF0E4DC)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SettingsChoicePill(
                              label: 'Metric',
                              selected: value.unitSystem == UnitSystem.metric,
                              onTap: () async {
                                await ref
                                    .read(settingsRepositoryProvider)
                                    .updateUnitSystem(UnitSystem.metric);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SettingsChoicePill(
                              label: 'Imperial',
                              selected: value.unitSystem == UnitSystem.imperial,
                              onTap: () async {
                                await ref
                                    .read(settingsRepositoryProvider)
                                    .updateUnitSystem(UnitSystem.imperial);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingsSectionTitle(
                      icon: Icons.auto_stories_rounded,
                      title: 'Ravelry',
                      subtitle: value.hasRavelry
                          ? 'Your read-only import is connected and ready.'
                          : 'Bring your existing stash in when you are ready.',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: value.hasRavelry
                            ? const Color(0xFFF4F0EA)
                            : const Color(0xFFF8F4F0),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF0E4DC)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: value.hasRavelry
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              value.hasRavelry
                                  ? 'Connected for import'
                                  : 'Not connected yet',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      value.hasRavelry
                          ? 'Your Ravelry import is connected.'
                          : 'Not connected yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.55,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (value.hasRavelry)
                      OutlinedButton(
                        onPressed: () => ref
                            .read(ravelryOnboardingControllerProvider.notifier)
                            .disconnect(value.unitSystem),
                        child: const Text('Disconnect Ravelry'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => context.go('/onboarding/ravelry'),
                        child: const Text('Connect Ravelry'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingsSectionTitle(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Premium',
                      subtitle: value.isPremium
                          ? 'Everything is unlocked.'
                          : 'A future upgrade path for heavier knit planning.',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      value.isPremium
                          ? 'Premium is active.'
                          : 'Premium upgrade flow is planned next. Scanner and stash stay available in free mode for now.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.55,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: value.isPremium ? null : () {},
                      child: Text(value.isPremium ? 'Premium active' : 'Upgrade soon'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SettingsSectionTitle(
                      icon: Icons.logout_rounded,
                      title: 'Session',
                      subtitle: 'Sign out on this device whenever you need a clean restart.',
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) {
                          context.go('/');
                        }
                      },
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsChoicePill extends StatelessWidget {
  const _SettingsChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF6D7D6) : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFF1C1BF) : const Color(0xFFE4D7CE),
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x10C98989),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 38,
                height: 1,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Adjust the way lupilup feels, from units and imports to the little things that keep the app yours.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
        ),
      ],
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F4F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0E4DC)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
