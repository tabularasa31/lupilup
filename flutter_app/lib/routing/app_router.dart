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
    _TabDestination(label: 'Projects', icon: Icons.grid_view_rounded, location: '/projects'),
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: SizedBox(
            height: 88,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  top: 18,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.98),
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
                      padding: const EdgeInsets.fromLTRB(14, 22, 14, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TabBarItem(
                              destination: _tabs[0],
                              selected: selectedIndex == 0,
                              onTap: () {
                                if (_tabs[0].location != location) {
                                  context.go(_tabs[0].location);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 86),
                          Expanded(
                            child: _TabBarItem(
                              destination: _tabs[1],
                              selected: selectedIndex == 1,
                              onTap: () {
                                if (_tabs[1].location != location) {
                                  context.go(_tabs[1].location);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: GestureDetector(
                    onTap: () => context.push('/scan'),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x24A76F6F),
                            blurRadius: 22,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
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
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Icon(
            destination.icon,
            size: 23,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
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
