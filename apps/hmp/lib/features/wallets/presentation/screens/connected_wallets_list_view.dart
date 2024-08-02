// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/connected_wallet_item_widget.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// A screen that displays a list of connected wallets.
///
/// This screen is displayed as a modal bottom sheet and allows the user to
/// view and manage their connected wallets.
class ConnectedWalletsListScreen extends StatefulWidget {
  /// Creates a [ConnectedWalletsListScreen].
  ///
  /// The [key] parameter is used to uniquely identify this widget.
  const ConnectedWalletsListScreen({super.key});

  /// Shows the [ConnectedWalletsListScreen] as a modal bottom sheet.
  ///
  /// The [context] parameter is used to build the modal bottom sheet.
  ///
  /// This method is asynchronous and returns a [Future] that completes when the
  /// modal bottom sheet is dismissed.
  static Future<dynamic> show(BuildContext context) async {
    // Show the modal bottom sheet with a backdrop filter to blur the background.
    await showModalBottomSheet(
      useSafeArea: false,
      isScrollControlled: true,
      context: context,
      builder: (_) => BackdropFilter(
        // Apply a blur effect to the background.
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        // Display the [ConnectedWalletsListScreen].
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
    // Builds the screen widget.
    //
    // The screen displays a list of connected wallets. It uses the `BlocConsumer`
    // widget to listen for changes in the `WalletsCubit` state and update the UI.
    // It also uses the `BackdropFilter` widget to apply a blur effect to the background.
    return BlocConsumer<WalletsCubit, WalletsState>(
      // The `BlocConsumer` widget takes the `WalletsCubit` instance and a `builder`
      // function to build the UI based on the state changes.
      bloc: getIt<WalletsCubit>(),
      // The `listenWhen` function is used to specify the condition to trigger the
      // `listener` function. In this case, it triggers when the length of `connectedWallets`
      // changes.
      listenWhen: (previous, current) =>
          previous.connectedWallets.length != current.connectedWallets.length,
      // The `listener` function is called when the condition specified in `listenWhen`
      // is met. It resets the dependency injection container, configures the dependencies,
      // and navigates to the start up screen.
      listener: (context, state) async {
        await getIt.reset();
        await configureDependencies();
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.startUpScreen, (route) => false);
      },
      // The `builder` function builds the UI based on the current state of the `WalletsCubit`.
      // It returns a `Container` widget with a `SingleChildScrollView` and a `Stack` widget.
      // The `Container` sets the height of the screen based on the length of `connectedWallets`.
      // The `Stack` contains a `SizedBox` widget with a `SingleChildScrollView` and a `ListView.builder`
      // widget to display the list of connected wallets.
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
                                    // Displays the title of the screen.
                                    Text(
                                      LocaleKeys.walletConnectionStatus.tr(),
                                      style: fontTitle05Bold(),
                                    ),
                                    // Displays a close icon to dismiss the screen.
                                    CustomImageView(
                                      onTap: () => Navigator.pop(context),
                                      svgPath: "assets/icons/ic_close.svg",
                                    )
                                  ],
                                ),
                              ),
                              // Displays a list of connected wallets.
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
