import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/hadith_repository.dart';

sealed class HadithEvent {
  const HadithEvent();
}

/// Firestore'dagi hadislarni kuzatishni boshlaydi.
final class WatchHadiths extends HadithEvent {
  const WatchHadiths();
}

/// Ma'lumotni o'zgartiruvchi amallar uchun umumiy asos.
sealed class HadithMutation extends HadithEvent {
  const HadithMutation();
}

final class AddHadith extends HadithMutation {
  const AddHadith(this.data);

  final Map<String, dynamic> data;
}

final class DeleteHadith extends HadithMutation {
  const DeleteHadith(this.id);

  final String id;
}

final class SaveHadith extends HadithMutation {
  const SaveHadith(this.id, this.changes);

  final String id;
  final Map<String, String> changes;
}

class HadithState {
  const HadithState({
    this.documents,
    this.saving = false,
    this.loadError = false,
    this.message,
  });

  final List<HadithDocument>? documents;
  final bool saving;
  final bool loadError;
  final String? message;
}

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  HadithBloc(this._repository) : super(const HadithState()) {
    on<WatchHadiths>(_onWatch);
    on<HadithMutation>(_onMutation);

    add(const WatchHadiths());
  }

  final HadithRepository _repository;

  Future<void> _onWatch(WatchHadiths event, Emitter<HadithState> emit) {
    return emit.forEach<List<HadithDocument>>(
      _repository.watch(),
      onData: (documents) =>
          HadithState(documents: documents, saving: state.saving),
      onError: (error, stackTrace) => HadithState(
        documents: state.documents,
        saving: state.saving,
        loadError: true,
      ),
    );
  }

  Future<void> _onMutation(
    HadithMutation event,
    Emitter<HadithState> emit,
  ) async {
    if (state.saving) return;
    emit(
      HadithState(
        documents: state.documents,
        saving: true,
        loadError: state.loadError,
      ),
    );

    String message;
    try {
      switch (event) {
        case AddHadith(:final data):
          await _repository.add(data);
          message = 'Hadis qo‘shildi.';
        case DeleteHadith(:final id):
          await _repository.delete(id);
          message = 'Hadis o‘chirildi.';
        case SaveHadith(:final id, :final changes):
          await _repository.update(id, changes);
          message = 'Hadis saqlandi.';
      }
    } on FirebaseException catch (error) {
      message = switch (error.code) {
        'permission-denied' => 'Bu amal uchun ruxsat yo‘q.',
        'not-found' => 'Bu hadis endi bazada yo‘q.',
        _ => 'Amal bajarilmadi. Qayta urinib ko‘ring.',
      };
    }
    emit(
      HadithState(
        documents: state.documents,
        loadError: state.loadError,
        message: message,
      ),
    );
  }
}
