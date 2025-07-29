import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';
import 'package:mobile/features/space/domain/repositories/event_category_repository.dart';
import 'package:mobile/features/space/presentation/cubit/event_category_state.dart';

@injectable
class EventCategoryCubit extends Cubit<EventCategoryState> {
  final EventCategoryRepository _eventCategoryRepository;

  EventCategoryCubit(this._eventCategoryRepository)
      : super(const EventCategoryState()) {
    print('🚨🚨🚨 EVENT CATEGORY CUBIT: Created with repository: $_eventCategoryRepository');
    // Load event categories immediately when cubit is created
    print('🚨🚨🚨 EVENT CATEGORY CUBIT: Auto-loading event categories on creation...');
    loadEventCategories(includeInactive: true);
  }

  Future<void> loadEventCategories({bool includeInactive = false}) async {
    // 이미 데이터가 로드되어 있으면 캐시된 데이터 사용
    if (state.isDataLoaded && state.eventCategories.isNotEmpty) {
      print('🚨🚨🚨 EVENT CATEGORY: Using cached data (${state.eventCategories.length} categories)');
      emit(state.copyWith(submitStatus: RequestStatus.success));
      return;
    }

    print('🚨🚨🚨 EVENT CATEGORY: Loading event categories from server...');
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final result = await _eventCategoryRepository.getEventCategories(
      includeInactive: includeInactive,
    );

    result.fold(
      (error) {
        print('🚨🚨🚨 EVENT CATEGORY ERROR: Failed to load - ${error.message}');
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: error.message,
        ));
      },
      (categories) {
        print('🚨🚨🚨 EVENT CATEGORY SUCCESS: Loaded ${categories.length} event categories');
        if (categories.isNotEmpty) {
          for (var category in categories) {
            print('  - ${category.name} (${category.id})');
          }
        }
        emit(state.copyWith(
          eventCategories: categories,
          submitStatus: RequestStatus.success,
          isDataLoaded: true,
        ));
      },
    );
  }

  void selectEventCategory(EventCategoryEntity? category) {
    emit(state.copyWith(selectedEventCategory: () => category));
  }

  void clearSelection() {
    emit(state.copyWith(selectedEventCategory: () => null));
  }
}