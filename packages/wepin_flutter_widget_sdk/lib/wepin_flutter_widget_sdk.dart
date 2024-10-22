library wepin_flutter_widget_sdk;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wepin_flutter_common/wepin_flutter_common.dart';
import 'package:wepin_flutter_common/wepin_url.dart';
import 'package:wepin_flutter_login_lib/wepin_flutter_login_lib.dart';
import 'package:wepin_flutter_modal/wepin_flutter_modal.dart';
import 'package:wepin_flutter_network/session/wepin_session_check.dart';
import 'package:wepin_flutter_network/wepin_network.dart';
import 'package:wepin_flutter_network/wepin_firebase_network.dart';
import 'package:wepin_flutter_network/wepin_network_types.dart';
import 'package:wepin_flutter_common/webview/js_request.dart';
import 'package:wepin_flutter_common/webview/js_response.dart';
import 'package:wepin_flutter_widget_sdk/src/version.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

/// A WepinWidgetSDK.
class WepinWidgetSDK {
  bool _isInitialized = false;
  final String _wepinAppKey;
  final String wepinAppId;
  String? domain;
  String? version;
  WidgetAttributes wepinAttribute = WidgetAttributes();
  WepinNetwork? _wepinNetwork;
  WepinFirebaseNetwork? _wepinFirebaseNetwork;
  WepinSessionManager? _wepinSessionManager;
  final WepinModal? _wepinModal;
  String? _widgetUrl;
  WepinLifeCycle _wepinLifeCycle = WepinLifeCycle.notInitialized;
  WepinUser? _userInfo;
  Map<String, dynamic>? _currentWepinRequest;

  WepinLogin login;

  // StreamController 선언
  final StreamController<Map<String, dynamic>> _wepinEventController =
      StreamController<Map<String, dynamic>>.broadcast();
  // Stream getter
  Stream<Map<String, dynamic>> get wepinEventStream =>
      _wepinEventController.stream;

  WepinWidgetSDK({required String wepinAppKey, required this.wepinAppId})
      : _wepinAppKey = wepinAppKey,
        _wepinModal = WepinModal(),
        login = WepinLogin(wepinAppKey: wepinAppKey, wepinAppId: wepinAppId);

  Future<void> init({WidgetAttributes? attributes}) async {
    if (_isInitialized) {
      throw WepinError(WepinErrorCode.alreadyInitialized);
    }
    if (attributes != null) {
      wepinAttribute
        ..defaultCurrency = attributes.defaultCurrency
        ..defaultLanguage = attributes.defaultLanguage;
    }
    try {
      _isInitialized = false;
      wepinLifeCycle = WepinLifeCycle.initializing;
      domain = await WepinCommon.getPackageName();
      version = packageVersion;
      _wepinNetwork = WepinNetwork(
          wepinAppKey: _wepinAppKey,
          domain: domain!,
          version: version!,
          type: 'flutter_sdk');
      await _wepinNetwork?.getAppInfo();
      final firebaseKey = await _wepinNetwork?.getFirebaseConfig();
      if (firebaseKey != null) {
        _wepinFirebaseNetwork = WepinFirebaseNetwork(firebaseKey: firebaseKey);
        _wepinSessionManager = WepinSessionManager(
            appId: wepinAppId,
            wepinNetwork: _wepinNetwork!,
            wepinFirebaseNetwork: _wepinFirebaseNetwork!);
        await login.init();
        _widgetUrl = getWepinSdkUrl(_wepinAppKey)['wepinWebview'];
        await _checkLoginStatusAndSetLifecycle();
        _initWebViewCallback();
        _isInitialized = true;
      }
    } catch (e) {
      if (e is WepinError) {
        rethrow;
      }
      throw WepinError(WepinErrorCode.unknownError, e.toString());
    }
  }

