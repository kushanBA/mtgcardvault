import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../theme.dart' as theme;

class LoginScreen extends StatefulWidget {
  final VoidCallback onCreateAccount;

  const LoginScreen({super.key, required this.onCreateAccount});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _filled => _emailCtrl.text.trim().isNotEmpty && _passCtrl.text.isNotEmpty;

  void _submit() {
    if (!_filled) return;
    context.read<AuthBloc>().add(AuthLoginRequested(_emailCtrl.text.trim(), _passCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    final state = context.watch<AuthBloc>().state;
    final loading = state.status == AuthStatus.loading;
    final canSubmit = _filled && !loading;

    return Container(
      color: t.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 48),
              Text(
                'CardVault',
                style: theme.fontDisplay(fontSize: 22, color: t.accent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome back',
                style: theme.fontDisplay(fontSize: 24, color: t.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to track your collection',
                style: TextStyle(color: t.ink2, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Label('Email', t),
              const SizedBox(height: 8),
              Field(
                controller: _emailCtrl,
                hint: 'you@email.com',
                t: t,
                keyboardType: TextInputType.emailAddress,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 18),
              Label('Password', t),
              const SizedBox(height: 8),
              Field(
                controller: _passCtrl,
                hint: '••••••••',
                t: t,
                obscure: _obscure,
                onChanged: () => setState(() {}),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Text(
                    _obscure ? 'Show' : 'Hide',
                    style: TextStyle(color: t.muted, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (state.status == AuthStatus.error && state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: t.down.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(state.errorMessage!, style: TextStyle(color: t.down, fontSize: 13)),
                ),
              ],
              const SizedBox(height: 26),
              GestureDetector(
                onTap: canSubmit ? _submit : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: canSubmit ? t.ink : t.line,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: t.bg),
                        )
                      : Text(
                          'Sign in',
                          style: TextStyle(color: t.bg, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              OrDivider(t),
              const SizedBox(height: 18),
              GoogleSignInButton(
                t: t,
                loading: loading,
                onTap: loading
                    ? null
                    : () => context.read<AuthBloc>().add(const AuthGoogleLoginRequested()),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: t.ink2, fontSize: 13)),
                  GestureDetector(
                    onTap: widget.onCreateAccount,
                    child: Text(
                      'Create one',
                      style: TextStyle(color: t.accent, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Label extends StatelessWidget {
  final String text;
  final theme.AppColors t;
  const Label(this.text, this.t, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(color: t.ink2, fontSize: 12.5, fontWeight: FontWeight.w600),
  );
}

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final theme.AppColors t;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final VoidCallback onChanged;

  const Field({
    super.key,
    required this.controller,
    required this.hint,
    required this.t,
    required this.onChanged,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: TextStyle(color: t.ink, fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: t.muted, fontSize: 15),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  final theme.AppColors t;
  const OrDivider(this.t, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: t.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('or', style: TextStyle(color: t.muted, fontSize: 12.5)),
        ),
        Expanded(child: Divider(color: t.line)),
      ],
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final theme.AppColors t;
  final bool loading;
  final VoidCallback? onTap;

  const GoogleSignInButton({super.key, required this.t, required this.loading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: t.ink2),
              )
            : Text(
                'Continue with Google',
                style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
