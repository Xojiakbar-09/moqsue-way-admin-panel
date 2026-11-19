import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../bloc/hadith_bloc.dart';
import '../repository/hadith_repository.dart';
import 'widgets/hadith_dialogs.dart';
import 'widgets/hadith_list.dart';

/// Admin uchun hadislarni boshqarish sahifasi.
class HadithsPage extends StatelessWidget {
  const HadithsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HadithBloc(
        FirestoreHadithRepository(
          FirebaseFirestore.instance.collection('hadiths'),
        ),
      ),
      child: BlocConsumer<HadithBloc, HadithState>(
        listenWhen: (_, state) => state.message != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mosque_outlined),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text('Masjid Admin', overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              actions: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, auth) {
                    return TextButton(
                      onPressed: state.saving || auth.busy
                          ? null
                          : () => context
                                .read<AuthBloc>()
                                .add(const SignOutRequested()),
                      child: Text(auth.busy ? 'Chiqilmoqda…' : 'Chiqish'),
                    );
                  },
                ),
                const SizedBox(width: 16),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: state.saving || state.documents == null || state.loadError
                  ? null
                  : () => _addHadith(context),
              icon: const Icon(Icons.add),
              label: const Text('Hadis qo‘shish'),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: HadithList(state: state),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addHadith(BuildContext context) async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddHadithDialog(),
    );
    if (context.mounted && data != null) {
      context.read<HadithBloc>().add(AddHadith(data));
    }
  }
}
