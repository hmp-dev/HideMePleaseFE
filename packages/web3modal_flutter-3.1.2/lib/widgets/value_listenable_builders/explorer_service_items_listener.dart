import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/grid_item.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';

/// A widget that listens to changes in the `explorerService`'s initialization
/// and search states, and provides a builder function with the current state.
/// The builder function will receive updates whenever the states change.
///
/// The `builder` function will receive the following parameters:
///  - `context`: The build context of the widget.
///  - `initialised`: A boolean indicating whether `explorerService` is initialized.
///  - `items`: A list of [GridItem]s representing wallets found by `explorerService`.
///  - `searching`: A boolean indicating whether `explorerService` is currently searching for wallets.
///
/// The `listen` parameter, if set to `false`, will disable listening for changes in `explorerService`'s states.
class ExplorerServiceItemsListener extends StatefulWidget {
  // The constructor of the widget.
  //
  // Parameters:
  //   - `key`: The key of the widget.
  //   - `builder`: The builder function that will receive updates of the states.
  //   - `listen`: Whether to listen for changes in the states. Defaults to `true`.
  const ExplorerServiceItemsListener({
    super.key,
    required this.builder,
    this.listen = true,
  });

  // The builder function that will receive updates of the states.
  //
  // Parameters:
  //   - `context`: The build context of the widget.
  //   - `initialised`: A boolean indicating whether `explorerService` is initialized.
  //   - `items`: A list of [GridItem]s representing wallets found by `explorerService`.
  //   - `searching`: A boolean indicating whether `explorerService` is currently searching for wallets.
  final Function(
    BuildContext context,
    bool initialised,
    List<GridItem<W3MWalletInfo>> items,
    bool searching,
  ) builder;

  // Whether to listen for changes in the states.
  // Defaults to `true`.
  final bool listen;

  // Creates the state of the widget.
  //
  // Returns:
  //   An instance of `_ExplorerServiceItemsListenerState`.
  @override
  State<ExplorerServiceItemsListener> createState() =>
      _ExplorerServiceItemsListenerState();
}

class _ExplorerServiceItemsListenerState
    extends State<ExplorerServiceItemsListener> {
  List<GridItem<W3MWalletInfo>> _items = [];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: explorerService.instance.initialized,
      builder: (context, initialised, _) {
        if (!initialised) {
          return widget.builder(context, initialised, [], false);
        }
        return ValueListenableBuilder<bool>(
          valueListenable: explorerService.instance.isSearching,
          builder: (context, searching, _) {
            if (searching) {
              return widget.builder(context, initialised, _items, searching);
            }
            return ValueListenableBuilder<List<W3MWalletInfo>>(
              valueListenable: explorerService.instance.listings,
              builder: (context, items, _) {
                if (widget.listen) {
                  _items = items.toGridItems();
                }
                return widget.builder(context, initialised, _items, false);
              },
            );
          },
        );
      },
    );
  }
}

extension on List<W3MWalletInfo> {
  List<GridItem<W3MWalletInfo>> toGridItems() {
    List<GridItem<W3MWalletInfo>> gridItems = [];
    for (W3MWalletInfo item in this) {
      gridItems.add(
        GridItem<W3MWalletInfo>(
          title: item.listing.name,
          id: item.listing.id,
          image: explorerService.instance.getWalletImageUrl(
            item.listing.imageId,
          ),
          data: item,
        ),
      );
    }
    return gridItems;
  }
}
