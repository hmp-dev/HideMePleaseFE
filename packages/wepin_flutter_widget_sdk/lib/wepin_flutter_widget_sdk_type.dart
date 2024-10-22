import 'package:wepin_flutter_network/wepin_network_types.dart';
export 'package:wepin_flutter_login_lib/type/wepin_flutter_login_lib_type.dart';
export 'package:wepin_flutter_common/wepin_common_type.dart';
export 'package:wepin_flutter_common/wepin_error.dart';

class WepinAccount {
  String address;
  String network;
  String? contract;
  bool? isAA;

  WepinAccount({
    required this.address,
    required this.network,
    this.contract,
    this.isAA,
  });

  factory WepinAccount.fromJson(Map<String, dynamic> json) {
    return WepinAccount(
      address: json['address'],
      network: json['network'],
      contract: json['contract'],
      isAA: json['isAA'],
    );
  }

  // 팩토리 생성자 정의
  factory WepinAccount.fromAppAccount(IAppAccount account) {
    if (account.contract != null && account.accountTokenId != null) {
      return WepinAccount(
        network: account.network,
        address: account.address,
        contract: account.contract,
      );
    } else {
      return WepinAccount(
        network: account.network,
        address: account.address,
      );
    }
  }

  // 팩토리 메서드를 통해 리스트 생성
  static List<WepinAccount> fromAppAccountList(List<IAppAccount> accountList) {
    return accountList.map((account) => WepinAccount.fromAppAccount(account)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'network': network,
      'contract': contract,
      'isAA': isAA,
    };
  }

  @override
  String toString() {
    return 'WepinAccount(address: $address, network: $network, contract: $contract, isAA: $isAA)';
  }
}

class WepinTokenBalanceInfo {
  String contract;
  String symbol;
  String balance;

  WepinTokenBalanceInfo({
    required this.contract,
    required this.symbol,
    required this.balance,
  });

  factory WepinTokenBalanceInfo.fromJson(Map<String, dynamic> json) {
    return WepinTokenBalanceInfo(
      contract: json['contract'],
      symbol: json['symbol'],
      balance: json['balance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contract': contract,
      'symbol': symbol,
      'balance': balance,
    };
  }

  @override
  String toString() {
    return 'WepinTokenBalanceInfo(contract: $contract, symbol: $symbol, balance: $balance)';
  }
}

class WepinAccountBalanceInfo {
  String network;
  String address;
  String symbol;
  String balance;
  List<WepinTokenBalanceInfo> tokens;

  WepinAccountBalanceInfo({
    required this.network,
    required this.address,
    required this.symbol,
    required this.balance,
    required this.tokens,
  });

