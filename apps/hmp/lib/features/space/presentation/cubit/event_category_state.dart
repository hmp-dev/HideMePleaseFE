import 'package:equatable/equatable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';

class EventCategoryState extends Equatable {
  final List<EventCategoryEntity> eventCategories;
  final EventCategoryEntity? selectedEventCategory;
  final RequestStatus submitStatus;
  final String? errorMessage;
  final bool isDataLoaded;

  const EventCategoryState({
    this.eventCategories = const [],
    this.selectedEventCategory,
    this.submitStatus = RequestStatus.initial,
    this.errorMessage,
    this.isDataLoaded = false,
  });

  EventCategoryState copyWith({
    List<EventCategoryEntity>? eventCategories,
    EventCategoryEntity? Function()? selectedEventCategory,
    RequestStatus? submitStatus,
    String? errorMessage,
    bool? isDataLoaded,
  }) {
    return EventCategoryState(
      eventCategories: eventCategories ?? this.eventCategories,
      selectedEventCategory: selectedEventCategory != null ? selectedEventCategory() : this.selectedEventCategory,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      isDataLoaded: isDataLoaded ?? this.isDataLoaded,
    );
  }

  @override
  List<Object?> get props => [
        eventCategories,
        selectedEventCategory,
        submitStatus,
        errorMessage,
        isDataLoaded,
      ];
}