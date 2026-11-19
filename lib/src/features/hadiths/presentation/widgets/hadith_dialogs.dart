import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/hadith_bloc.dart';

/// Hadis maydonlarining foydalanuvchiga ko'rinadigan nomlari.
const Map<String, String> hadithFieldLabels = {
  'title': 'Sarlavha',
  'category': 'Kategoriya',
  'source': 'Manba',
  'textUz': 'Hadis matni (UZ)',
  'order': 'Tartib raqami',
  'titleRu': 'Sarlavha (RU)',
  'categoryRu': 'Kategoriya (RU)',
  'sourceRu': 'Manba (RU)',
  'textRu': 'Hadis matni (RU)',
  'titleEn': 'Sarlavha (EN)',
  'categoryEn': 'Kategoriya (EN)',
  'sourceEn': 'Manba (EN)',
  'textEn': 'Hadis matni (EN)',
};

const List<String> _requiredFields = ['title', 'category', 'source', 'textUz', 'order'];
const List<String> _ruFields = ['titleRu', 'categoryRu', 'sourceRu', 'textRu'];
const List<String> _enFields = ['titleEn', 'categoryEn', 'sourceEn', 'textEn'];

String _label(String key) => hadithFieldLabels[key] ?? key;

/// O'chirishni tasdiqlaydi va tasdiqlansa [DeleteHadith] yuboradi.
Future<void> confirmDeleteHadith(
  BuildContext context, {
  required String id,
  required String title,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hadisni o‘chirish'),
      content: Text('“$title” hadisi ro‘yxatdan o‘chiriladi.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Bekor qilish'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('O‘chirish'),
        ),
      ],
    ),
  );
  if (context.mounted && confirmed == true) {
    context.read<HadithBloc>().add(DeleteHadith(id));
  }
}

/// Mavjud hadis maydonlarini tahrirlash oynasi.
class EditHadithDialog extends StatefulWidget {
  const EditHadithDialog({super.key, required this.id, required this.fields});

  final String id;
  final Map<String, String> fields;

  @override
  State<EditHadithDialog> createState() => _EditHadithDialogState();
}

class _EditHadithDialogState extends State<EditHadithDialog> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.fields.map(
      (key, value) => MapEntry(key, TextEditingController(text: value)),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    Navigator.pop(context, <String, String>{
      for (final field in _controllers.entries)
        if (field.value.text != widget.fields[field.key])
          field.key: field.value.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.id),
      scrollable: true,
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final field in _controllers.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: field.value,
                  minLines: 1,
                  maxLines: 6,
                  decoration: InputDecoration(labelText: _label(field.key)),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        FilledButton(onPressed: _save, child: const Text('Saqlash')),
      ],
    );
  }
}

/// Yangi hadis qo'shish oynasi.
class AddHadithDialog extends StatefulWidget {
  const AddHadithDialog({super.key});

  @override
  State<AddHadithDialog> createState() => _AddHadithDialogState();
}

class _AddHadithDialogState extends State<AddHadithDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    for (final key in hadithFieldLabels.keys) key: TextEditingController(),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(<String, dynamic>{
      for (final field in _controllers.entries)
        field.key: field.key == 'order'
            ? int.parse(field.value.text.trim())
            : field.value.text.trim(),
    });
  }

  Widget _field(String key, {bool isRequired = false}) {
    final isOrder = key == 'order';
    final isMultiline = key.startsWith('text');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: isOrder ? TextInputType.number : null,
        minLines: isMultiline ? 3 : 1,
        maxLines: isMultiline ? 6 : 1,
        decoration: InputDecoration(labelText: _label(key)),
        validator: (value) {
          final input = (value ?? '').trim();
          if (isRequired && input.isEmpty) return 'Bu maydonni to‘ldiring.';
          if (isOrder) {
            final number = int.tryParse(input);
            if (number == null || number < 0) {
              return 'Manfiy bo‘lmagan butun son kiriting.';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hadis qo‘shish'),
      scrollable: true,
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final key in _requiredFields) _field(key, isRequired: true),
              ExpansionTile(
                title: const Text('Ruscha tarjima (ixtiyoriy)'),
                children: [for (final key in _ruFields) _field(key)],
              ),
              ExpansionTile(
                title: const Text('Inglizcha tarjima (ixtiyoriy)'),
                children: [for (final key in _enFields) _field(key)],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Qo‘shish')),
      ],
    );
  }
}
