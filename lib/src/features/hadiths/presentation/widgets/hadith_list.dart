import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/hadith_bloc.dart';
import '../../repository/hadith_repository.dart';
import 'hadith_dialogs.dart';

/// Hadislar ro'yxatini (sarlavha, yuklanish va bo'sh holatlar bilan) ko'rsatadi.
class HadithList extends StatelessWidget {
  const HadithList({super.key, required this.state});

  final HadithState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadError) {
      return const Center(
        child: Text('Hadislarni yuklab bo‘lmadi. Sahifani yangilang.'),
      );
    }
    final documents = state.documents;
    if (documents == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hadislar · ${documents.length}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (state.saving) const LinearProgressIndicator(),
        if (documents.isEmpty)
          const Expanded(child: Center(child: Text('Hozircha hadislar yo‘q.')))
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: documents.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) => HadithTile(
                document: documents[index],
                enabled: !state.saving,
              ),
            ),
          ),
      ],
    );
  }
}

/// Bitta hadis kartochkasi (tahrirlash va o'chirish tugmalari bilan).
class HadithTile extends StatelessWidget {
  const HadithTile({super.key, required this.document, required this.enabled});

  final HadithDocument document;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final strings = _stringFields(document.data());
    final title = strings['title'] ?? strings['titleUz'] ?? document.id;
    final subtitle =
        [strings['category'], strings['source'], if (title != document.id) document.id]
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .join(' · ');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: const Icon(Icons.menu_book_outlined),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: strings.isEmpty
                  ? 'Tahrirlash uchun matn maydoni yo‘q'
                  : 'Tahrirlash',
              onPressed: enabled && strings.isNotEmpty
                  ? () => _edit(context, strings)
                  : null,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'O‘chirish',
              onPressed: enabled
                  ? () => confirmDeleteHadith(
                        context,
                        id: document.id,
                        title: title,
                      )
                  : null,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, Map<String, String> fields) async {
    final changes = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => EditHadithDialog(id: document.id, fields: fields),
    );
    if (context.mounted && changes != null && changes.isNotEmpty) {
      context.read<HadithBloc>().add(SaveHadith(document.id, changes));
    }
  }
}

Map<String, String> _stringFields(Map<String, dynamic> data) => {
  for (final field in data.entries)
    if (field.value is String) field.key: field.value as String,
};
