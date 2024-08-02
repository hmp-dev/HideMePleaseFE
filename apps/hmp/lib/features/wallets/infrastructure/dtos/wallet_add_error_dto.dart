import 'package:equatable/equatable.dart';

/// A data transfer object (DTO) that represents an error response for adding a wallet.
///
/// This class holds the [code], [message], [error], and [trace] properties,
/// which are used to provide additional information about an error that occurred
/// during the process of adding a wallet.
class WalletAddErrorDto extends Equatable {
  /// The error code.
  final int? code;

  /// The error message.
  ///
  /// The default value is 'Something went wrong!'.
  final String message;

  /// The error that occurred.
  final String? error;

  /// The stack trace of the error.
  final String? trace;

  /// Creates a [WalletAddErrorDto] instance.
  ///
  /// The [code] parameter is the error code.
  /// The [message] parameter is the error message.
  /// The [error] parameter is the error that occurred.
  /// The [trace] parameter is the stack trace of the error.
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
