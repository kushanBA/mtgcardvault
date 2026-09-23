import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../theme.dart' as theme;
import 'login_screen.dart' show Label, Field, GoogleSignInButton, OrDivider;

class RegisterScreen extends StatefulWidget {
  final VoidCallback onHaveAccount;

  const RegisterScreen({super.key, required this.onHaveAccount});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _filled =>
      _nameCtrl.text.trim().isNotEmpty && _emailCtrl.text.trim().isNotEmpty && _passCtrl.text.isNotEmpty;

  void _submit() {
    if (!_filled) return;
    context.read<AuthBloc>().add(
      AuthRegisterRequested(_emailCtrl.text.trim(), _nameCtrl.text.trim(), _passCtrl.text),
    );
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
                'Create your account',
                style: theme.fontDisplay(fontSize: 24, color: t.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Start tracking your collection',
                style: TextStyle(color: t.ink2, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Label('Name', t),
              const SizedBox(height: 8),
              Field(
                controller: _nameCtrl,
                hint: 'Your name',
                t: t,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 18),
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
                          'Create account',
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
                  Text('Already have an account? ', style: TextStyle(color: t.ink2, fontSize: 13)),
                  GestureDetector(
                    onTap: widget.onHaveAccount,
                    child: Text(
                      'Sign in',
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
