import 'package:get_it/get_it.dart';
import 'package:reown_appkit/modal/constants/string_constants.dart';
import 'package:reown_appkit/modal/services/coinbase_service/coinbase_service.dart';
import 'package:reown_appkit/modal/services/coinbase_service/models/coinbase_data.dart';
import 'package:reown_appkit/modal/services/magic_service/i_magic_service.dart';
import 'package:reown_appkit/modal/services/magic_service/models/magic_data.dart';
import 'package:reown_appkit/reown_appkit.dart';

// TODO ReownAppKitModal this should be hidden
enum ReownAppKitModalConnector {
  wc,
  coinbase,
  magic,
  none;

  bool get isWC => this == ReownAppKitModalConnector.wc;
  bool get isCoinbase => this == ReownAppKitModalConnector.coinbase;
  bool get isMagic => this == ReownAppKitModalConnector.magic;
  bool get noSession => this == ReownAppKitModalConnector.none;
}

/// Session object of the modal when connected
class ReownAppKitModalSession {
  SessionData? _sessionData;
  CoinbaseData? _coinbaseData;
  MagicData? _magicData;
  SIWESession? _siweSession;

  ReownAppKitModalSession({
    SessionData? sessionData,
    CoinbaseData? coinbaseData,
    MagicData? magicData,
    SIWESession? siweSession,
  })  : _sessionData = sessionData,
        _coinbaseData = coinbaseData,
        _magicData = magicData,
        _siweSession = siweSession;

  /// USED TO READ THE SESSION FROM LOCAL STORAGE
  factory ReownAppKitModalSession.fromMap(Map<String, dynamic> map) {
    final sessionDataString = map['sessionData'];
    final coinbaseDataString = map['coinbaseData'];
    final magicDataString = map['magicData'];
    final siweSession = map['siweSession'];
    return ReownAppKitModalSession(
      sessionData: sessionDataString != null
          ? SessionData.fromJson(sessionDataString)
          : null,
      coinbaseData: coinbaseDataString != null
          ? CoinbaseData.fromJson(coinbaseDataString)
          : null,
      magicData:
          magicDataString != null ? MagicData.fromJson(magicDataString) : null,
      siweSession:
          siweSession != null ? SIWESession.fromJson(siweSession) : null,
    );
  }

  ReownAppKitModalSession copyWith({
    SessionData? sessionData,
    CoinbaseData? coinbaseData,
    MagicData? magicData,
    SIWESession? siweSession,
  }) {
    return ReownAppKitModalSession(
      sessionData: sessionData ?? _sessionData,
      coinbaseData: coinbaseData ?? _coinbaseData,
      magicData: magicData ?? _magicData,
      siweSession: siweSession ?? _siweSession,
    );
  }

  /// Indicates the connected service
  ReownAppKitModalConnector get sessionService {
    if (_sessionData != null) {
      return ReownAppKitModalConnector.wc;
    }
    if (_coinbaseData != null) {
      return ReownAppKitModalConnector.coinbase;
    }
    if (_magicData != null) {
      // TODO rename to ReownAppKitModalConnector.socials
      return ReownAppKitModalConnector.magic;
    }

    return ReownAppKitModalConnector.none;
  }

  bool hasSwitchMethod() {
    if (sessionService.noSession) {
      return false;
    }
    if (sessionService.isCoinbase) {
      return true;
    }
    if (sessionService.isMagic) {
      return true;
    }

    final nsMethods = getApprovedMethods() ?? [];
    final supportsAddChain = nsMethods.contains(
      MethodsConstants.walletAddEthChain,
    );
    return supportsAddChain;
  }

  /// Get the approved methods by the connected peer
  List<String>? getApprovedMethods() {
    if (sessionService.noSession) {
      return null;
    }
    if (sessionService.isCoinbase) {
      return CoinbaseService.supportedMethods;
    }
    if (sessionService.isMagic) {
      return GetIt.I<IMagicService>().supportedMethods;
    }

    final sessionNamespaces = _sessionData!.namespaces;
    final namespace = sessionNamespaces[CoreConstants.namespace];
    final methodsList = namespace?.methods.toSet().toList();
    return methodsList ?? [];
  }

  /// Get the approved events by the connected peer
  List<String>? getApprovedEvents() {
    if (sessionService.noSession) {
      return null;
    }
    if (sessionService.isCoinbase) {
      return [];
    }
    if (sessionService.isMagic) {
      return [];
    }

    final sessionNamespaces = _sessionData!.namespaces;
    final namespace = sessionNamespaces[CoreConstants.namespace];
    final eventsList = namespace?.events.toSet().toList();
    return eventsList ?? [];
  }

  /// Get the approved chains by the connected peer
  List<String>? getApprovedChains() {
    if (sessionService.noSession) {
      return null;
    }
    // We can not know which chains are approved from Coinbase or Magic
    if (!sessionService.isWC) {
      return [chainId];
    }

    final accounts = getAccounts() ?? [];
    final approvedChains = NamespaceUtils.getChainsFromAccounts(accounts);
    return approvedChains;
  }

  /// Get the approved accounts by the connected peer
  List<String>? getAccounts() {
    if (sessionService.noSession) {
      return null;
    }
    if (sessionService.isCoinbase) {
      return ['${CoreConstants.namespace}:$chainId:$address'];
    }
    if (sessionService.isMagic) {
      return ['${CoreConstants.namespace}:$chainId:$address'];
    }

    final sessionNamespaces = _sessionData!.namespaces;
    return sessionNamespaces[CoreConstants.namespace]?.accounts ?? [];
  }

