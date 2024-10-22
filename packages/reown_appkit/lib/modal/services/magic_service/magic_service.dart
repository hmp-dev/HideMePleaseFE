import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:reown_appkit/reown_appkit.dart';
import 'package:reown_appkit/modal/constants/string_constants.dart';
import 'package:reown_appkit/modal/services/analytics_service/analytics_service_singleton.dart';
import 'package:reown_appkit/modal/services/analytics_service/models/analytics_event.dart';
import 'package:reown_appkit/modal/services/magic_service/models/email_login_step.dart';
import 'package:reown_appkit/modal/services/magic_service/i_magic_service.dart';
import 'package:reown_appkit/modal/services/magic_service/models/magic_data.dart';
import 'package:reown_appkit/modal/services/magic_service/models/magic_events.dart';
import 'package:reown_appkit/modal/services/magic_service/models/frame_message.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class MagicService implements IMagicService {
  static const _thirdSafeDomains = [
    'auth.magic.link',
    'launchdarkly.com',
  ];

  ConnectionMetadata get _selfMetadata => ConnectionMetadata(
        metadata: _metadata,
        publicKey: '',
      );

  // TODO export this
  ConnectionMetadata get _peerMetadata => ConnectionMetadata(
        metadata: PairingMetadata(
          name: 'Email Wallet',
          description: '',
          url: '',
          icons: [''], // TODO set the icon here depending on the login type
        ),
        publicKey: '',
      );

  //
  Timer? _timeOutTimer;
  String? _connectionChainId;
  int _onLoadCount = 0;
  String _packageName = '';
  AppKitSocialOption? _socialProvider;

  late Completer<bool> _initialized;
  late Completer<bool> _connected;
  late Completer<dynamic> _response;
  late Completer<bool> _disconnect;
  late final IReownCore _core;
  late final PairingMetadata _metadata;
  late final FeaturesConfig _features;
  late final WebViewController _webViewController;
  late final WebViewWidget _webview;
  // Logger get _logger => _core.logger;

  @override
  final List<String> supportedMethods = [
    'personal_sign',
    'eth_sendTransaction',
    'eth_accounts',
    'eth_sendRawTransaction',
    'eth_signTypedData_v4',
  ];

  @override
  WebViewWidget get webview => _webview;
  @override
  final isReady = ValueNotifier(false);
  @override
  final isConnected = ValueNotifier(false);
  @override
  final isTimeout = ValueNotifier(false);
  @override
  final isEmailEnabled = ValueNotifier(false);
  @override
  final isSocialEnabled = ValueNotifier(false);
  @override
  final email = ValueNotifier<String>('');
  @override
  final newEmail = ValueNotifier<String>('');
  @override
  final step = ValueNotifier<EmailLoginStep>(EmailLoginStep.idle);

  @override
  List<AppKitSocialOption> get socials => _features.socials;

  @override
  Event<MagicSessionEvent> onMagicLoginRequest = Event<MagicSessionEvent>();

  @override
  Event<MagicLoginEvent> onMagicLoginSuccess = Event<MagicLoginEvent>();

  @override
  Event<MagicConnectEvent> onMagicConnect = Event<MagicConnectEvent>();

  @override
  Event<MagicErrorEvent> onMagicError = Event<MagicErrorEvent>();

  @override
  Event<MagicSessionEvent> onMagicUpdate = Event<MagicSessionEvent>();

  @override
  Event<MagicRequestEvent> onMagicRpcRequest = Event<MagicRequestEvent>();

  @override
  Event<CompleteSocialLoginEvent> onCompleteSocialLogin =
      Event<CompleteSocialLoginEvent>();

  MagicService({
    required IReownCore core,
    required PairingMetadata metadata,
    required FeaturesConfig featuresConfig,
  })  : _core = core,
        _metadata = metadata,
        _features = featuresConfig {
    isEmailEnabled.value = _features.email;
    isSocialEnabled.value = _features.socials.isNotEmpty;
    //
    if (isEmailEnabled.value || isSocialEnabled.value) {
      _webViewController = WebViewController();
      _webview = WebViewWidget(controller: _webViewController);
      isReady.addListener(_readyListener);
    }
  }

  final _awaitReadyness = Completer<bool>();
  void _readyListener() {
    if (isReady.value && !_awaitReadyness.isCompleted) {
      _awaitReadyness.complete(true);
    }
  }

  @override
  Future<void> init() async {
    if (!isEmailEnabled.value && !isSocialEnabled.value) {
      _initialized = Completer<bool>();
      _initialized.complete(false);
      _connected = Completer<bool>();
      _connected.complete(false);
      return;
    }
    _packageName = await ReownCoreUtils.getPackageName();
    await _init();
    await _initialized.future;
    await _isConnected();
    await _connected.future;
    isReady.value = true;
    _syncDappData();
    return;
  }

  Future<void> _init() async {
    _initialized = Completer<bool>();

    await _webViewController.setBackgroundColor(Colors.transparent);
    await _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _webViewController.enableZoom(false);
    await _webViewController.addJavaScriptChannel(
      'w3mWebview',
      onMessageReceived: _onFrameMessage,
    );
    await _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          if (_isAllowedDomain(request.url)) {
            await _fitToScreen();
            return NavigationDecision.navigate;
          }
          if (isReady.value) {
            ReownCoreUtils.openURL(request.url);
          }
          return NavigationDecision.prevent;
        },
        onWebResourceError: _onWebResourceError,
        onPageFinished: (String url) async {
          _onLoadCount++;
          // If bundleId/packageName is whitelisted in cloud then for some reason it enters here twice
          // Like as if secure-mobile.walletconnect.com is loaded twice
          // If bundleId/packageName is NOT whitelisted in cloud then it enter just once.
          // This is happening only on Android devices, on iOS only once execution is done no matter what.
          if (_onLoadCount < 2 && Platform.isAndroid) return;
          await _runJavascript();
          await _fitToScreen();
          Future.delayed(Duration(milliseconds: 600)).then((value) {
            if (_initialized.isCompleted) return;
            _initialized.complete(true);
          });
        },
      ),
    );
    await _setDebugMode();
    await _loadRequest();
  }

  @override
  void setEmail(String value) {
    email.value = value;
  }

  @override
  void setNewEmail(String value) {
    newEmail.value = value;
  }

  @override
  void setProvider(AppKitSocialOption? provider) {
    _socialProvider = provider;
  }

  bool get _socialsNotReady => (!isSocialEnabled.value || !isReady.value);
  bool get _emailNotReady => (!isEmailEnabled.value || !isReady.value);
  bool get _serviceNotReady =>
      (!isEmailEnabled.value && !isSocialEnabled.value) || !isReady.value;

  // ****** W3mFrameProvider public methods ******* //

  // SOCIAL LOGIN RELATED METHODS

  Completer<String?> _getSocialRedirectUri = Completer<String?>();
  @override
  Future<String?> getSocialRedirectUri({
    required AppKitSocialOption provider,
    String? schema,
    String? chainId,
  }) async {
    if (_socialsNotReady) return null;
    //
    _getSocialRedirectUri = Completer<String?>();
    _connectionChainId = chainId ?? _connectionChainId;
    _socialProvider = provider;
    final message = GetSocialRedirectUri(
      provider: _socialProvider!.name.toLowerCase(),
      schema: schema,
    ).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
    return await _getSocialRedirectUri.future;
  }

  Completer<bool> _connectSocial = Completer<bool>();
  @override
  Future<dynamic> connectSocial({required String uri}) async {
    if (_socialsNotReady) return null;
    //
    _connectSocial = Completer<bool>();
    final message = ConnectSocial(uri: uri).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
    return await _connectSocial.future;
  }

  @override
  void completeSocialLogin({required String url}) {
    onCompleteSocialLogin.broadcast(CompleteSocialLoginEvent(url));
  }

  Completer<String?> _getFarcasterUri = Completer<String?>();
  @override
  Future<String?> getFarcasterUri({String? chainId}) async {
    if (_socialsNotReady) return null;
    if (_getFarcasterUri.isCompleted) {
      return await _getFarcasterUri.future;
    }
    //
    _getFarcasterUri = Completer<String?>();
    _connectionChainId = chainId ?? _connectionChainId;
    _socialProvider = AppKitSocialOption.Farcaster;
    final message = GetFarcasterUri().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
    return await _getFarcasterUri.future;
  }

  Completer<bool> _connectFarcaster = Completer<bool>();
  @override
  Future<bool> awaitFarcasterResponse() async {
    if (_socialsNotReady) return false;
    //
    _connectFarcaster = Completer<bool>();
    // final message = ConnectFarcaster().toString();
    // await _webViewController.runJavaScript('sendMessage($message)');
    return await _connectFarcaster.future;
  }

  // EMAIL RELATED METHODS

  @override
  Future<void> connectEmail({required String value, String? chainId}) async {
    if (_emailNotReady) return;
    //
    _socialProvider = null;
    _connectionChainId = chainId ?? _connectionChainId;
    final message = ConnectEmail(email: value).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> updateEmail({required String value}) async {
    if (_emailNotReady) return;
    //
    step.value = EmailLoginStep.loading;
    final message = UpdateEmail(email: value).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> updateEmailPrimaryOtp({required String otp}) async {
    if (_emailNotReady) return;
    //
    step.value = EmailLoginStep.loading;
    final message = UpdateEmailPrimaryOtp(otp: otp).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> updateEmailSecondaryOtp({required String otp}) async {
    if (_emailNotReady) return;
    //
    step.value = EmailLoginStep.loading;
    final message = UpdateEmailSecondaryOtp(otp: otp).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> connectOtp({required String otp}) async {
    if (_emailNotReady) return;
    //
    step.value = EmailLoginStep.loading;
    final message = ConnectOtp(otp: otp).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  // SHARED METHODS

  @override
  Future<void> syncTheme(ReownAppKitModalTheme? theme) async {
    if (_serviceNotReady) return;
    //
    final message = SyncTheme(theme: theme).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  void _syncDappData() async {
    if (_serviceNotReady) return;
    //
    final message = SyncAppData(
      metadata: _metadata,
      projectId: _core.projectId,
      sdkVersion: 'flutter-${CoreConstants.X_SDK_VERSION}',
    ).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> getChainId() async {
    if (_serviceNotReady) return;
    //
    final message = GetChainId().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> getUser({String? chainId}) async {
    if (_serviceNotReady) return;
    //
    return await _getUser(chainId);
  }

  Future<void> _getUser(String? chainId) async {
    final message = GetUser(chainId: chainId ?? _connectionChainId).toString();
    return await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> switchNetwork({required String chainId}) async {
    if (_serviceNotReady) return;
    //
    final message = SwitchNetwork(chainId: chainId).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<dynamic> request({
    String? chainId,
    required SessionRequestParams request,
  }) async {
    if (_serviceNotReady) return;
    //
    await _awaitReadyness.future;
    await _rpcRequest(request.toJson());
    return await _response.future;
  }

  Future<void> _rpcRequest(Map<String, dynamic> parameters) async {
    _response = Completer<dynamic>();
    if (!isConnected.value) {
      _connected = Completer<bool>();
      if (_socialProvider != null) {
        onMagicLoginRequest.broadcast(MagicSessionEvent(
          provider: _socialProvider,
        ));
      } else {
        onMagicLoginRequest.broadcast(MagicSessionEvent(
          email: email.value,
        ));
        await connectEmail(value: email.value);
      }
      final success = await _connected.future;
      if (!success) return;
    }
    onMagicRpcRequest.broadcast(MagicRequestEvent(request: parameters));
    final method = parameters['method'];
    final params = parameters['params'] as List;
    final message = RpcRequest(method: method, params: params).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<bool> disconnect() async {
    if (_serviceNotReady) return false;
    //
    _disconnect = Completer<bool>();
    if (!isConnected.value) {
      _resetTimeOut();
      _disconnect.complete(true);
      return (await _disconnect.future);
    }
    final message = SignOut().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
    return (await _disconnect.future);
  }

  // ****** Private Methods ******* //

  Future<void> _loadRequest() async {
    try {
      final headers = {
        // secure-site's middleware requires a referer otherwise it throws `400: Missing projectId or referer`
        'referer': _metadata.url,
        'x-bundle-id': _packageName,
      };
      final uri = Uri.parse(UrlConstants.secureService);
      final queryParams = {
        'projectId': _core.projectId,
        'bundleId': _packageName,
      };
      await _webViewController.loadRequest(
        uri.replace(queryParameters: queryParams),
        headers: headers,
      );
      // in case connection message or even the request itself hangs there's no other way to continue the flow than timing it out.
      _timeOutTimer ??= Timer.periodic(Duration(seconds: 1), _timeOut);
    } catch (e) {
      _initialized.complete(false);
    }
  }

  Future<void> _isConnected() async {
    _connected = Completer<bool>();
    final message = IsConnected().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  String? _socialUsername;

  void _onFrameMessage(JavaScriptMessage jsMessage) async {
    if (Platform.isAndroid) {
      _core.logger.d('[$runtimeType] JS Console: $jsMessage');
    }
    try {
      final frameMessage = jsMessage.toFrameMessage();
      if (!frameMessage.isValidOrigin || !frameMessage.isValidData) {
        return;
      }
      final messageData = frameMessage.data!;
      if (messageData.syncDataSuccess) {
        _resetTimeOut();
      }
      // ****** IS_CONNECTED
      if (messageData.isConnectSuccess) {
        _resetTimeOut();
        isConnected.value = messageData.getPayloadMapKey<bool>('isConnected');
        if (!_connected.isCompleted) {
          _connected.complete(isConnected.value);
        }
        onMagicConnect.broadcast(MagicConnectEvent(isConnected.value));
        if (isConnected.value) {
          await _getUser(_connectionChainId);
        }
      }
      if (messageData.getSocialRedirectUriSuccess) {
        final uri = messageData.getPayloadMapKey<String>('uri');
        _getSocialRedirectUri.complete(uri);
      }
      // ****** CONNECT_SOCIAL_SUCCESS
      if (messageData.connectSocialSuccess) {
        _socialUsername = messageData.getPayloadMapKey<String?>('userName');
        debugPrint('[$runtimeType] connectSocialSuccess $_socialUsername');
        _connectSocial.complete(true);
      }
      // ****** GET_FARCASTER_URI_SUCCESS
      if (messageData.getFarcasterUriSuccess) {
        final url = messageData.getPayloadMapKey<String>('url');
        _getFarcasterUri.complete(url);
      }
      // ****** CONNECT_FARCASTER_SUCCESS
      if (messageData.connectFarcasterSuccess) {
        _socialUsername = messageData.getPayloadMapKey<String?>('userName');
        debugPrint('[$runtimeType] connectFarcasterSuccess $_socialUsername');
        _connectFarcaster.complete(true);
      }
      // ****** CONNECT_EMAIL
      if (messageData.connectEmailSuccess) {
        if (step.value != EmailLoginStep.loading) {
          final action = messageData.getPayloadMapKey<String>('action');
          final value = action.toString().toUpperCase();
          final newStep = EmailLoginStep.fromAction(value);
          if (newStep == EmailLoginStep.verifyOtp) {
            if (step.value == EmailLoginStep.verifyDevice) {
              analyticsService.instance.sendEvent(DeviceRegisteredForEmail());
            }
            analyticsService.instance.sendEvent(EmailVerificationCodeSent());
          }
          step.value = newStep;
        }
      }
      // ****** CONNECT_OTP
      if (messageData.connectOtpSuccess) {
        analyticsService.instance.sendEvent(EmailVerificationCodePass());
        step.value = EmailLoginStep.idle;
        await _getUser(_connectionChainId);
      }
      // ****** UPDAET_EMAIL
      if (messageData.updateEmailSuccess) {
        final action = messageData.getPayloadMapKey<String>('action');
        if (action == 'VERIFY_SECONDARY_OTP') {
          step.value = EmailLoginStep.verifyOtp2;
        } else {
          step.value = EmailLoginStep.verifyOtp;
        }
        analyticsService.instance.sendEvent(EmailEdit());
      }
      // ****** UPDATE_EMAIL_PRIMARY_OTP
      if (messageData.updateEmailPrimarySuccess) {
        step.value = EmailLoginStep.verifyOtp2;
      }
      // ****** UPDATE_EMAIL_SECONDARY_OTP
      if (messageData.updateEmailSecondarySuccess) {
        analyticsService.instance.sendEvent(EmailEditComplete());
        step.value = EmailLoginStep.idle;
        setEmail(newEmail.value);
        setNewEmail('');
        await _getUser(_connectionChainId);
      }
      // ****** SWITCH_NETWORK
      if (messageData.switchNetworkSuccess) {
        final chainId = messageData.getPayloadMapKey<int?>('chainId');
        onMagicUpdate.broadcast(MagicSessionEvent(chainId: chainId));
      }
      // ****** GET_CHAIN_ID
      if (messageData.getChainIdSuccess) {
        final chainId = messageData.getPayloadMapKey<int?>('chainId');
        onMagicUpdate.broadcast(MagicSessionEvent(chainId: chainId));
        _connectionChainId = chainId?.toString();
      }
      // ****** RPC_REQUEST
      if (messageData.rpcRequestSuccess) {
        final hash = messageData.payload as String?;
        _response.complete(hash);
        onMagicRpcRequest.broadcast(
          MagicRequestEvent(
            request: null,
            result: hash,
            success: true,
          ),
        );
      }
      // ****** GET_USER
      if (messageData.getUserSuccess) {
        isConnected.value = true;
        debugPrint('[$runtimeType] getUserSuccess ${messageData.payload}');
        final magicData = MagicData.fromJson(messageData.payload!).copytWith(
          userName: _socialUsername,
        );
        _socialUsername = null;
        if (!_connected.isCompleted) {
          final event = MagicSessionEvent(
            email: magicData.email,
            userName: magicData.userName,
            address: magicData.address,
            chainId: magicData.chainId,
            provider: magicData.provider,
          );
          onMagicUpdate.broadcast(event);
          _connected.complete(isConnected.value);
        } else {
          final session = magicData.copytWith(
            peer: _peerMetadata.copyWith(
              metadata: _peerMetadata.metadata.copyWith(
                name: _socialProvider?.name ?? 'Email Wallet',
              ),
            ),
            self: _selfMetadata,
            provider: _socialProvider,
          );
          onMagicLoginSuccess.broadcast(MagicLoginEvent(session));
        }
      }
      // ****** SIGN_OUT_SUCCESS
      if (messageData.signOutSuccess) {
        _resetTimeOut();
        _disconnect.complete(true);
      }
      if (messageData.sessionUpdate) {
        // onMagicUpdate.broadcast(MagicSessionEvent(...));
      }
      if (messageData.isConnectError) {
        _error(IsConnectedErrorEvent());
      }
      if (messageData.connectEmailError) {
        String? message = messageData.getPayloadMapKey<String?>('message');
        if (message?.toLowerCase() == 'invalid params') {
          message = 'Wrong email format';
        }
        _error(ConnectEmailErrorEvent(message: message));
      }
      if (messageData.updateEmailError) {
        final message = messageData.getPayloadMapKey<String?>('message');
        _error(UpdateEmailErrorEvent(message: message));
      }
      if (messageData.updateEmailPrimaryOtpError) {
        final message = messageData.getPayloadMapKey<String?>('message');
        _error(UpdateEmailPrimaryOtpErrorEvent(message: message));
      }
      if (messageData.updateEmailSecondaryOtpError) {
        final message = messageData.getPayloadMapKey<String?>('message');
        _error(UpdateEmailSecondaryOtpErrorEvent(message: message));
      }
      if (messageData.connectOtpError) {
        analyticsService.instance.sendEvent(EmailVerificationCodeFail());
        final message = messageData.getPayloadMapKey<String?>('message');
        _error(ConnectOtpErrorEvent(message: message));
      }
      if (messageData.getSocialRedirectUriError) {
        String? message = messageData.getPayloadMapKey<String?>('message');
        message = message?.replaceFirst(
          'Error: Magic RPC Error: [-32600] ',
          '',
        );
        _error(MagicErrorEvent(message));
        _getSocialRedirectUri.complete(null);
      }
      if (messageData.connectSocialError) {
        String? message = messageData.getPayloadMapKey<String?>('message');
        message = message?.replaceFirst(
          'Error: Magic RPC Error: [-32600] ',
          '',
        );
        _error(MagicErrorEvent(message));
        _connectSocial.complete(false);
      }
      if (messageData.getFarcasterUriError) {
        String? message = messageData.getPayloadMapKey<String?>('message');
        message = message?.replaceFirst(
          'Error: Magic RPC Error: [-32600] ',
          '',
        );
        _error(MagicErrorEvent(message));
        _getFarcasterUri.complete(null);
      }
      if (messageData.connectFarcasterError) {
        String? message = messageData.getPayloadMapKey<String?>('message');
        message = message?.replaceFirst(
          'Error: Magic RPC Error: [-32600] ',
          '',
        );
        _error(MagicErrorEvent(message));
        _connectFarcaster.complete(false);
      }
      if (messageData.getUserError) {
        _error(GetUserErrorEvent());
      }
      if (messageData.switchNetworkError) {
        _error(SwitchNetworkErrorEvent());
      }
      if (messageData.rpcRequestError) {
        final message = messageData.getPayloadMapKey<String?>('message');
        _error(RpcRequestErrorEvent(message));
      }
      if (messageData.signOutError) {
        _error(SignOutErrorEvent());
      }
    } catch (e, s) {
      _core.logger.d('[$runtimeType] $jsMessage $e', stackTrace: s);
    }
  }

  void _error(MagicErrorEvent errorEvent) {
    if (errorEvent is RpcRequestErrorEvent) {
      _response.completeError(JsonRpcError(code: 0, message: errorEvent.error));
      onMagicRpcRequest.broadcast(
        MagicRequestEvent(
          request: null,
          result: JsonRpcError(code: 0, message: errorEvent.error),
          success: false,
        ),
      );
      return;
    }
    if (errorEvent is IsConnectedErrorEvent) {
      isReady.value = false;
      isConnected.value = false;
      step.value = EmailLoginStep.idle;
    }
    if (errorEvent is ConnectEmailErrorEvent) {
      isConnected.value = false;
      step.value = EmailLoginStep.idle;
    }
    if (errorEvent is UpdateEmailErrorEvent) {
      isConnected.value = false;
      step.value = EmailLoginStep.verifyOtp;
    }
    if (errorEvent is UpdateEmailPrimaryOtpErrorEvent) {
      step.value = EmailLoginStep.verifyOtp;
    }
    if (errorEvent is UpdateEmailSecondaryOtpErrorEvent) {
      step.value = EmailLoginStep.verifyOtp2;
    }
    if (errorEvent is ConnectOtpErrorEvent) {
      isConnected.value = false;
      step.value = EmailLoginStep.verifyOtp;
    }
    if (errorEvent is SignOutErrorEvent) {
      isConnected.value = true;
      _disconnect.complete(false);
    }
    if (!_connected.isCompleted) {
      _connected.complete(isConnected.value);
    }
    onMagicError.broadcast(errorEvent);
  }

  Future<void> _fitToScreen() async {
    return await _webViewController.runJavaScript('''
      if (document.querySelector('meta[name="viewport"]') === null) {
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        document.head.appendChild(meta);
      } else {
        document.querySelector('meta[name="viewport"]').setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
      }
    ''');
  }

  Future<void> _runJavascript() async {
    return await _webViewController.runJavaScript('''
      window.addEventListener('message', ({ data, origin }) => {
        console.log('[MagicService] received <=== ' + JSON.stringify({data,origin}))
        window.w3mWebview.postMessage(JSON.stringify({data,origin}))
      })

      const sendMessage = async (message) => {
        const iframeFL = document.getElementById('frame-mobile-sdk')
        console.log('[MagicService] posted =====> ' + JSON.stringify(message))
        iframeFL.contentWindow.postMessage(message, '*')
      }
    ''');
  }

  void _onDebugConsoleReceived(JavaScriptConsoleMessage message) {
    _core.logger.d('[$runtimeType] JS Console: ${message.message}');
  }

  void _onWebResourceError(WebResourceError error) {
    if (error.isForMainFrame == true) {
      isReady.value = false;
      isConnected.value = false;
      step.value = EmailLoginStep.idle;
      debugPrint('''
              [$runtimeType] Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
              url: ${error.url}
            ''');
    }
  }

  bool _isAllowedDomain(String domain) {
    final domains = [
      UrlConstants.secureOrigin1,
      UrlConstants.secureOrigin2,
      ..._thirdSafeDomains,
    ].join('|');
    return RegExp(r'' + domains).hasMatch(domain);
  }

  void _timeOut(Timer time) {
    if (time.tick > 30) {
      _resetTimeOut();
      _error(IsConnectedErrorEvent());
      isTimeout.value = true;
      _core.logger.e(
        '[EmailLogin] initialization timed out. Please check if your '
        'bundleId/packageName $_packageName is whitelisted in your cloud '
        'configuration at ${UrlConstants.cloudService} for project id ${_core.projectId}',
      );
    }
  }

  Future<void> _setDebugMode() async {
    if (kDebugMode) {
      try {
        if (Platform.isIOS) {
          await _webViewController.setOnConsoleMessage(
            _onDebugConsoleReceived,
          );
          final webkitCtrl =
              _webViewController.platform as WebKitWebViewController;
          webkitCtrl.setInspectable(true);
        }
        if (Platform.isAndroid) {
          if (_webViewController.platform is AndroidWebViewController) {
            final platform =
                _webViewController.platform as AndroidWebViewController;
            AndroidWebViewController.enableDebugging(true);
            platform.setMediaPlaybackRequiresUserGesture(false);

            final cookieManager =
                WebViewCookieManager().platform as AndroidWebViewCookieManager;
            cookieManager.setAcceptThirdPartyCookies(
              _webViewController.platform as AndroidWebViewController,
              true,
            );
          }
        }
      } catch (_) {}
    }
  }

  void _resetTimeOut() {
    _timeOutTimer?.cancel();
    _timeOutTimer = null;
  }
}

extension JavaScriptMessageExtension on JavaScriptMessage {
  FrameMessage toFrameMessage() {
    final decodeMessage = jsonDecode(message) as Map<String, dynamic>;
    return FrameMessage.fromJson(decodeMessage);
  }
}
