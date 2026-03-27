import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/features/auth/presentation/auth_callback_screen.dart';
import 'package:lupilup_flutter/features/auth/presentation/bootstrap_screen.dart';
import 'package:lupilup_flutter/features/auth/presentation/login_screen.dart';
import 'package:lupilup_flutter/features/auth/presentation/magic_link_screen.dart';
import 'package:lupilup_flutter/features/onboarding/presentation/ravelry_onboarding_screen.dart';
import 'package:lupilup_flutter/features/projects/presentation/project_detail_screen.dart';
import 'package:lupilup_flutter/features/projects/presentation/projects_screen.dart';
import 'package:lupilup_flutter/features/scanner/presentation/scanner_screen.dart';
import 'package:lupilup_flutter/features/settings/presentation/settings_screen.dart';
import 'package:lupilup_flutter/features/stash/presentation/stash_editor_screen.dart';
import 'package:lupilup_flutter/features/stash/presentation/stash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final uri = state.uri;

      // iOS custom schemes like `lupilup://auth/callback?...` are parsed as:
      // - scheme: lupilup
      // - host: auth
      // - path: /callback
      // Normalize them into app routes GoRouter can match.
      if (uri.scheme == 'lupilup' && uri.host == 'auth' && uri.path == '/callback') {
        final normalized = Uri(
          path: '/auth/callback',
          queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
          fragment: uri.fragment.isEmpty ? null : uri.fragment,
        );
        return normalized.toString();
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BootstrapScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/magic-link',
        builder: (context, state) => const MagicLinkScreen(),
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) => const AuthCallbackScreen(),
      ),
      GoRoute(
        path: '/callback',
        builder: (context, state) => const AuthCallbackScreen(),
      ),
      GoRoute(
        path: '/onboarding/ravelry',
        builder: (context, state) => const RavelryOnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainTabScaffold(child: child),
        routes: [
          GoRoute(
            path: '/stash',
            builder: (context, state) => const StashScreen(),
            routes: [
              GoRoute(
                path: 'add-edit',
                builder: (context, state) {
                  final id = state.uri.queryParameters['id'];
                  return StashEditorScreen(itemId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/scan',
            builder: (context, state) => const ScannerScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  return ProjectDetailScreen(projectId: state.pathParameters['id']!);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class MainTabScaffold extends StatelessWidget {
  const MainTabScaffold({
    required this.child,
    super.key,
  });

  final Widget child;

  static const _tabs = <_TabDestination>[
    _TabDestination(label: 'Stash', icon: Icons.inventory_2_outlined, location: '/stash'),
    _TabDestination(label: 'Scan', icon: Icons.document_scanner_outlined, location: '/scan'),
    _TabDestination(label: 'Projects', icon: Icons.grid_view_rounded, location: '/projects'),
    _TabDestination(label: 'Settings', icon: Icons.tune_rounded, location: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere((tab) => location.startsWith(tab.location));
    final selectedIndex = currentIndex < 0 ? 0 : currentIndex;

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderStrong),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F0C0A),
                  blurRadius: 26,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final selected = index == selectedIndex;
                  return Expanded(
                    child: _TabBarItem(
                      destination: tab,
                      selected: selected,
                      onTap: () {
                        if (tab.location != location) {
                          context.go(tab.location);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarItem extends StatelessWidget {
  const _TabBarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _TabDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF8EFEB) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              destination.icon,
              size: 24,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              destination.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabDestination {
  const _TabDestination({
    required this.label,
    required this.icon,
    required this.location,
  });

  final String label;
  final IconData icon;
  final String location;
}
