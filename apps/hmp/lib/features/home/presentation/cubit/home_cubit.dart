import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';

part 'home_state.dart';

/// [HomeCubit] is a class that extends [BaseCubit] to handle state changes
/// in the home screen. It has a method [onUpdateHomeViewType] that updates
/// the [HomeViewType] of the home screen.
@lazySingleton
class HomeCubit extends BaseCubit<HomeState> {
  /// Initializes a new instance of the [HomeCubit] class.
  ///
  /// The initial state of the cubit is obtained from calling the [HomeState.initial]
  /// factory constructor.
  HomeCubit() : super(HomeState.initial());

  /// Updates the [homeViewType] of the state to the given [homeViewType].
  ///
  /// The [homeViewType] parameter is of type [HomeViewType] and represents the
  /// new view type for the home screen.
  ///
  /// This method emits a new state by calling the [emit] method of the base class
  /// [BaseCubit] with the updated state obtained by calling the [copyWith]
  /// method of the current state and passing the [homeViewType] parameter.
  void onUpdateHomeViewType(HomeViewType homeViewType) {
    emit(state.copyWith(homeViewType: homeViewType));
  }
}
