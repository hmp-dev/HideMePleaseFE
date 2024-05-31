import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseCubit<BaseState> extends Cubit<BaseState> {
  BaseCubit(super.state);
}

abstract class BaseState extends Equatable {
  const BaseState();

  RequestStatus get status => throw UnimplementedError();

  RequestStatus get submitStatus => throw UnimplementedError();

  bool get isLoading =>
      status == RequestStatus.initial || status == RequestStatus.loading;

  bool get isSuccess => status == RequestStatus.success;

  bool get isFailure => status == RequestStatus.failure;

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
