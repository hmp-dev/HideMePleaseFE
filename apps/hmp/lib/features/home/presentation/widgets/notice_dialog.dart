import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../generated/locale_keys.g.dart';

class NoticeDialog extends StatefulWidget {
  const NoticeDialog({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  static show({
    required BuildContext context,
    required String imageUrl,
  }) {
    showDialog(
      useSafeArea: false,
      barrierColor: Colors.black.withOpacity(0.8),
      context: context,
      builder: (_) => NoticeDialog(
        imageUrl: imageUrl,
      ),
    );
  }

  @override
  State<NoticeDialog> createState() => _NoticeDialogState();
}

class _NoticeDialogState extends State<NoticeDialog>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  bool dontShowCheckBox = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(
                  top: 16, bottom: 24, left: 16, right: 16),
              margin: const EdgeInsets.only(bottom: 60),
              width: MediaQuery.of(context).size.width * 0.90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CustomImageView(
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width * 0.90,
                    height: MediaQuery.of(context).size.height * 0.60,
                    url: widget
                        .imageUrl, //"assets/images/temp-banner-alert-image.png",
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          dontShowCheckBox = !dontShowCheckBox;
                        });

                        // setDoNotShowForSevenDaya value in local storage
                        setDoNotShowForSevenDays();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            side: const BorderSide(color: black500),
                            activeColor: hmpBlue,
                            checkColor: white,
                            value: dontShowCheckBox,
                            onChanged: (bool? value) {
                              setState(() {
                                dontShowCheckBox = value ?? false;
                              });

                              setDoNotShowForSevenDays();
                            },
                          ),
                          Text(LocaleKeys.dontShowMeForAWeek.tr(),
                              style: fontCompactSm(color: black500)),
                        ],
                      ),
                    ),
                  ),
                  HMPCustomButton(
                    bgColor: hmpBlue,
                    height: 44,
                    text: LocaleKeys.confirm.tr(),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  setDoNotShowForSevenDays() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the current date and save it in milliseconds since epoch
    DateTime now = DateTime.now();
    prefs.setInt('sevenDaySkipDate', now.millisecondsSinceEpoch);
  }
}
