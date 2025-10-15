// ignore_for_file: unused_field

import 'package:carousel_slider/carousel_controller.dart' as carousel_slider;
import 'package:flutter/src/material/carousel.dart' as flutter_carousel;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/home/presentation/widgets/connect_wallet_card_widget.dart';
import 'package:mobile/features/home/presentation/widgets/go_to_membership_card_widget.dart';
import 'package:mobile/features/home/presentation/widgets/home_header_widget.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';

class HomeViewBeforeWalletConnectedWithNoFreeNFT extends StatefulWidget {
  const HomeViewBeforeWalletConnectedWithNoFreeNFT({
    super.key,
  });

  @override
  State<HomeViewBeforeWalletConnectedWithNoFreeNFT> createState() =>
      _HomeViewBeforeWalletConnectedWithNoFreeNFTState();
}

class _HomeViewBeforeWalletConnectedWithNoFreeNFTState
    extends State<HomeViewBeforeWalletConnectedWithNoFreeNFT>
    with AutomaticKeepAliveClientMixin {
  final int _currentIndex = 0;
  final int _currentSelectWidgetIndex = 0;
  final String _currentTokenAddress = "";
  final bool _isCurrentIndexIsLat = false;

  final CarouselController _carouselController = CarouselController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(
      covariant HomeViewBeforeWalletConnectedWithNoFreeNFT oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listener: (context, nftState) {},
      builder: (context, nftState) {
        return Column(
          children: [
            BlocBuilder<WalletsCubit, WalletsState>(
              bloc: getIt<WalletsCubit>(),
              builder: (context, walletsState) {
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    HomeHeaderWidget(
                        connectedWallet: walletsState.connectedWallets),
                    const SizedBox(height: 40),
                    (walletsState.connectedWallets.isEmpty)
                        ? const ConnectWalletCardWidget()
                        : const GoToMemberShipCardWidget(),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
