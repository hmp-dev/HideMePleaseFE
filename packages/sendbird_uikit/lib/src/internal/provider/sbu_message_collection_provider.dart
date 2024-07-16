// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class SBUMessageCollectionProvider with ChangeNotifier {
  static int currentCollectionNo = 1;

  final Map<int, MessageCollection> _collectionMap = {};
  final Map<int, bool?> _scrollToEndMap = {};
  final Map<int, BaseMessage?> _editingMessageMap = {};
  final Map<int, bool?> _deletedChannelMap = {};

  SBUMessageCollectionProvider._();

  static final SBUMessageCollectionProvider _provider =
      SBUMessageCollectionProvider._();

  factory SBUMessageCollectionProvider() => _provider;

  int add({
    required GroupChannel channel,
    MessageListParams? params,
  }) {
    final collectionNo = currentCollectionNo++;
    final collection = MessageCollection(
      channel: channel,
      params: (params ?? MessageListParams())
        ..reverse = true, // Supported reverse value is only true.
      handler: _MyMessageCollectionHandler(this, channel.channelUrl),
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

  MessageCollection? getCollection(int collectionNo) {
    return _collectionMap[collectionNo];
  }

  void _refresh([String? channelUrl, CollectionEventSource? eventSource]) {
    _checkScrollToEnd(channelUrl, eventSource);

    notifyListeners();
  }

  void _markAsRead(String channelUrl, MessageContext context) {
    final collectionNoList = _getCollectionNoList(channelUrl);
    if (collectionNoList.isNotEmpty) {
      runZonedGuarded(() {
        _collectionMap[collectionNoList.first]?.markAsRead(context);
      }, (error, stack) {
        // TODO: Check error
      });
    }
  }

  void _restart(String channelUrl) {
    for (final collectionNo in _getCollectionNoList(channelUrl)) {
      final collection = _collectionMap[collectionNo];
      if (collection != null) {
        remove(collectionNo);
        add(channel: collection.channel, params: collection.params);
      }
    }
  }

  List<int> _getCollectionNoList(String channelUrl) {
    final List<int> result = [];
    for (final collectionNo in _collectionMap.keys) {
      final collection = _collectionMap[collectionNo];
      if (channelUrl == collection?.channel.channelUrl) {
        result.add(collectionNo);
      }
    }
    return result;
  }

  // _scrollToEndMap
  void _checkScrollToEnd(
    String? channelUrl,
    CollectionEventSource? eventSource,
  ) {
    if (channelUrl != null && eventSource != null) {
      if (eventSource == CollectionEventSource.localMessagePendingCreated ||
          eventSource == CollectionEventSource.localMessageResendStarted ||
          eventSource == CollectionEventSource.eventMessageReceived) {
        for (final collectionNo in _getCollectionNoList(channelUrl)) {
          _scrollToEndMap[collectionNo] = true;
        }
      }
    }
  }

  bool isScrollToEnd(int collectionNo) {
    final result = _scrollToEndMap[collectionNo];
    return (result != null && result);
  }

  void resetScrollToEnd(int collectionNo) {
    _scrollToEndMap.remove(collectionNo);
  }

  // _editingMessageMap
  void setEditingMessage(int collectionNo, BaseMessage? message) {
    _editingMessageMap[collectionNo] = message;
    _refresh();
  }

  BaseMessage? getEditingMessage(int collectionNo) {
    return _editingMessageMap[collectionNo];
  }

  void resetEditingMessage(int collectionNo) {
    _editingMessageMap.remove(collectionNo);
    _refresh();
  }

  // _deletedChannelMap
  void _setDeletedChannel(String channelUrl) {
    for (final collectionNo in _getCollectionNoList(channelUrl)) {
      _deletedChannelMap[collectionNo] = true;
    }
    _refresh();
  }

  bool isDeletedChannel(int collectionNo) {
    final result = _deletedChannelMap[collectionNo];
    return (result != null && result);
  }

  void resetDeletedChannel(int collectionNo) {
    _deletedChannelMap.remove(collectionNo);
  }

  Future<bool> _hasFailedMessages(String channelUrl) async {
    final collectionNoList = _getCollectionNoList(channelUrl);
    if (collectionNoList.isNotEmpty) {
      final failedMessages =
          await _collectionMap[collectionNoList.first]?.getFailedMessages();
      if (failedMessages != null && failedMessages.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}

class _MyMessageCollectionHandler extends MessageCollectionHandler {
  final SBUMessageCollectionProvider _provider;
  final String _channelUrl;

  _MyMessageCollectionHandler(this._provider, this._channelUrl);

  @override
  void onMessagesAdded(MessageContext context, GroupChannel channel,
      List<BaseMessage> messages) async {
    _provider._markAsRead(channel.channelUrl, context);

    //+ Anti-flicker
    if (context.collectionEventSource ==
            CollectionEventSource.messageCacheInitialize &&
        context.sendingStatus == SendingStatus.succeeded) {
      if (await _provider._hasFailedMessages(channel.channelUrl)) {
        return;
      }
    }
    //- Anti-flicker

    _provider._refresh(channel.channelUrl, context.collectionEventSource);
  }

  @override
  void onMessagesUpdated(MessageContext context, GroupChannel channel,
      List<BaseMessage> messages) {
    _provider._refresh(channel.channelUrl, context.collectionEventSource);
  }

  @override
  void onMessagesDeleted(MessageContext context, GroupChannel channel,
      List<BaseMessage> messages) {
    _provider._refresh(channel.channelUrl, context.collectionEventSource);
  }

  @override
  void onChannelUpdated(GroupChannelContext context, GroupChannel channel) {
    _provider._refresh(channel.channelUrl, context.collectionEventSource);
  }

  @override
  void onChannelDeleted(GroupChannelContext context, String deletedChannelUrl) {
    _provider._setDeletedChannel(deletedChannelUrl);
  }

  @override
  void onHugeGapDetected() {
    _provider._restart(_channelUrl);
  }
}
