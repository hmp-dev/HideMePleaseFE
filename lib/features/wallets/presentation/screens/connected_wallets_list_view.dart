import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/connected_wallet_item_widget.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/plus_icon_round_button.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class ConnectedWalletsListScreen extends StatefulWidget {
  const ConnectedWalletsListScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConnectedWalletsListScreen(),
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
    return BaseScaffold(
      title: LocaleKeys.linkedWallet.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      suffix: PlusIconRoundButton(
        onTap: () {
          getIt<WalletsCubit>().onConnectWallet(context);
        },
      ),
      body: SafeArea(
        child: BlocConsumer<WalletsCubit, WalletsState>(
          bloc: getIt<WalletsCubit>(),
          listener: (context, state) {},
          builder: (context, state) {
            return Stack(
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
            );
          },
        ),
      ),
    );
  }
}
