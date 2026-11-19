import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../hadiths/presentation/hadiths_page.dart';
import '../bloc/auth_bloc.dart';
import 'widgets/error_message.dart';
import 'widgets/login_form.dart';

/// Faqat shu akkauntda hadislarni boshqarish huquqi bor.
const String _adminUid = '97yWeMxwBEXHiWyK3bP80v7ffwi1';

/// Kirish holatiga qarab formani, "huquq yo'q" ekranini yoki hadislar
/// sahifasini ko'rsatadi.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    if (user?.uid == _adminUid) return const HadithsPage();

    return Scaffold(
      body: DecoratedBox(
        decoration: _background(context),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.checkingSession) {
                      return const CircularProgressIndicator();
                    }

                    final user = state.user;
                    return user == null
                        ? LoginForm(state: state)
                        : _UnauthorizedCard(
                            state: state,
                            email: user.email ?? user.uid,
                          );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _background(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.secondaryContainer,
          theme.scaffoldBackgroundColor,
          theme.scaffoldBackgroundColor,
        ],
      ),
    );
  }
}

/// Admin huquqi bo'lmagan foydalanuvchi uchun karta.
class _UnauthorizedCard extends StatelessWidget {
  const _UnauthorizedCard({required this.state, required this.email});

  final AuthState state;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bu akkauntda admin huquqi yo‘q',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            SelectableText(email),
            if (state.error case final error?) ...[
              const SizedBox(height: 12),
              ErrorMessage(error),
            ],
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: state.busy
                  ? null
                  : () => context.read<AuthBloc>().add(const SignOutRequested()),
              child: Text(state.busy ? 'Chiqilmoqda…' : 'Chiqish'),
            ),
          ],
        ),
      ),
    );
  }
}