  Future<void> _checkLoginStatusAndSetLifecycle() async {
    bool? isExistLoginStatus =
        await _wepinSessionManager?.checkExistWepinLoginSession();
    if (isExistLoginStatus != null && isExistLoginStatus) {
      _userInfo = await _wepinSessionManager!.getLoginUserStorage();
      if (_userInfo?.userStatus?.loginStatus != 'complete') {
        wepinLifeCycle = WepinLifeCycle.loginBeforeRegister;
      } else {
        wepinLifeCycle = WepinLifeCycle.login;
      }
    } else {
      wepinLifeCycle = WepinLifeCycle.initialized;
    }
  }

  bool isInitialized() {
    return _isInitialized;
  }

  Future<void> finalize() async {
    await _wepinSessionManager?.clearSession();
    await login.finalize();
    _isInitialized = false;
    _responseEvent.clear();
    _requestEvent.clear();
  }

  // _wepinLifeCycle 값에 대한 getter
  WepinLifeCycle get wepinLifeCycle => _wepinLifeCycle;

  // _wepinLifeCycle 값에 대한 setter
  set wepinLifeCycle(WepinLifeCycle newValue) {
    if (newValue != _wepinLifeCycle) {
      _wepinLifeCycle = newValue;
      _emitLifecycleChange(newValue);
    }
  }

  // 이벤트 발생 메소드
  void _emitLifecycleChange(WepinLifeCycle newValue) {
    if (newValue == WepinLifeCycle.login ||
        newValue == WepinLifeCycle.loginBeforeRegister) {
      // WEPIN_SDK_EVENTS.WEPIN_LIFECYCLE_CHANGE 이벤트 발생
      // 추가 정보를 함께 전달할 경우
      // print('Lifecycle changed: $newValue, UserInfo: $_userInfo');
      // 변경된 값 스트림에 추가
      _wepinEventController.add({
        'event': 'WEPIN_SDK_EVENTS.WEPIN_LIFECYCLE_CHANGE',
        'lifecycle': newValue,
        'userInfo': _userInfo,
      });
    } else {
      // print('Lifecycle changed: $newValue');
      // 변경된 값 스트림에 추가
      _wepinEventController.add({
        'event': 'WEPIN_SDK_EVENTS.WEPIN_LIFECYCLE_CHANGE',
        'lifecycle': newValue,
      });
    }
  }

  Future<WepinLifeCycle> getStatus() async {
    await _checkLoginStatusAndSetLifecycle();
    return wepinLifeCycle;
  }

  void changeLanguage({language, currency}) {
    wepinAttribute
      ..defaultCurrency = currency ?? wepinAttribute.defaultCurrency
      ..defaultLanguage = language ?? wepinAttribute.defaultLanguage;
  }

  Future<WepinUser> register(BuildContext context) async {
    _loginUICompleter = null;
    if (!_isInitialized) {
      throw WepinError(WepinErrorCode.notInitialized);
    }
    if (await getStatus() != WepinLifeCycle.loginBeforeRegister &&
        _userInfo == null) {
      throw WepinError(WepinErrorCode.incorrectLifecycleException,
          'The LifeCycle of wepin SDK has to be login_before_register');
    }
    final userStatus = _userInfo!.userStatus;
    if (userStatus?.loginStatus == 'registerRequired' &&
        userStatus?.pinRequired != true) {
      final userId = _userInfo!.userInfo?.userId;
      final walletId = _userInfo!.walletId;

      /// register api
      await _wepinNetwork?.register(RegisterRequest(
          appId: wepinAppId,
          userId: userId!,
          loginStatus: userStatus!.loginStatus,
          walletId: walletId!));
      await _wepinNetwork?.updateTermsAccepted(
          userId!,
          UpdateTermsAcceptedRequest(
              termsAccepted:
                  ITermsAccepted(termsOfService: true, privacyPolicy: true)));

      await _wepinSessionManager?.wepinStorage.setLocalStorage<WepinUserStatus>(
          'user_status', WepinUserStatus(loginStatus: 'complete'));
      await _checkLoginStatusAndSetLifecycle();
      return _userInfo!;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch;
      _currentWepinRequest = {
        'header': {
          'request_from': 'flutter',
          'request_to': 'wepin_widget',
          'id': id,
        },
        'body': {
          'command': 'register_wepin',
          'parameter': {
            'loginStatus': userStatus?.loginStatus,
            'pinRequired': userStatus?.pinRequired
          },
        },
      };
      final completer = Completer<WepinUser>();
      _responseEvent[id] = (JSResponse response) async {
        closeWidget();
        await _checkLoginStatusAndSetLifecycle();
        _currentWepinRequest = null;
        _responseEvent.remove(id);
        if (response.body.state == 'SUCCESS') {
          completer.complete(_userInfo);
        } else {
          completer.completeError(WepinError(
              WepinErrorCode.failedRegister, '${response.body.data}'));
        }
        return;
      };
      if (context.mounted) {
        await _open(context: context);
      } else {
        completer.completeError(WepinError(WepinErrorCode.invalidContext));
      }
      return completer.future;
    }
  }

