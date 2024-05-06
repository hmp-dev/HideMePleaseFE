import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/logger/logger.dart';

abstract class BaseCubit<BaseState> extends Cubit<BaseState> {
  BaseCubit(super.state);

  @override
  void onError(Object error, StackTrace stackTrace) {
    Log.error('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}

abstract class BaseState extends Equatable {
  const BaseState();

  RequestStatus get submitStatus => throw UnimplementedError();

  bool get isLoading =>
      submitStatus == RequestStatus.initial ||
      submitStatus == RequestStatus.loading;

  bool get isSuccess => submitStatus == RequestStatus.success;

  bool get isFailure => submitStatus == RequestStatus.failure;

  bool get isSubmitLoading => submitStatus == RequestStatus.loading;

  bool get isSubmitSuccess => submitStatus == RequestStatus.success;

  bool get isSubmitFailure => submitStatus == RequestStatus.failure;

  @override
  List<Object?> get props => throw UnimplementedError();

  BaseState copyWith() => throw UnimplementedError();

  @override
  bool get stringify => true;
}

enum RequestStatus {
  initial,
  loading,
  success,
  failure,
}
