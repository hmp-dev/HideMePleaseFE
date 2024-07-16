// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class SBUGroupChannelCollectionProvider with ChangeNotifier {
  static int currentCollectionNo = 1;

  final Map<int, GroupChannelCollection> _collectionMap = {};

  SBUGroupChannelCollectionProvider._();

  static final SBUGroupChannelCollectionProvider _provider =
      SBUGroupChannelCollectionProvider._();

  factory SBUGroupChannelCollectionProvider() => _provider;

  int add({
    GroupChannelListQuery? query,
  }) {
    final collectionNo = currentCollectionNo++;
    final collection = GroupChannelCollection(
      query: query ?? GroupChannelListQuery(),
      handler: _MyGroupChannelCollectionHandler(this),
    );
    _collectionMap[collectionNo] = collection;
    return collectionNo;
  }

  void remove(int collectionNo) {
    final collection = _collectionMap[collectionNo];
    if (collection != null) {
      collection.dispose();
      _collectionMap.remove(collectionNo);
    }
  }

  GroupChannelCollection? getCollection(int collectionNo) {
    return _collectionMap[collectionNo];
  }

  void _refresh() {
    notifyListeners();
  }
}

class _MyGroupChannelCollectionHandler extends GroupChannelCollectionHandler {
  final SBUGroupChannelCollectionProvider _provider;

  _MyGroupChannelCollectionHandler(this._provider);

  @override
  void onChannelsAdded(
      GroupChannelContext context, List<GroupChannel> channels) {
    _provider._refresh();
  }

  @override
  void onChannelsUpdated(
      GroupChannelContext context, List<GroupChannel> channels) {
    _provider._refresh();
  }

  @override
  void onChannelsDeleted(
      GroupChannelContext context, List<String> deletedChannelUrls) {
    _provider._refresh();
  }
}
