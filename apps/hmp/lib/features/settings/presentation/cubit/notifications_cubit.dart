import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/settings/domain/entities/notification_entity.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'notifications_state.dart';

@lazySingleton
class NotificationsCubit extends BaseCubit<NotificationsState> {
  final SettingsRepository _settingsRepository;

  // Injects the SettingsRepository to the NotificationsCubit
  NotificationsCubit(
    this._settingsRepository,
  ) : super(NotificationsState.initial());

  /// Retrieves the notifications from the server using the
  /// SettingsRepository and emits the states accordingly.
  ///
  /// The cubit starts by emitting the loading state. If the repository
  /// returns a failure, the cubit emits the failure state with the
  /// 'somethingError' translated message. If the repository returns a success,
  /// the cubit emits the success state with the notifications mapped to
  /// NotificationEntity objects.
  Future<void> onStart() async {
    // Emits the loading state
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    // Retrieves the notifications from the repository
    final response = await _settingsRepository.getNotifications();

    // Handles the response based on the result
    response.fold(
      // If the response is a failure, emits the failure state
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // If the response is a success, maps the result to NotificationEntity
      // objects and emits the success state
      (result) {
        final resultList = result.map((e) => e.toEntity()).toList();
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            notifications: resultList,
          ),
        );
      },
    );
  }
}