  Completer<WepinUser?>? _loginUICompleter;
  List<LoginProvider>? _loginProviders;
  String _specifiedEmail = '';
  Future<WepinUser?> loginWithUI(BuildContext context,
      {required List<LoginProvider> loginProviders, String? email}) async {
    if (!_isInitialized) {
      throw WepinError(WepinErrorCode.notInitialized);
    }
    final status = await getStatus();
    if (status == WepinLifeCycle.login ||
        status == WepinLifeCycle.loginBeforeRegister && _userInfo != null) {
      return _userInfo!;
    } else {
      if (context.mounted) {
        _loginUICompleter = Completer<WepinUser?>();
        _specifiedEmail = email ?? '';
        _loginProviders = loginProviders;
        await _open(context: context);
        // Await the completion of the Completer
        WepinUser? result = await _loginUICompleter!.future;

        // After the Completer is completed, close the WebView
        await closeWidget();
        // if (_loginUICompleter!.isCompleted) {
        //   await closeWidget();
        // }
        return result; // Return the result from the Completer
      } else {
        throw WepinError(WepinErrorCode.invalidContext);
      }
    }
  }

  List<WepinAccount>? _accountInfo;
  List<IAppAccount>? _detailAccounts;

  Future<List<WepinAccount>> getAccounts(
      {List<String>? networks, bool? withEoa}) async {
    if (!_isInitialized) {
      throw WepinError(WepinErrorCode.notInitialized);
    }

    if (await getStatus() != WepinLifeCycle.login && _userInfo == null) {
      throw WepinError(WepinErrorCode.incorrectLifecycleException,
          'The LifeCycle of wepin SDK has to be login');
    }

    final userId = _userInfo!.userInfo?.userId;
    final walletId = _userInfo!.walletId;
    final localeId =
        LocaleMapper.getNumberFromLocale(wepinAttribute.defaultLanguage);

    final accountList = await _wepinNetwork?.getAppAccountList(
        GetAccountListRequest(
            walletId: walletId!,
            userId: userId!,
            localeId: localeId!.toString()));

    if (accountList == null) {
      throw WepinError(WepinErrorCode.accountNotFound, 'Account list is empty');
    }

    _detailAccounts = _filterAccountList(
      accounts: accountList.accounts,
      aaAccounts: accountList.aa_accounts ?? [],
      withEoa: withEoa ?? false,
    );

    _accountInfo = WepinAccount.fromAppAccountList(_detailAccounts!);

    if (networks != null && networks.isNotEmpty) {
      return _accountInfo!
          .where((account) => networks.contains(account.network))
          .toList();
    }

    return _accountInfo!;
  }

  List<IAppAccount> _filterAccountList({
    required List<IAppAccount> accounts,
    required List<IAppAccount> aaAccounts,
    bool withEoa = false,
  }) {
    if (aaAccounts.isEmpty) return accounts;

    if (withEoa) {
      return [...accounts, ...aaAccounts];
    }

    return accounts.map((account) {
      final aaAccount = aaAccounts.firstWhere(
        (aaAccount) =>
            aaAccount.coinId == account.coinId &&
            aaAccount.contract == account.contract &&
            aaAccount.eoaAddress == account.address,
        orElse: () => account,
      );
      return aaAccount;
    }).toList();
  }

