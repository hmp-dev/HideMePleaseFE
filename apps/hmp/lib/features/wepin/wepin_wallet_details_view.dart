// class WepinWalletConnectLisTile extends StatefulWidget {

// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class WepinWalletDetailsView extends StatefulWidget {
  /// Creates a [WepinWalletDetailsView].
  ///
  /// The [onConnectWallet] callback is called when the user taps the
  /// connect wallet button.
  const WepinWalletDetailsView({
    super.key,
  });

  @override
  State<WepinWalletDetailsView> createState() => _WepinWalletDetailsViewState();
}

class _WepinWalletDetailsViewState extends State<WepinWalletDetailsView> {
  @override
  void initState() {
    super.initState();
    getIt<WepinCubit>().openWepinWidget(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Platform.isIOS
              ? MediaQuery.of(context).size.height - 150
              : MediaQuery.of(context).size.height - 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              Text(
                LocaleKeys.access_wepin_wallet.tr(),
                textAlign: TextAlign.center,
                style: fontTitle03Bold(),
              ),
              const VerticalSpace(70),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 48, // 70% of original width
                        height: 48, // 70% of original height
                        child: CustomImageView(
                          imagePath: "assets/images/launcher-icon.png",
                          radius: BorderRadius.circular(4),
                          width: 48, // Reduced width
                          height: 48,
                          fit: BoxFit.contain, // Reduced height
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Icon(
                          Icons.more_horiz,
                          size: 30,
                          color: fore2,
                        ),
                      ),
                      SizedBox(
                        width: 48, // 70% of original width
                        height: 48, // 70% of original height
                        child: CustomImageView(
                          imagePath: "assets/images/wepin_logo_dark.png",
                          width: 48, // Reduced width
                          height: 48,
                          fit: BoxFit.contain, // Reduced height
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const VerticalSpace(70),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          "Powered by",
                          style: fontBodyXsBold(color: fore2),
                        ),
                      ),
                      CustomImageView(
                        svgPath: "assets/images/wepin_white_logo.svg",
                        color: fore2,
                        // Reduced height
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Container(
              //   margin: const EdgeInsets.symmetric(vertical: 8.0),
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: HMPCustomButton(
              //     text: "위핀 지갑 연결",
              //     onPressed: () async {
              //       if (wepinSDK != null) {
              //         await wepinSDK!.openWidget(context);
              //       }
              //     },
              //   ),
              // ),
            ],
          ),
        )
      ],
    );
  }
}
