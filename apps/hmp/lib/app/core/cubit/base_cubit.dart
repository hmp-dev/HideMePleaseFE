import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/logger/logger.dart';

abstract class BaseCubit<BaseState> extends Cubit<BaseState> {
  BaseCubit(super.state);

  @override

  /// Handles errors that occur during the execution of a function.
  ///
  /// Logs the error message and stack trace using the Log class.
  /// Calls the superclass method to handle the error.
  void onError(Object error, StackTrace stackTrace) {
    Log.error('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}

abstract class BaseState extends Equatable {
  const BaseState();

  /// Gets the current status of the request.
  ///
  /// Default implementation returns submitStatus. Override for custom logic.
  RequestStatus get status => submitStatus;

  RequestStatus get submitStatus => throw UnimplementedError();

  /// A getter that returns the loading status.
  ///
  /// This property indicates whether a loading process is currently
  /// active. It returns `true` if loading is in progress, otherwise `false`.
  bool get isLoading =>
      status == RequestStatus.initial || status == RequestStatus.loading;

  /// A getter that checks if the request status is successful.
  ///
  /// Returns `true` if the `status` is equal to `RequestStatus.success`, otherwise `false`.
  bool get isSuccess => status == RequestStatus.success;

  /// A getter that checks if the request status is a failure.
  ///
  /// Returns `true` if the status is `RequestStatus.failure`, otherwise `false`.
  bool get isFailure => status == RequestStatus.failure;

  /// A getter that checks if the submit action is currently loading.
  ///
  /// Returns `true` if the `submitStatus` is equal to `RequestStatus.loading`,
  /// otherwise returns `false`.
  bool get isSubmitLoading => submitStatus == RequestStatus.loading;

  bool get isSubmitSuccess => submitStatus == RequestStatus.success;

  bool get isSubmitFailure => submitStatus == RequestStatus.failure;

  @override
  List<Object?> get props => throw UnimplementedError();

  /// Creates a copy of the current state.
  ///
  /// This method should be overridden to return a new instance of the state
  /// with the desired modifications.
  ///
  /// Throws an [UnimplementedError] if not overridden.
  BaseState copyWith() => throw UnimplementedError();

  /// A getter that returns `true` to indicate that the object should be stringified.
  @override
  bool get stringify => true;
}

enum RequestStatus {
  initial,
  loading,
  success,
  failure,
}
