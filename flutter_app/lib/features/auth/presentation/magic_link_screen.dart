import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lupilup_flutter/core/theme/app_theme.dart';
import 'package:lupilup_flutter/core/widgets/app_scaffold.dart';
import 'package:lupilup_flutter/core/widgets/section_card.dart';
import 'package:lupilup_flutter/features/auth/data/auth_repository.dart';

class MagicLinkScreen extends ConsumerStatefulWidget {
  const MagicLinkScreen({super.key});

  @override
  ConsumerState<MagicLinkScreen> createState() => _MagicLinkScreenState();
}

class _MagicLinkScreenState extends ConsumerState<MagicLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).sendMagicLink(_emailController.text);
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send magic link: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return AppScaffold(
        child: Center(
          child: SectionCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Check your inbox', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(
                  'We sent a magic link to ${_emailController.text.trim().toLowerCase()}.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap the link in the email to sign in. It expires in 1 hour.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => setState(() => _sent = false),
                  child: const Text('Use a different email'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: 'Sign in with email',
      child: ListView(
        children: [
          Text(
            'Enter your email and we\'ll send you a magic link, no password needed.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          SectionCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                    ),
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty || !text.contains('@')) {
                        return 'Enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _send,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Send magic link'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

