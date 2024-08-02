// ignore_for_file: constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';

enum ErrorCodes {
  COULD_NOT_VERIFY,
  JWT_INVALID_OR_EXPIRED,
  USER_DOES_NOT_EXIST,
  WALLET_DOES_NOT_EXIST,
  MISSING_WELCOME_NFT,
  INVALID_SPACE_ID,
  INVALID_BENEFIT_ID,
  BENEFIT_TOKEN_EXPIRED,
  ENTITY_NOT_FOUND,
  SINGLE_USE_BENEFIT_USED,
  BENEFIT_ALREADY_USED_TODAY,
  SPACE_OUT_OF_RANGE,
  MISSING_IMPLEMENTATION,
  WALLET_ALREADY_LINKED,
  UNHANDLED_ERROR,
}

extension ErrorMessages on ErrorCodes {
  /// Provides a human-readable message corresponding to the error code.
  String get message {
    switch (this) {
      case ErrorCodes.COULD_NOT_VERIFY:
        return 'Could not verify.';
      case ErrorCodes.JWT_INVALID_OR_EXPIRED:
        return 'JWT is invalid or expired.';
      case ErrorCodes.USER_DOES_NOT_EXIST:
        return 'User does not exist.';
      case ErrorCodes.WALLET_DOES_NOT_EXIST:
        return 'Wallet does not exist.';
      case ErrorCodes.MISSING_WELCOME_NFT:
        return 'Missing welcome NFT.';
      case ErrorCodes.INVALID_SPACE_ID:
        return 'Invalid space ID.';
      case ErrorCodes.INVALID_BENEFIT_ID:
        return 'Invalid benefit ID.';
      case ErrorCodes.BENEFIT_TOKEN_EXPIRED:
        return 'Benefit token expired.';
      case ErrorCodes.ENTITY_NOT_FOUND:
        return 'Entity not found.';
      case ErrorCodes.SINGLE_USE_BENEFIT_USED:
        return 'Single use benefit already used.';
      case ErrorCodes.BENEFIT_ALREADY_USED_TODAY:
        return 'Benefit already used today.';
      case ErrorCodes.SPACE_OUT_OF_RANGE:
        return 'Space out of range.';
      case ErrorCodes.MISSING_IMPLEMENTATION:
        return 'Missing implementation.';
      case ErrorCodes.WALLET_ALREADY_LINKED:
        return LocaleKeys.walletAlreadyLinkedMessage.tr();
      case ErrorCodes.UNHANDLED_ERROR:
        return 'Unhandled error.';
      default:
        return 'Unknown error.';
    }
  }
}

/// Retrieves the error message corresponding to the provided error code.
///
/// This function searches through the `ErrorCodes` enumeration to find a match
/// for the given `errorCode`. If a match is found, the associated error message
/// is returned. If no match is found or an exception occurs, a default error
/// message is returned.
///
/// @param errorCode The error code for which the error message is to be retrieved.
/// @return The error message corresponding to the provided error code, or a default
///         message if the error code is not found or an exception occurs.
String getErrorMessage(String errorCode) {
  try {
    return ErrorCodes.values
        .firstWhere((e) => e.toString().split('.').last == errorCode)
        .message;
  } catch (e) {
    return 'An unknown error occurred.';
  }
}
