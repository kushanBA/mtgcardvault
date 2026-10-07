import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../theme.dart' as theme;

class SaveVaultStep extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEmail;

  const SaveVaultStep({super.key, required this.onBack, required this.onEmail});

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    final authState = context.watch<AuthBloc>().state;
    final loading = authState.status == AuthStatus.loading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t.line)),
                child: Text('‹', style: TextStyle(color: t.ink2, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: t.panel,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3B2A6B), Color(0xFF1B1230)]),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'READY TO SAVE',
                          style: TextStyle(color: t.muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                        ),
                        Text(
                          'Sheoldred, the Apocalypse',
                          style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Text('\$84.50', style: theme.fontHeavy(fontSize: 16, color: t.ink)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('Save it to your vault.', style: theme.fontDisplay(fontSize: 25, color: t.ink)),
            const SizedBox(height: 10),
            Text(
              'Create your free account so your scans, binders and prices are safe on every device.',
              style: TextStyle(color: t.ink2, fontSize: 14, height: 1.55),
            ),
            if (authState.status == AuthStatus.error && authState.errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: t.down.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(authState.errorMessage!, style: TextStyle(color: t.down, fontSize: 13)),
              ),
            ],
            const Spacer(),
            _AuthButton(
              onTap: null,
              background: Colors.white.withValues(alpha: 0.4),
              foreground: const Color(0xFF0B0E11).withValues(alpha: 0.5),
              glyph: '🍎',
              label: 'Continue with Apple',
              trailingBadge: 'Coming soon',
            ),
            const SizedBox(height: 10),
            _AuthButton(
              onTap: loading ? null : () => context.read<AuthBloc>().add(const AuthGoogleLoginRequested()),
              background: t.panel,
              foreground: t.ink,
              border: t.line,
              glyph: 'G',
              glyphColor: const Color(0xFF4285F4),
              label: 'Continue with Google',
              loading: loading,
            ),
            const SizedBox(height: 10),
            _AuthButton(
              onTap: loading ? null : onEmail,
              background: t.panel,
              foreground: t.ink,
              border: t.line,
              glyph: '✉',
              label: 'Continue with email',
            ),
            const SizedBox(height: 16),
            Text(
              'By continuing you agree to our Terms and Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.muted, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;
  final Color? border;
  final String glyph;
  final Color? glyphColor;
  final String label;
  final String? trailingBadge;
  final bool loading;

  const _AuthButton({
    required this.onTap,
    required this.background,
    required this.foreground,
    required this.glyph,
    required this.label,
    this.border,
    this.glyphColor,
    this.trailingBadge,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: border != null ? Border.all(color: border!) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
              )
            else ...[
              Text(glyph, style: TextStyle(color: glyphColor ?? foreground, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: foreground, fontSize: 14.5, fontWeight: FontWeight.w700)),
              if (trailingBadge != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailingBadge!,
                  style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
