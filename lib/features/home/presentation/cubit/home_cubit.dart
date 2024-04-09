import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';

part 'home_state.dart';

@lazySingleton
class HomeCubit extends BaseCubit<HomeState> {
  HomeCubit() : super(HomeState.initial());

  onUpdateHomeViewType(HomeViewType homeViewType) {
    emit(state.copyWith(homeViewType: homeViewType));
  }
}