  factory WepinAccountBalanceInfo.fromJson(Map<String, dynamic> json) {
    var tokensFromJson = json['tokens'] as List;
    List<WepinTokenBalanceInfo> tokenList = tokensFromJson.map((token) => WepinTokenBalanceInfo.fromJson(token)).toList();

    return WepinAccountBalanceInfo(
      network: json['network'],
      address: json['address'],
      symbol: json['symbol'],
      balance: json['balance'],
      tokens: tokenList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'network': network,
      'address': address,
      'symbol': symbol,
      'balance': balance,
      'tokens': tokens.map((token) => token.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'WepinAccountBalanceInfo(network: $network, address: $address, symbol: $symbol, balance: $balance, tokens: $tokens)';
  }
}


class WepinNFT {
  final WepinAccount account;
  final WepinNFTContract contract;
  final String name;
  final String description;
  final String externalLink;
  final String imageUrl;
  final String? contentUrl;
  final int? quantity;
  final String contentType;
  final int state;

  WepinNFT({
    required this.account,
    required this.contract,
    required this.name,
    required this.description,
    required this.externalLink,
    required this.imageUrl,
    this.contentUrl,
    this.quantity,
    required this.contentType,
    required this.state,
  });

  factory WepinNFT.fromJson(Map<String, dynamic> json) {
    return WepinNFT(
      account: WepinAccount.fromJson(json['account']),
      contract: WepinNFTContract.fromJson(json['contract']),
      name: json['name'],
      description: json['description'],
      externalLink: json['externalLink'],
      imageUrl: json['imageUrl'],
      contentUrl: json['contentUrl'],
      quantity: json['quantity'],
      contentType: json['contentType'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
      'contract': contract.toJson(),
      'name': name,
      'description': description,
      'externalLink': externalLink,
      'imageUrl': imageUrl,
      'contentUrl': contentUrl,
      'quantity': quantity,
      'contentType': contentType,
      'state': state,
    };
  }

  @override
  String toString() {
    return 'WepinNFT(account: $account, contract: $contract, name: $name, description: $description, externalLink: $externalLink, imageUrl: $imageUrl, contentUrl: $contentUrl, quantity: $quantity, contentType: $contentType, state: $state)';
  }
}

class WepinNFTContract {
  final String name;
  final String address;
  final String scheme;
  final String? description;
  final String network;
  final String? externalLink;
  final String? imageUrl;

  WepinNFTContract({
    required this.name,
    required this.address,
    required this.scheme,
    this.description,
    required this.network,
    this.externalLink,
    this.imageUrl,
  });

  factory WepinNFTContract.fromJson(Map<String, dynamic> json) {
    return WepinNFTContract(
      name: json['name'],
      address: json['address'],
      scheme: json['scheme'],
      description: json['description'],
      network: json['network'],
      externalLink: json['externalLink'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'scheme': scheme,
      'description': description,
      'network': network,
      'externalLink': externalLink,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'WepinNFTContract(name: $name, address: $address, scheme: $scheme, description: $description, network: $network, externalLink: $externalLink, imageUrl: $imageUrl)';
  }
}

class WepinTxData {
  final String toAddress;
  String amount;

  WepinTxData({
    required this.toAddress,
    required this.amount,
  });

  factory WepinTxData.fromJson(Map<String, dynamic> json) {
    return WepinTxData(
      toAddress: json['toAddress'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toAddress': toAddress,
      'amount': amount,
    };
  }

  @override
  String toString() {
    return 'WepinTxData(toAddress: $toAddress, amount: $amount)';
  }
}


class WepinSendResponse {
  final String txId;

  WepinSendResponse({
    required this.txId,
  });

  factory WepinSendResponse.fromJson(Map<String, dynamic> json) {
    return WepinSendResponse(
      txId: json['txId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txId': txId,
    };
  }

  @override
  String toString() {
    return 'WepinSendResponse(txId: $txId)';
  }
}

class WepinReceiveResponse {
  final WepinAccount account;

  WepinReceiveResponse({
    required this.account,
  });

  factory WepinReceiveResponse.fromJson(Map<String, dynamic> json) {
    return WepinReceiveResponse(
      account: WepinAccount.fromJson(json['account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
    };
  }

  @override
  String toString() {
    return 'WepinReceiveResponse(account: $account)';
  }
}


enum WepinLifeCycle {
  notInitialized, // 'not_initialized'
  initializing,   // 'initializing'
  initialized,    // 'initialized'
  beforeLogin,    // 'before_login'
  login,          // 'login'
  loginBeforeRegister, // 'login_before_register'
}

extension WepinLifeCycleExtension on WepinLifeCycle {
  String get value {
    switch (this) {
      case WepinLifeCycle.notInitialized:
        return 'not_initialized';
      case WepinLifeCycle.initializing:
        return 'initializing';
      case WepinLifeCycle.initialized:
        return 'initialized';
      case WepinLifeCycle.beforeLogin:
        return 'before_login';
      case WepinLifeCycle.login:
        return 'login';
      case WepinLifeCycle.loginBeforeRegister:
        return 'login_before_register';
    }
  }

  static WepinLifeCycle fromString(String value) {
    switch (value) {
      case 'not_initialized':
        return WepinLifeCycle.notInitialized;
      case 'initializing':
        return WepinLifeCycle.initializing;
      case 'initialized':
        return WepinLifeCycle.initialized;
      case 'before_login':
        return WepinLifeCycle.beforeLogin;
      case 'login':
        return WepinLifeCycle.login;
      case 'login_before_register':
        return WepinLifeCycle.loginBeforeRegister;
      default:
        throw ArgumentError('Invalid WepinLifeCycle value');
    }
  }
}

class LoginProvider {
  final String provider;
  final String clientId;

  LoginProvider({required this.provider, required this.clientId});

  factory LoginProvider.fromJson(Map<String, dynamic> json) {
    return LoginProvider(
      provider: json['provider'],
      clientId: json['clientId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'clientId': clientId
    };
  }

  @override
  String toString() {
    return 'LoginProvider(provider: $provider, clientId: $clientId)';
  }
}