  Future<List<WepinAccountBalanceInfo>> getBalance(
      {List<WepinAccount>? accounts}) async {
    if (!_isInitialized) {
      throw WepinError(WepinErrorCode.notInitialized);
    }
    if (await getStatus() != WepinLifeCycle.login && _userInfo == null) {
      throw WepinError(
        WepinErrorCode.incorrectLifecycleException,
        'The LifeCycle of Wepin SDK has to be login',
      );
    }

    await getAccounts();

    if (_detailAccounts == null || _detailAccounts!.isEmpty) {
      throw WepinError(WepinErrorCode.accountNotFound, 'Account list is empty');
    }

    final isAllAccounts = accounts == null || accounts.isEmpty;
    final List<WepinAccountBalanceInfo> balanceInfo = [];

    final filteredAccounts = isAllAccounts
        ? _detailAccounts!
        : _detailAccounts!
            .where((dAccount) => accounts.any((acc) =>
                acc.network == dAccount.network &&
                acc.address == dAccount.address &&
                dAccount.contract == null))
            .toList();

    if (filteredAccounts.isEmpty) {
      throw WepinError(
          WepinErrorCode.accountNotFound, 'No matching accounts found');
    }

    // getAccountBalance Parallel processing
    List<Future<void>> futures = [];
    for (var dAccount in filteredAccounts) {
      futures.add(() async {
        var balance =
            await _wepinNetwork?.getAccountBalance(dAccount.accountId);
        if (balance != null) {
          balanceInfo
              .add(_filterAccountBalance(_detailAccounts!, dAccount, balance));
        }
      }());
    }

    await Future.wait(futures);

    if (balanceInfo.isEmpty) {
      throw WepinError(
          WepinErrorCode.noBalancesFound, 'No balances found for the accounts');
    }

    return balanceInfo;
  }

  WepinAccountBalanceInfo _filterAccountBalance(
      List<IAppAccount> detailAccounts,
      IAppAccount dAccount,
      GetAccountBalanceResponse balance) {
    List<IAppAccount> accTokens = detailAccounts
        .where((acc) =>
            acc.accountId == dAccount.accountId && acc.accountTokenId != null)
        .toList();
    List<WepinTokenBalanceInfo> findTokens = balance.tokens.isNotEmpty
        ? balance.tokens
            .where((bal) => accTokens.any((t) => t.contract == bal.contract))
            .map((x) {
            return WepinTokenBalanceInfo(
              contract: x.contract,
              balance: WepinCommon.getBalanceWithDecimal(x.balance, x.decimals),
              symbol: x.symbol,
            );
          }).toList()
        : [];

    return WepinAccountBalanceInfo(
      network: dAccount.network,
      address: dAccount.address,
      balance:
          WepinCommon.getBalanceWithDecimal(balance.balance, balance.decimals),
      symbol: dAccount.symbol,
      tokens: findTokens,
    );
  }

  WepinNFT? _filterNft(IAppNFT nft, List<IAppAccount> dAccounts) {
    IAppAccount? matchedAccount = dAccounts.cast<IAppAccount?>().firstWhere(
          (account) => nft.accountId == account?.accountId,
          orElse: () => null, // 조건에 맞는 항목이 없을 경우 null 반환
        );

    if (matchedAccount == null) {
      return null; // 조건에 맞는 Account 없을 경우 null 반환
    }

    return WepinNFT(
      account: WepinAccount.fromAppAccount(matchedAccount),
      contract: WepinNFTContract(
        name: nft.contract.name,
        address: nft.contract.address,
        scheme: NFTContract.schemeMapping[nft.contract.scheme] ??
            nft.contract.scheme.toString(),
        network: nft.contract.network,
        description: nft.contract.description,
        externalLink: nft.contract.externalLink,
        imageUrl: nft.contract.imageUrl,
      ),
      name: nft.name,
      description: nft.description,
      externalLink: nft.externalLink,
      imageUrl: nft.imageUrl,
      contentType: IAppNFT.contentTypeMapping[nft.contentType]!,
      state: nft.state,
      contentUrl: nft.contentUrl,
      quantity: nft.quantity,
    );
  }

