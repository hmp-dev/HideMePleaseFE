import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class CheckinFailDialog extends StatelessWidget {
  const CheckinFailDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 350,
          height: 168,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8FF),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF132E41),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: DefaultImage(
                      path: "assets/icons/icon_cautaion.svg",
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    LocaleKeys.nfc_checkin_error_title.tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                LocaleKeys.nfc_checkin_error_subtitle.tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
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
                      LocaleKeys.got_it_button.tr(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
