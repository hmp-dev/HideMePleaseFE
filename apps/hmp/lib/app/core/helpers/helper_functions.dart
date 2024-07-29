import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/wallet_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/pref_keys.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
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

Future<bool> showHmpAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required Function onConfirm,
}) async {
  bool? result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
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
              height: 44,
              text: LocaleKeys.confirm.tr(),
              onPressed: () {
                onConfirm();
              },
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

Future<bool> showBenefitRedeemSuccessAlertDialog({
  required BuildContext context,
  required String title,
  required Function onConfirm,
  required String buttonTitle,
}) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          //backgroundColor: const Color(0xFF4E4E55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: bg4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomImageView(
                  svgPath: "assets/icons/ic_check_tik.svg",
                  width: 20,
                  height: 20,
                ),
                //
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
              height: 44,
              bgColor: bg4,
              text: buttonTitle,
              onPressed: () {
                onConfirm();
              },
            ),
          ],
        ),
      );
    },
  );

  return result ?? false;
}

Future<bool> showBenefitRedeemAgreeTermsAlertDialog({
  required BuildContext context,
  required String title,
  required Function onConfirm,
  required Function onCancel,
}) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          //backgroundColor: const Color(0xFF4E4E55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Text(
            title,
            textAlign: TextAlign.center,
            style: fontBodyMdSize15(),
          ),
          //content: const SizedBox.shrink(),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: HMPCustomButton(
                    height: 44,
                    bgColor: bg4,
                    text: LocaleKeys.confirm.tr(),
                    onPressed: () => onConfirm(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: HMPCustomButton(
                    height: 44,
                    bgColor: fore4,
                    text: LocaleKeys.cancel.tr(),
                    onPressed: () => onCancel(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  return result ?? false;
}

Future<bool> showCompletedWithdrawAlertDialog({
  required BuildContext context,
  required String title,
  required Function onConfirm,
}) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          // backgroundColor: const Color(0xFF4E4E55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: bg4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomImageView(
                  svgPath: "assets/icons/ic_check_tik.svg",
                  width: 20,
                  height: 20,
                ),
                //
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
              height: 44,
              text: LocaleKeys.confirm.tr(),
              onPressed: () {
                onConfirm();
              },
            ),
          ],
        ),
      );
    },
  );

  return result ?? false;
}

Future<bool> showWithdrawConfirmationAlertDialog({
  required BuildContext context,
  required String title,
  required Function onConfirm,
  required Function onCancel,
}) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          // backgroundColor: const Color(0xFF4E4E55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: bg4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomImageView(
                  svgPath: "assets/icons/ic_info_icon.svg",
                  width: 20,
                  height: 20,
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
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: RoundedButtonWithBorder(
                bgColor: const Color(0xFF4E4E55),
                text: LocaleKeys.cancel.tr(),
                onPressed: () {
                  onCancel();
                },
              ),
            )
          ],
        ),
      );
    },
  );

  return result ?? false;
}

Future<bool> showEnableLocationAlertDialog({
  required BuildContext context,
  required String title,
  required Function onConfirm,
  required Function onCancel,
}) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          // backgroundColor: const Color(0xFF4E4E55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: bg4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomImageView(
                  svgPath: "assets/icons/ic_info_icon.svg",
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Use min to fit content
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: fontBodySm(),
              ),
              const SizedBox(height: 20), // Spacing between text and buttons
              HMPCustomButton(
                bgColor: bg4,
                text: LocaleKeys.confirm.tr(),
                onPressed: () {
                  onConfirm();
                  Navigator.of(context)
                      .pop(true); // Close the dialog and return true
                },
              ),
              const SizedBox(height: 10), // Spacing between buttons
              RoundedButtonWithBorder(
                bgColor: const Color(0xFF4E4E55),
                text: LocaleKeys.cancel.tr(),
                onPressed: () {
                  onCancel();
                },
              ),
            ],
          ),
          actions: const <Widget>[],
        ),
      );
    },
  );

  return result ?? false;
}