  Future<List<WepinNFT>> getNFTs(
      {required bool refresh, List<String>? networks}) async {
    if (!_isInitialized) {
      throw WepinError(WepinErrorCode.notInitialized);
    }

    if (await getStatus() != WepinLifeCycle.login && _userInfo == null) {
      throw WepinError(
        WepinErrorCode.incorrectLifecycleException,
        'The LifeCycle of wepin SDK has to be login',
      );
    }

    await getAccounts();

    if (_detailAccounts == null || _detailAccounts!.isEmpty) {
      throw WepinError(WepinErrorCode.accountNotFound, 'Account list is empty');
    }

    final userId = _userInfo!.userInfo?.userId;
    final walletId = _userInfo!.walletId;

    final GetNFTListResponse? detailNftList = refresh
        ? await _wepinNetwork?.refreshNFTList(
            GetNFTListRequest(walletId: walletId!, userId: userId!))
        : await _wepinNetwork?.getNFTList(
            GetNFTListRequest(walletId: walletId!, userId: userId!));

    if (detailNftList == null) {
      throw WepinError(WepinErrorCode.nftNotFound, 'Nft list is empty');
    }

    if (detailNftList.nfts.isEmpty) {
      return [];
    }

    final bool allNetworks = networks == null || networks.isEmpty;
    final List<WepinNFT> nftList = [];
    final List<IAppAccount> availableAccounts = _detailAccounts!
        .where((account) => allNetworks || networks.contains(account.network))
        .toList();

    for (var nft in detailNftList.nfts) {
      final filteredNft = _filterNft(nft, availableAccounts);
      if (filteredNft != null) nftList.add(filteredNft);
    }

    if (nftList.isEmpty) {
      return [];
    }

    return nftList;
  }

  String _normalizeAmount(String amount) {
    // 정규식: 소수점 이하 자릿수를 제한하지 않는 숫자 형식
    final RegExp regExp = RegExp(r'^\d+(\.\d+)?$');

    if (regExp.hasMatch(amount)) {
      return amount;
    } else {
      throw WepinError(
          WepinErrorCode.invalidParameters, 'Invalid amount format: $amount');
    }
  }

  Future<WepinSendResponse> send(BuildContext context,
      {required WepinAccount account, WepinTxData? txData}) async {
    _loginUICompleter = null;
    if (!_isInitialized) {
      throw WepinError(WepinErrorCode.notInitialized);
    }
    if (await getStatus() != WepinLifeCycle.login && _userInfo == null) {
      throw WepinError(WepinErrorCode.incorrectLifecycleException,
          'The LifeCycle of wepin SDK has to be login');
    }

    await getAccounts();

    if (_detailAccounts == null || _detailAccounts!.isEmpty) {
      throw WepinError(WepinErrorCode.accountNotFound, 'Account list is empty');
    }

    final filteredAccounts = _detailAccounts!.where((dAccount) =>
        account.network == dAccount.network &&
        account.address == dAccount.address &&
        dAccount.contract == null);

    if (filteredAccounts.isEmpty) {
      throw WepinError(WepinErrorCode.accountNotFound, 'No accounts found');
    }

    // final findAccount = filteredAccounts.first;
    // value
    if (txData != null &&
        txData.amount.isNotEmpty &&
        txData.toAddress.isNotEmpty) {
      txData.amount = _normalizeAmount(txData.amount);
    }

    final id = DateTime.now().millisecondsSinceEpoch;
    _currentWepinRequest = {
      'header': {
        'request_from': 'flutter',
        'request_to': 'wepin_widget',
        'id': id,
      },
      'body': {
        'command': 'send_transaction_without_provider',
        'parameter': {
          'account': {
            'address': account.address,
            'network': account.network,
            'contract': account.contract,
          },
          'from': account.address,
          'to': txData?.toAddress,
          'value': txData?.amount,
        },
      },
    };
    final completer = Completer<WepinSendResponse>();
    _responseEvent[id] = (JSResponse response) async {
      closeWidget();
      await _checkLoginStatusAndSetLifecycle();
      _currentWepinRequest = null;
      _responseEvent.remove(id);
      if (response.body.state == 'SUCCESS') {
        final txId = response.body.data;
        completer.complete(WepinSendResponse(txId: txId));
      } else {
        completer.completeError(
            WepinError(WepinErrorCode.failedSend, '${response.body.data}'));
      }
      return null;
    };
    if (context.mounted) {
      await _open(context: context);
    } else {
      completer.completeError(WepinError(WepinErrorCode.invalidContext));
    }
    return completer.future;
  }

