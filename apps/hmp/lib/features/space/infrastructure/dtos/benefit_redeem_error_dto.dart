import 'package:equatable/equatable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BenefitRedeemErrorDto extends Equatable {
  final int? code;
  final String message;
  final String? error;
  final String? trace;

  BenefitRedeemErrorDto({
    this.code,
    String? message,
    this.error,
    this.trace,
  }) : message = message ?? LocaleKeys.error_default_message.tr();

  @override
  List<Object?> get props => [
        code,
        message,
        error,
        trace,
      ];
}
