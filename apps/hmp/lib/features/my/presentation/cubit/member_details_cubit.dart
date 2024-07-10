import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';

part 'member_details_state.dart';

@lazySingleton
class MemberDetailsCubit extends BaseCubit<MemberDetailsState> {
  final ProfileRepository _profileRepository;

  MemberDetailsCubit(
    this._profileRepository,
  ) : super(MemberDetailsState.initial());

  Future<void> onStart({required String userId}) =>
      onGetProfile(userId: userId);

  Future<void> onGetProfile({required String userId}) async {
    final response = await _profileRepository.getUserProfile(userId: userId);

    response.fold(
      (err) {
        emit(state.copyWith(status: RequestStatus.failure));
      },
      (profile) {
        emit(
          state.copyWith(
            profile: profile.toEntity(),
            status: RequestStatus.success,
          ),
        );
      },
    );
  }
}
