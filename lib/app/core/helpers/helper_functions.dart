import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/wallet_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/pref_keys.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  try {
    // Define the desired date format
    final dateFormat = DateFormat('MM/dd HH:mm');

    // Format the DateTime object using the defined format
    return dateFormat.format(dateTime);
  } catch (e) {
    "$e".log();

    "error formatting passed date: $dateTime".log();
    return '';
  }
}

String getCreatedAt(String dateString) {
  try {
    // Parse the input date string to a DateTime object
    DateTime dateTime = DateTime.parse(dateString);

    // Format the DateTime object to the desired format
    String formattedDate = DateFormat('yyyy/MM/dd').format(dateTime);

    return formattedDate;
  } catch (e) {
    "$e".log();

    "error formatting passed date: $dateString".log();
    return '';
  }
}

String formatDateGetMonthYear(String dateTimeString) {
  try {
    // Parse the string into a DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Define the desired date format
    final dateFormat = DateFormat('MM/yy');

    // Format the DateTime object using the defined format
    return dateFormat.format(dateTime);
  } catch (e) {
    "$e".log();
    "error formatting passed date: $dateTimeString".log();
    return '';
  }
}

String formatNumberWithCommas(String numberString) {
  try {
    final number = int.tryParse(numberString) ?? 0;
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  } catch (e) {
    "$e".log();
    "error formatting passed Number String: $numberString".log();
    return '';
  }
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
        backgroundColor: const Color(0xFF4E4E55),
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

showCompletedWithdrawAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required Function onConfirm,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF4E4E55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        title: Center(
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: bg4,
            ),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(
                Icons.check,
                color: fore1,
                size: 25,
              ),
            ),
          ),
        ),
        content: Text(
          title,
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

Future<int?> getInitialScreen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(isShowOnBoardingView);
}
