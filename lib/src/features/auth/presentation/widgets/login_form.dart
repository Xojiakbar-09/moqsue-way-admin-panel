import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc.dart';
import 'error_message.dart';

/// Email/parol orqali admin sifatida kirish formasi.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.state});

  final AuthState state;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.state.busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      SignInRequested(_email.text.trim(), _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BrandAvatar(),
              const SizedBox(height: 20),
              Text(
                'Masjid Admin',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text('Admin akkauntingiz bilan kiring.',
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 28),
              TextFormField(
                controller: _email,
                enabled: !state.busy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Email manzilini kiriting.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                enabled: !state.busy,
                obscureText: _hidden,
                autocorrect: false,
                enableSuggestions: false,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Parol',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _hidden ? 'Parolni ko‘rsatish' : 'Parolni yashirish',
                    onPressed: () => setState(() => _hidden = !_hidden),
                    icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (value) =>
                    (value ?? '').isEmpty ? 'Parolni kiriting.' : null,
              ),
              if (state.error case final error?) ...[
                const SizedBox(height: 12),
                ErrorMessage(error),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: state.busy ? null : _submit,
                child: Text(state.busy ? 'Kirilmoqda…' : 'Kirish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandAvatar extends StatelessWidget {
  const _BrandAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        child: const Icon(Icons.mosque_outlined, size: 28),
      ),
    );
  }
}
