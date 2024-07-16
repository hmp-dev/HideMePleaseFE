part of 'submit_location_cubit.dart';

class SubmitLocationState extends BaseState {
  final String errorMessage;
  final double latitude;
  final double longitude;
  final bool isLocationSubmitted;

  @override
  final RequestStatus submitStatus;

  const SubmitLocationState({
    required this.latitude,
    required this.longitude,
    required this.isLocationSubmitted,
    required this.errorMessage,
    this.submitStatus = RequestStatus.initial,
  });

  factory SubmitLocationState.initial() => const SubmitLocationState(
        submitStatus: RequestStatus.initial,
        errorMessage: '',
        latitude: 0.0,
        longitude: 0.0,
        isLocationSubmitted: false,
      );

  @override
  List<Object?> get props => [
        submitStatus,
        errorMessage,
        latitude,
        longitude,
        isLocationSubmitted,
      ];

  @override
  SubmitLocationState copyWith({
    RequestStatus? submitStatus,
    String? errorMessage,
    int? submitCount,
    double? latitude,
    double? longitude,
    bool? isLocationSubmitted,
  }) {
    return SubmitLocationState(
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLocationSubmitted: isLocationSubmitted ?? this.isLocationSubmitted,
    );
  }
}