  Future<WepinReceiveResponse> receive(BuildContext context,
      {required WepinAccount account}) async {
    if (!_isInitialized) {
      throw WepinError(WepinErrorCode.notInitialized);
    }
    if (await getStatus() != WepinLifeCycle.login && _userInfo == null) {
      throw WepinError(WepinErrorCode.incorrectLifecycleException,
          'The LifeCycle of wepin SDK has to be login');
    }

    await getAccounts();

    if (_detailAccounts == null || _detailAccounts!.isEmpty) {
      throw WepinError(WepinErrorCode.accountNotFound, 'Account list is empty');
    }

    final filteredAccounts = _detailAccounts!.where((dAccount) =>
        account.network == dAccount.network &&
        account.address == dAccount.address &&
        dAccount.contract == null);

    if (filteredAccounts.isEmpty) {
      throw WepinError(WepinErrorCode.accountNotFound, 'No accounts found');
    }

    final id = DateTime.now().millisecondsSinceEpoch;
    _currentWepinRequest = {
      'header': {
        'request_from': 'flutter',
        'request_to': 'wepin_widget',
        'id': id,
      },
      'body': {
        'command': 'receive_account',
        'parameter': {
          'account': {
            'address': account.address,
            'network': account.network,
            'contract': account.contract,
          },
        },
      },
    };
    final completer = Completer<WepinReceiveResponse>();
    _responseEvent[id] = (JSResponse response) async {
      closeWidget();
      await _checkLoginStatusAndSetLifecycle();
      _currentWepinRequest = null;
      _responseEvent.remove(id);
      if (response.body.state == 'SUCCESS') {
        completer.complete(WepinReceiveResponse(account: account));
      } else {
        if (response.body.data == 'User Cancel') {
          completer.complete(WepinReceiveResponse(account: account));
          return;
        }
        completer.completeError(
            WepinError(WepinErrorCode.failedSend, '${response.body.data}'));
      }
      return null;
    };
    if (context.mounted) {
      await _open(context: context);
    } else {
      completer.completeError(WepinError(WepinErrorCode.invalidContext));
    }
    return completer.future;
  }

  Future<void> openWidget(BuildContext context) async {
    _loginUICompleter = null;
    if (!_isInitialized) {
      throw WepinError(WepinErrorCode.notInitialized);
    }
    if (context.mounted) {
      await _open(context: context);
    } else {
      throw WepinError(WepinErrorCode.invalidContext);
    }
  }

  Future<WidgetPermission> _requestPermissions() async {
    // Request camera permission
    PermissionStatus cameraStatus = await Permission.camera.request();
    return WidgetPermission(camera: cameraStatus.isGranted, clipboard: true);
  }

  WidgetPermission? _permission;

  Future<void> _open({required BuildContext context, String? url}) async {
    final loadUrl = _widgetUrl! + ((url != null && url.isNotEmpty) ? url : '');
    _permission = await _requestPermissions();
    if (context.mounted) {
      _wepinModal?.openModal(context, loadUrl, _webviewCallback);
    } else {
      throw WepinError(WepinErrorCode.invalidContext);
    }
  }

