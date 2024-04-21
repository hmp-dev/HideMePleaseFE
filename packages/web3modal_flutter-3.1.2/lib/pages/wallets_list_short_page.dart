import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/pages/connect_wallet_page.dart';
import 'package:web3modal_flutter/pages/wallets_list_long_page.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/all_wallets_item.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_item_chip.dart';
import 'package:web3modal_flutter/widgets/lists/wallets_list.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';
import 'package:web3modal_flutter/widgets/value_listenable_builders/explorer_service_items_listener.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';

class WalletsListShortPage extends StatefulWidget {
  const WalletsListShortPage()
      : super(key: KeyConstants.walletListShortPageKey);

  @override
  State<WalletsListShortPage> createState() => _WalletsListShortPageState();
}

class _WalletsListShortPageState extends State<WalletsListShortPage> {
  @override
  Widget build(BuildContext context) {
    final service = Web3ModalProvider.of(context).service;
    final isPortrait = ResponsiveData.isPortrait(context);
    double maxHeight = isPortrait
        ? (kListItemHeight * 8.3)
        : ResponsiveData.maxHeightOf(context);
    return Web3ModalNavbar(
      title: '지갑 연결',
      // leftAction:NavbarActionButton(
      //   asset: 'assets/icons/help.svg',
      //   action: () {
      //     widgetStack.instance.push(const AboutWallets());
      //   },
      // ),
      safeAreaLeft: true,
      safeAreaRight: true,
      body: ExplorerServiceItemsListener(
        builder: (context, initialised, items, _) {
          debugPrint(
              'items.length: =========================> ${items.length}');

          if (!initialised || items.isEmpty) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: const WalletsList(
                isLoading: true,
                itemList: [],
              ),
            );
          }
          final itemsCount = min(kShortWalletListCount, items.length);

          debugPrint(
              'explorerService.instance.totalListings ${explorerService.instance.totalListings}');

          final itemsToShow = getWalletsListToShow(items, itemsCount);

          if (itemsCount < kShortWalletListCount && isPortrait) {
            maxHeight = kListItemHeight * (itemsCount + 1);
          }
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: WalletsList(
              onTapWallet: (data) {
                service.selectWallet(data);
                widgetStack.instance.push(const ConnectWalletPage());
              },
              itemList: itemsToShow.toList(),
              bottomItems: 

                  // This conditional statement checks if the number of items to show is less than `kShortWalletListCount`.
                  // If it is, it returns an empty list, meaning no 'All Wallets' item will be shown.
                  // If not, it creates an `AllWalletsItem` widget with a trailing `WalletItemChip` widget.
                  // The `WalletItemChip` widget displays the number of total listings in the `explorerService`.
                  // When this widget is tapped, it pushes a `WalletsListLongPage` to the navigation stack.
                  (itemsCount < kShortWalletListCount)
                      ? [] // If the number of items to show is less than `kShortWalletListCount`, return an empty list
                      : [
                          AllWalletsItem(
                            // Otherwise, create an `AllWalletsItem` widget
                            trailing: ValueListenableBuilder<int>(
                              valueListenable: explorerService.instance
                                  .totalListings, // The number of listings is obtained from `explorerService`
                              builder: (context, value, _) {
                                // The builder is called whenever the number of listings changes
                                return WalletItemChip(
                                  // A `WalletItemChip` widget is created to display the number of listings
                                  value: value.lazyCount,
                                  textStyle: fontR__MW3M(
                                      14), // The `value` parameter is the current number of listings
                                );
                              },
                            ),
                            onTap: () {
                              widgetStack
                                  .instance // When the widget is tapped, push a `WalletsListLongPage` to the navigation stack
                                  .push(const WalletsListLongPage());
                            },
                          ),
                        ],
            ),
          );
        },
      ),
    );
  }

  Iterable<GridItem<W3MWalletInfo>> getWalletsListToShow(
      List<GridItem<W3MWalletInfo>> items, int itemsCount) {
    debugPrint('items.length: ==> ${items.length}');

    List<GridItem<W3MWalletInfo>> itemsToShow = [];

    for (int i = 0; i < items.length; i++) {
      String lowercaseTitle = items[i].title.toLowerCase();

      if (lowercaseTitle == 'metamask' ||
          lowercaseTitle == 'klip' ||
          lowercaseTitle == 'phantom' ||
          lowercaseTitle == 'walletconnect' ||
          lowercaseTitle == 'wemixwallet') {
        itemsToShow.add(items[i]);
      }

      debugPrint(items[i].title);
    }

    final itemsToAdd = items.getRange(0, 4);

    for (var item in itemsToAdd) {
      if (item.title.toLowerCase() != 'metamask') {
        itemsToShow.add(item);
      }
    }
    return itemsToShow;
  }
}

extension on int {
  String get lazyCount {
    if (this <= 10) return toString();
    return '${toString().substring(0, toString().length - 1)}0+';
  }
}
