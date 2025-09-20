import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MatchingHelpDialog extends StatelessWidget {
  const MatchingHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Content container at the bottom
                Container(
                  margin: const EdgeInsets.only(top: 105), // Half of image height to create overlap
                    width: 370,
                    // Remove fixed height to allow content-based sizing
                    constraints: const BoxConstraints(
                      minHeight: 150, // Adjusted minimum height
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8FF),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF132E41),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 120, bottom: 20, left: 16, right: 16), // Top padding for image overlap
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultImage(
                        path: "assets/icons/icon_matching_head.svg",
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        LocaleKeys.what_is_matching.tr() + '?',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    LocaleKeys.matching_help_desc1.tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    LocaleKeys.matching_help_desc2.tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    LocaleKeys.matching_help_desc3.tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    LocaleKeys.matching_help_desc4.tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultImage(
                        path: "assets/icons/icon_cautaion.svg",
                        width: 15,
                        height: 15,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        LocaleKeys.matching_help_caution.tr(),
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Increased spacing before button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.zero, // Remove padding to make the container fit
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                      minimumSize: const Size(179, 38),
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2CB3FF), Color(0xFF7CD0FF)],
                        ),
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: const Color(0xFF132E41),
                          width: 1,
                        ),
                      ),
                      child: Container(
                        width: 179,
                        height: 38,
                        alignment: Alignment.center,
                        child: Text(
                          LocaleKeys.matching_help_confirm.tr(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                        ], // Close children array
                      ),
                    ),
                  ),
                // Image positioned on top
                Positioned(
                  top: 0,
                  child: DefaultImage(
                    path: "assets/icons/matching_image.png",
                    width: 218,
                    height: 211,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
