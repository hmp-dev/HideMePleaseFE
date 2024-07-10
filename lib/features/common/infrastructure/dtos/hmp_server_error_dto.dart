import 'package:equatable/equatable.dart';

class HmpServerErrorDto extends Equatable {
  final int? code;
  final String message;
  final String? error;
  final String? trace;

  const HmpServerErrorDto({
    this.code,
    this.message = "오류가 발생했습니다. 잠시 후 다시 시도해주세요.", //'Something went wrong!',
    this.error,
    this.trace,
  });

  @override
  List<Object?> get props => [
        code,
        message,
        error,
        trace,
      ];
}
