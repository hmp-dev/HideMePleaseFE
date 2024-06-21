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

  NotificationsCubit(
    this._settingsRepository,
  ) : super(NotificationsState.initial());

  Future<void> onStart() async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _settingsRepository.getNotifications();
    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
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
