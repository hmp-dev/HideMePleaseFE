import 'package:equatable/equatable.dart';

class WalletAddErrorDto extends Equatable {
  final int? code;
  final String message;
  final String? error;
  final String? trace;

  const WalletAddErrorDto({
    this.code,
    this.message = 'Something went wrong!',
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