  Redirect? getSessionRedirect() {
    if (sessionService.noSession) {
      return null;
    }

    return _sessionData?.peer.metadata.redirect;
  }

  // toJson() would convert ReownAppKitModalSession to a SessionData kind of map
  // no matter if Coinbase Wallet or Email Wallet is connected
  Map<String, dynamic> toJson() {
    final sessionData = SessionData(
      topic: topic ?? '',
      pairingTopic: pairingTopic ?? '',
      relay: relay ?? Relay(ReownConstants.RELAYER_DEFAULT_PROTOCOL),
      expiry: expiry ?? 0,
      acknowledged: acknowledged ?? false,
      controller: controller ?? '',
      namespaces: _namespaces() ?? {},
      self: self!,
      peer: peer!,
      requiredNamespaces: _sessionData?.requiredNamespaces,
      optionalNamespaces: _sessionData?.optionalNamespaces,
      sessionProperties: _sessionData?.sessionProperties,
      authentication: _sessionData?.authentication,
      transportType: _sessionData?.transportType ?? TransportType.relay,
    );
    return sessionData.toJson();
  }
}

extension ReownAppKitModalSessionExtension on ReownAppKitModalSession {
  String? get topic => _sessionData?.topic;
  String? get pairingTopic => _sessionData?.pairingTopic;
  Relay? get relay => _sessionData?.relay;
  int? get expiry => _sessionData?.expiry;
  bool? get acknowledged => _sessionData?.acknowledged;
  String? get controller => _sessionData?.controller;
  Map<String, Namespace>? get namespaces => _sessionData?.namespaces;

  ConnectionMetadata? get self {
    if (sessionService.isCoinbase) {
      return _coinbaseData?.self;
    }
    if (sessionService.isMagic) {
      return _magicData?.self ??
          ConnectionMetadata(
            publicKey: '',
            metadata: PairingMetadata(
              name: 'Email Wallet',
              description: '',
              url: '',
              icons: [],
            ),
          );
    }
    return _sessionData?.self;
  }

  ConnectionMetadata? get peer {
    if (sessionService.isCoinbase) {
      return _coinbaseData?.peer;
    }
    if (sessionService.isMagic) {
      return _magicData?.peer ??
          ConnectionMetadata(
            publicKey: '',
            metadata: PairingMetadata(
              name: 'Email Wallet',
              description: '',
              url: '',
              icons: [],
            ),
          );
    }
    return _sessionData?.peer;
  }

  //
  String get email => _magicData?.email ?? '';

  String get userName => _magicData?.userName ?? '';

  AppKitSocialOption? get socialProvider => _magicData?.provider;

  //
  String? get address {
    if (sessionService.noSession) {
      return null;
    }
    if (sessionService.isCoinbase) {
      return _coinbaseData!.address;
    }
    if (sessionService.isMagic) {
      return _magicData!.address;
    }
    final namespace = namespaces?[CoreConstants.namespace];
    final accounts = namespace?.accounts ?? [];
    if (accounts.isNotEmpty) {
      return NamespaceUtils.getAccount(accounts.first);
    }
    return null;
  }

  String get chainId {
    if (sessionService.isWC) {
      final chainIds = NamespaceUtils.getChainIdsFromNamespaces(
        namespaces: namespaces ?? {},
      );
      if (chainIds.isNotEmpty) {
        return (chainIds..sort()).first.split(':')[1];
      }
    }
    if (sessionService.isCoinbase) {
      return _coinbaseData!.chainId.toString();
    }
    if (sessionService.isMagic) {
      return _magicData!.chainId.toString();
    }
    return '1';
  }

  String? get connectedWalletName {
    if (sessionService.isCoinbase) {
      return CoinbaseService.defaultWalletData.listing.name;
    }
    if (sessionService.isWC) {
      return peer?.metadata.name;
    }
    return null;
  }

  Map<String, dynamic> toRawJson() {
    return {
      ...(_sessionData?.toJson() ?? {}),
      ...(_coinbaseData?.toJson() ?? {}),
      ...(_magicData?.toJson() ?? {}),
    };
  }

  Map<String, Namespace>? _namespaces() {
    if (sessionService.isCoinbase) {
      return {
        CoreConstants.namespace: Namespace(
          chains: ['${CoreConstants.namespace}:$chainId'],
          accounts: ['${CoreConstants.namespace}:$chainId:$address'],
          methods: [...CoinbaseService.supportedMethods],
          events: [],
        ),
      };
    }
    if (sessionService.isMagic) {
      return {
        CoreConstants.namespace: Namespace(
          chains: ['${CoreConstants.namespace}:$chainId'],
          accounts: ['${CoreConstants.namespace}:$chainId:$address'],
          methods: [...GetIt.I<IMagicService>().supportedMethods],
          events: [],
        ),
      };
    }
    return namespaces;
  }

  /// USED TO STORE THE SESSION IN LOCAL STORAGE
  Map<String, dynamic> toMap() {
    return {
      if (_sessionData != null) 'sessionData': _sessionData!.toJson(),
      if (_coinbaseData != null) 'coinbaseData': _coinbaseData?.toJson(),
      if (_magicData != null) 'magicData': _magicData?.toJson(),
      if (_siweSession != null) 'siweSession': _siweSession?.toJson(),
    };
  }
}
