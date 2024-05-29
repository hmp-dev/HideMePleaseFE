import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/wallet_type.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/generated/locale_keys.g.dart';

String formatWalletAddress(String walletAddress) {
  if (walletAddress.length < 10) {
    return walletAddress; // Return the original address if it's too short
  }

  // Extract the first 6 characters and last 4 characters
  String prefix = walletAddress.substring(0, 6);
  String suffix = walletAddress.substring(walletAddress.length - 4);

  // Format the truncated address with ellipsis
  String formattedAddress = '$prefix...$suffix';

  return formattedAddress;
}

String getWalletProvider(String inputString) {
  String lowercaseInput = inputString.toLowerCase();
  for (WalletProvider provider in WalletProvider.values) {
    if (lowercaseInput.contains(provider.name.toLowerCase())) {
      return provider.name;
    }
  }
  return '';
}

String formatDate(DateTime dateTime) {
  // Define the desired date format
  final dateFormat = DateFormat('MM/dd HH:mm');

  // Format the DateTime object using the defined format
  return dateFormat.format(dateTime);
}

String formatDateGetMonthYear(String dateTimeString) {
  // Parse the string into a DateTime object
  DateTime dateTime = DateTime.parse(dateTimeString);

  // Define the desired date format
  final dateFormat = DateFormat('MM/yy');

  // Format the DateTime object using the defined format
  return dateFormat.format(dateTime);
}

String formatNumberWithCommas(String numberString) {
  final number = int.tryParse(numberString) ?? 0;
  final formatter = NumberFormat('#,###');
  return formatter.format(number);
}

// ============

showHmpAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required Function onConfirm,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        title: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: fontTitle07Bold(),
          ),
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: fontBodySm(),
        ),
        actions: <Widget>[
          HMPCustomButton(
            bgColor: bg4,
            text: LocaleKeys.confirm.tr(),
            onPressed: () {
              onConfirm();
            },
          ),
        ],
      );
    },
  );
}

String getLocalCategoryName(String categoryName) {
  switch (categoryName) {
    case 'ENTIRE':
      return LocaleKeys.entire.tr();
    case "PUB":
      return LocaleKeys.entire.tr();
    case "CAFE":
      return LocaleKeys.entire.tr();
    case "COWORKING":
      return LocaleKeys.entire.tr();
    case "MUSIC":
      return LocaleKeys.entire.tr();
    case "MEAL":
      return LocaleKeys.entire.tr();
    default:
      throw Exception('Unhandled category');
  }
}