  // 웹뷰 이벤트 핸들러 대체
  final Map<String, RequestHandlerFunction> _requestEvent = {};
  final Map<int, ResponseHandlerFunction> _responseEvent = {};
  void _initWebViewCallback() {
    _requestEvent['ready_to_widget'] =
        (JSRequest request, JSResponse response) async {
      final data =
          await _wepinSessionManager?.wepinStorage.getAllLocalStorage();
      List<String>? providers =
          _loginProviders?.map((e) => e.provider).toList();
      // provider list가 없으면 이메일 로그인만 가능하도록하기 위해 빈배열로 해야줘야 함!
      ResponseReadyToWidget readyToWidgetData = ResponseReadyToWidget(
          _wepinAppKey,
          WidgetWebivewAttributes.convertAttributes(wepinAttribute,
              loginProviders: providers ?? []),
          domain!,
          Platform.isIOS ? 3 : 2,
          version!,
          wepinAppId,
          'flutter-sdk',
          data ?? {},
          _permission!);
      response.body.data = readyToWidgetData.toJson();
      return jsonEncode(response.toJson());
    };

    _requestEvent['close_wepin_widget'] =
        (JSRequest request, JSResponse response) async {
      await closeWidget();
      return jsonEncode(response.toJson());
    };

    _requestEvent['set_user_email'] =
        (JSRequest request, JSResponse response) async {
      response.body.data = {'email': _specifiedEmail};
      return jsonEncode(response.toJson());
    };

    _requestEvent['set_local_storage'] =
        (JSRequest request, JSResponse response) async {
      final data = request.body.parameter['data'];
      await _wepinSessionManager?.wepinStorage.setAllLocalStorage(data);
      if (data['user_info'] != null) {
        await getStatus();
        if (_loginUICompleter != null && !(_loginUICompleter!.isCompleted)) {
          _loginUICompleter?.complete(_userInfo);
        }
      }
      return jsonEncode(response.toJson());
    };

    _requestEvent['get_sdk_request'] =
        (JSRequest request, JSResponse response) async {
      response.body.data = _currentWepinRequest ?? 'No request';
      return jsonEncode(response.toJson());
    };

    _requestEvent['get_clipboard'] =
        (JSRequest request, JSResponse response) async {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      response.body.data = data?.text ?? '';
      return jsonEncode(response.toJson());
    };

    _requestEvent['get_login_info'] =
        (JSRequest request, JSResponse response) async {
      final provider = request.body.parameter['provider'];
      // Create a map for efficient lookup
      Map<String, String> providerToClientIdMap = {
        for (var provider in _loginProviders!)
          provider.provider: provider.clientId
      };

      // Function to find clientId by provider
      String? findClientIdByProvider(String provider) {
        return providerToClientIdMap[provider];
      }

      try {
        final res = await login.loginFirebaseWithOauthProvider(
            provider: provider, clientId: findClientIdByProvider(provider)!);
        response.body.data = res ?? 'failed login';
      } catch (e) {
        response.body.data = {'error': '$e'};
      }

      return jsonEncode(response.toJson());
    };

    _responseEvent.clear();
  }

  Future<String?> _webviewCallback(List<dynamic> message) async {
    String jsRequest;
    if (message.first is! String) {
      jsRequest = jsonEncode(message.first);
    } else {
      jsRequest = message.first;
    }
    Map<String, dynamic> jsonData = jsonDecode(jsRequest);
    JSRequest? request;
    JSResponse? jsResponse;
    ResponseHeader? responseHeader;
    ResponseBody? responseBody;
    String command = '';
    String response = '';

    if (jsonData['header'] != null &&
        jsonData['header']['request_to'] != null) {
      request = JSRequest.fromJson(jsonData);

      if (request.header.request_to != 'flutter') {
        return response;
      }

      command = request.body.command;
      responseHeader = ResponseHeader(
          id: request.header.id,
          reponse_from: request.header.request_to,
          response_to: request.header.request_from);
      responseBody = ResponseBody(
          command: request.body.command,
          state: 'SUCCESS',
          data: null); //Noti : General Success Response body

      if (_requestEvent.keys.contains(command)) {
        return await _requestEvent[command]!(
            request, JSResponse(header: responseHeader, body: responseBody));
      }
    } else {
      jsResponse = JSResponse.fromJson(jsonData);

      if (jsResponse.header.response_to != 'flutter') {
        return '';
      }
      final id = jsResponse.header.id;
      command = jsResponse.body.command;

      if (_responseEvent.keys.contains(id)) {
        return await _responseEvent[id]!(jsResponse);
      }
    }
    return null; // or return response if needed
  }

  Future<void> closeWidget() async {
    _wepinModal?.closeModal();
  }
}
