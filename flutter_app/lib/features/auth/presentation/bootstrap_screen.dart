import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/core/widgets/brand_wordmark.dart';
import 'package:lupilup_flutter/features/auth/logic/auth_state.dart';

class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<BootstrapState>>(
      bootstrapStateProvider,
      (_, next) => next.whenData(_handleBootstrapState),
      fireImmediately: true,
    );
  }

  void _handleBootstrapState(BootstrapState state) {
    if (!mounted || _hasNavigated) {
      return;
    }

    _hasNavigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (state.target == AppBootstrapTarget.login) {
        context.go('/login');
      } else if (state.target == AppBootstrapTarget.onboarding) {
        context.go('/onboarding/ravelry');
      } else {
        context.go('/stash');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bootstrapState = ref.watch(bootstrapStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: bootstrapState.when(
          data: (_) => const _BootstrapContent(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          loading: () => const _BootstrapContent(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (error, _) => _BootstrapContent(
            child: Text(
              'We could not finish sign in.\n$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BootstrapContent extends StatelessWidget {
  const _BootstrapContent({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandWordmark(size: 58),
        const SizedBox(height: 10),
        Text(
          'your yarn, beautifully organised',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
        ),
        const SizedBox(height: 28),
        child,
      ],
    );
  }
}