String getLocalCategoryName(String categoryName) {
  switch (categoryName) {
    case 'ENTIRE':
      return LocaleKeys.entire.tr();
    case 'WALKERHILL':
      return LocaleKeys.walkerhill.tr();
    case "PUB":
      return LocaleKeys.pub.tr();
    case "CAFE":
      return LocaleKeys.cafe.tr();
    case "COWORKING":
      return LocaleKeys.coworking.tr();
    case "MUSIC":
      return LocaleKeys.music.tr();
    case "MEAL":
      return LocaleKeys.meal.tr();
    default:
      throw Exception('Unhandled category');
  }
}

Future<int?> getInitialScreen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(isShowOnBoardingView);
}

List<BenefitEntity> moveBenefitEntityToFirst(
    List<BenefitEntity> nftBenefitList, String id) {
  List<BenefitEntity> sorted = nftBenefitList;
  // Find the index of the entity with the specified id
  final index = sorted.indexWhere((benefit) => benefit.id == id);

  // Check if the entity exists in the list
  if (index != -1) {
    // Remove the entity from its current position
    final benefitEntity = sorted.removeAt(index);

    // Insert the entity at the first index
    sorted.insert(0, benefitEntity);
  }

  return sorted;
}

String removeCurlyBraces(String input) {
  return input.replaceAll(RegExp(r'[{}]'), '');
}

String checkTimeDifference(String dateString) {
  // Parse the input date string to a DateTime object
  DateTime parsedDate = DateTime.parse(dateString);
  DateTime currentDate = DateTime.now();

  // Calculate the difference between current time and the parsed date
  Duration difference = currentDate.difference(parsedDate);

  if (difference.inMinutes < 60) {
    return "${difference.inMinutes} ${LocaleKeys.minutesAgo.tr()}";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} ${LocaleKeys.hoursAgo.tr()}";
  } else {
    int days = difference.inDays;
    int hours = difference.inHours % 24;

    if (days == 1) {
      return "$days ${LocaleKeys.day.tr()}";
    }

    final dayString = (days == 1)
        ? "$days ${LocaleKeys.day.tr()}"
        : "$days ${LocaleKeys.days.tr()}";

    return "$days $dayString and $hours ${LocaleKeys.hoursAgo.tr()}";
  }
}

// Check if User is Near to Space

bool isUserInSpace(
    double userLat, double userLng, double spaceLat, double spaceLng,
    {double threshold = 10.0}) {
  double distance =
      calculateDistanceInMeters(userLat, userLng, spaceLat, spaceLng);
  return distance < threshold;
}

double calculateDistanceInMeters(
    double startLat, double startLng, double endLat, double endLng) {
  const earthRadiusInMeters = 6371000; // Radius of the Earth in meters

  final dLat = _degreesToRadians(endLat - startLat);
  final dLng = _degreesToRadians(endLng - startLng);

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degreesToRadians(startLat)) *
          math.cos(_degreesToRadians(endLat)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);

  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusInMeters * c;
}

double _degreesToRadians(double degrees) {
  return degrees * math.pi / 180;
}

//===================>

Future<void> logErrorWithDeviceInfo(dynamic error, StackTrace stackTrace,
    {String? reason}) async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  String deviceModel = '';
  String osVersion = '';

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    deviceModel = androidInfo.model;
    osVersion = 'Android ${androidInfo.version.release}';
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    deviceModel = iosInfo.utsname.machine;
    osVersion = 'iOS ${iosInfo.systemVersion}';
  }

  await FirebaseCrashlytics.instance.setCustomKey('device_model', deviceModel);
  await FirebaseCrashlytics.instance.setCustomKey('os_version', osVersion);

  await FirebaseCrashlytics.instance.recordError(
    error,
    stackTrace,
    reason: reason,
  );
}

List<BenefitEntity> removeDuplicates(List<BenefitEntity> benefitList) {
  final seenIds = <String>{}; // Create a Set to track seen IDs
  final uniqueBenefits = <BenefitEntity>[]; // List to store unique items

  for (var benefit in benefitList) {
    if (!seenIds.contains(benefit.id)) {
      seenIds.add(benefit.id); // Add the ID to the Set
      uniqueBenefits.add(benefit); // Add the BenefitEntity to the unique list
    }
  }

  return uniqueBenefits;
}
