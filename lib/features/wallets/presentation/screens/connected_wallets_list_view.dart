import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/connected_wallet_item_widget.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class ConnectedWalletsListScreen extends StatefulWidget {
  const ConnectedWalletsListScreen({super.key});

  static Future<dynamic> show(BuildContext context) async {
    await showModalBottomSheet(
      useSafeArea: false,
      isScrollControlled: true,
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: const ConnectedWalletsListScreen(),
      ),
    );
  }

  @override
  State<ConnectedWalletsListScreen> createState() =>
      _ConnectedWalletsListScreenState();
}

class _ConnectedWalletsListScreenState
    extends State<ConnectedWalletsListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletsCubit, WalletsState>(
      bloc: getIt<WalletsCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          height: state.connectedWallets.length * 78 + 120,
          decoration: const BoxDecoration(
            color: scaffoldBg,
          ),
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: state.isSubmitLoading
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      LocaleKeys.walletConnectionStatus.tr(),
                                      style: fontTitle05Bold(),
                                    ),
                                    CustomImageView(
                                      onTap: () => Navigator.pop(context),
                                      svgPath: "assets/icons/ic_close.svg",
                                    )
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: state.connectedWallets.length,
                                itemBuilder: (context, index) {
                                  return ConnectedWalletItemWidget(
                                    connectedWallet:
                                        state.connectedWallets[index],
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
