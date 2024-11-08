// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:appcheck/appcheck.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/constants/wallet_connects_constants.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/wallet_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/home/presentation/views/solana_import_wallet_view.dart';
import 'package:mobile/features/wallets/domain/entities/connected_wallet_entity.dart';
import 'package:mobile/features/wallets/domain/repositories/wallets_repository.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'wallets_state.dart';

const kAppIcon =
    'https://firebasestorage.googleapis.com/v0/b/hidemeplease2024-dev.appspot.com/o/public%2Fplaystore-icon.png?alt=media&token=121932f4-6fcc-4ddf-a48f-4496f128d763';
const kAppName = 'HideMePlease';
const kAppWeb = 'https://hidemeplease.xyz';
final kSolanaAppId = AppIdentity(
  uri: Uri.parse(kAppWeb),
  icon: Uri.parse('favicon.png'),
  name: kAppName,
);

@lazySingleton
class WalletsCubit extends BaseCubit<WalletsState> {
  final WalletsRepository _walletsRepository;

  SolanaWalletProvider? _solanaWallet;

  WalletsCubit(
    this._walletsRepository,
  ) : super(WalletsState.initial());

  Future<void> onGetAllWallets() async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _walletsRepository.getWallets();

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // users.map((e) => e.toEntity()).toList()
      (wallets) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            connectedWallets: wallets.map((e) => e.toEntity()).toList(),
          ),
        );
      },
    );
  }

  Future<void> onPostWallet({
    required SaveWalletRequestDto saveWalletRequestDto,
  }) async {
    onUpdateIsWelcomeNftRedeemInProcess(false);
    // disconnect W3MService
    onDisconnectW3MService();

    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      errorMessage: '',
    ));

    final response = await _walletsRepository.saveWallet(
        saveWalletRequestDto: saveWalletRequestDto);

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message,
        ));
        // fetch All Wallets
        onGetAllWallets();
      },
      (wallets) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
        // fetch All Wallets
        onGetAllWallets();
      },
    );
  }

  /// == Functions related To WalletConnect ==
  ///
  ///

  /// Initialize the WalletsCubit with a [SolanaWalletProvider].
  ///
  /// This function initializes the SolanaWalletProvider and the WalletConnect
  /// service. It also subscribes to various events emitted by the WalletConnect
  /// service.
  ///
  /// Parameters:
  /// - [solWallet]: The SolanaWalletProvider to use.
  ///
  /// Returns:
  /// - A [Future] that completes when the initialization is done.
  Future<void> initReownAppKitSdk(
      {required BuildContext context,
      required SolanaWalletProvider solWallet}) async {
    // Set the initial state to loading
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    try {
      // Set the SolanaWalletProvider
      _solanaWallet = solWallet;

      // Initialize the WalletConnect service

      emit(
        state.copyWith(
          reownAppKitModal: ReownAppKitModal(
            context: context,
            logLevel: LogLevel.all,
            featuredWalletIds: Web3Constants.allowedWalletIds,
            includedWalletIds: Web3Constants.allowedWalletIds,
            projectId: Web3Constants.projectId,
            metadata: const PairingMetadata(
              name: kAppName,
              description: 'Hide Me Please App',
              url: kAppWeb,
              icons: [kAppIcon],
              redirect: Redirect(
                native: 'web3modalflutter://',
                universal: 'HideMePlease',
              ),
            ),
          ),
        ),
      );

      await state.reownAppKitModal!.init();

      // Subscribe to session events
      state.reownAppKitModal!.onSessionEventEvent.subscribe(_onSessionEvent);
      // Subscribe to session updates
      state.reownAppKitModal!.onSessionUpdateEvent.subscribe(_onSessionUpdate);
      // Subscribe to session expiration
      state.reownAppKitModal!.onSessionExpireEvent.subscribe(_onSessionExpired);
      // Subscribe to modal errors
      state.reownAppKitModal!.onModalError.subscribe(_onModalError);
      // Subscribe to modal connection
      state.reownAppKitModal!.onModalConnect.subscribe(_onModalConnect);
      // Subscribe to modal disconnection
      state.reownAppKitModal!.onModalDisconnect.subscribe(_onModalDisconnect);

      // Emit the success state
      emit(state.copyWith(
        submitStatus: RequestStatus.success,
      ));
    } catch (e, t) {
      "_reownAppKitModel init error $e".log();

      "_reownAppKitModel init error: StackTrace $t".log();

      "_reownAppKitModel init error ${state.reownAppKitModal!.status}".log();

      // Emit the failure state with an error message
      emit(state.copyWith(
        submitStatus: RequestStatus.failure,
        errorMessage: LocaleKeys.somethingError.tr(),
      ));
    }
  }

  void _onSessionEvent(SessionEvent? args) {
    if (args?.name == EventsConstants.chainChanged) {
      final chainId = args?.data.toString() ?? '';

      ('onSessionEvent Chain: $chainId').log();
    }
  }

  void _onSessionUpdate(SessionUpdate? args) {
    ('[$runtimeType] onSessionUpdate $args').log();
  }

  void _onSessionExpired(SessionExpire? args) {
    ('[$runtimeType] onSessionExpired $args').log();
  }

  void _onModalError(ModalError? args) {
    "Modal Error is called +++++".log();
    ('[$runtimeType] onModalError $args');

    logErrorWithDeviceInfo(
        '[$runtimeType] onModalError $args', StackTrace.current,
        reason: "Wallet Connect Error");
  }

  /// Callback function for when a wallet is connected through the modal.
  ///
  /// This function is called when a wallet is connected through the modal.
  /// It logs the address of the connected wallet and the name of the
  /// connected wallet provider. It then calls the `onPostWallet` function
  /// to save the wallet details to the server.
  ///
  /// Parameters:
  /// - [args]: The `ModalConnect` object that contains the session details
  ///           of the connected wallet.
  void _onModalConnect(ModalConnect? args) {
    // Log the address and name of the connected wallet
    ('[$runtimeType] onModalConnect ${args?.session.address}').log();
    final publicAddress = args?.session.address ?? '';
    final connectedWalletName =
        args?.session.connectedWalletName?.toUpperCase() ?? '';

    // Get the name of the connected wallet provider
    final providerName = getWalletProvider(connectedWalletName);

    // Call the onPostWallet function to save the wallet details
    onPostWallet(
      saveWalletRequestDto: SaveWalletRequestDto(
        publicAddress: publicAddress,
        provider: providerName,
      ),
    );
  }

  void _onModalDisconnect(ModalDisconnect? args) {
    ('[$runtimeType] onModalDisconnect $args').log();
  }

  Future<void> onOpenReownAppKitBottomModal({
    required BuildContext context,
    bool isFromWePinWalletConnect = false,
    bool isFromWePinWelcomeNftRedeem = false,
    bool onTapConnectWalletButton = false,
  }) async {
    // reset the tapped wallet name
    onUpdateTappedWalletName('');
    onUpdateIsWelcomeNftRedeemInProcess(false);
    await state.reownAppKitModal!.openModalView();

    if (state.reownAppKitModal!.selectedWallet?.listing.id ==
        'phantom-custom') {
      if (Platform.isAndroid) {
        onConnectSolWallet(context);
      } else if (Platform.isIOS) {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SolanaImportWalletView()))
            .then((value) async {
          if (value != null) {
            final publicKey = value as String;

            onPostWallet(
              saveWalletRequestDto: SaveWalletRequestDto(
                publicAddress: publicKey,
                provider: getWalletProvider('phantom'),
              ),
            );
          }
        });
      }
    }

    if (state.reownAppKitModal!.selectedWallet?.listing.id == 'wepin-custom') {
      "Wepin Connect is called".log();
      if (state.isWepinWalletConnected) {
        context.showSnackBar(
          LocaleKeys.wepin_already_connected.tr(),
        );
      } else {
        // Update the tapped wallet name
        onUpdateTappedWalletName(WalletProvider.WEPIN.name);

        if (isFromWePinWalletConnect) {
          getIt<WepinCubit>().showLoader();
          getIt<WepinCubit>()
              .onConnectWepinWallet(context, isFromWePinWalletConnect: true);
        }

        //
        if (isFromWePinWelcomeNftRedeem && !isFromWePinWalletConnect) {
          getIt<WepinCubit>().showLoader();
          getIt<WepinCubit>()
              .onConnectWepinWallet(context, isFromWePinWelcomeNftRedeem: true);
        }
      }
    }
  }

  onCloseWalletConnectModel() async {
    state.reownAppKitModal!.closeModal();
  }

  onUpdateTappedWalletName(String walletName) async {
    emit(state.copyWith(tappedWalletName: walletName));
  }

  onUpdateIsWelcomeNftRedeemInProcess(bool value) async {
    emit(state.copyWith(isWelcomeNftRedeemInProcess: value));
  }

  onConnectSolWallet(BuildContext context) async {
    final bool isPhantomWalletAvailable =
        (await AppCheck().checkAvailability('app.phantom')) != null;
    if (!isPhantomWalletAvailable) {
      launchUrlString(
          'https://play.google.com/store/apps/details?id=app.phantom');
      return;
    }

    if (_solanaWallet != null) {
      if (_solanaWallet!.adapter.isAuthorized) {
        await _solanaWallet!.adapter.deauthorize(
          type: AssociationType.local,
          walletUriBase: const PhantomAppInfo(id: '0').walletUriBase,
        );
      }

      await _solanaWallet!.adapter.authorize(
        type: AssociationType.local,
        walletUriBase: const PhantomAppInfo(id: '0').walletUriBase,
      );
      if (_solanaWallet!.adapter.isAuthorized) {
        final solWalletAddr = base58Encode(
            base64Decode(_solanaWallet!.adapter.connectedAccount!.address));

        solWalletAddr.log();
        onPostWallet(
          saveWalletRequestDto: SaveWalletRequestDto(
            publicAddress: solWalletAddr,
            provider: getWalletProvider('phantom'),
          ),
        );
      }
    }
  }

  onDisconnectW3MService() {
    "onDisconnectW3MService is called**********************".log();
    if (state.reownAppKitModal != null) {
      state.reownAppKitModal!.disconnect();
    }
  }

  onDisconnectSolWallet(BuildContext context) async {
    if (_solanaWallet != null && _solanaWallet!.adapter.isAuthorized) {
      await _solanaWallet!.disconnect(context);
    }
  }

  onDeleteConnectedWallet({required String walletId}) async {
    EasyLoading.show();

    final response =
        await _walletsRepository.deleteConnectedWallet(walletId: walletId);

    EasyLoading.dismiss();

    response.fold(
      (err) {},
      (result) {
        //EasyLoading.showSuccess('Wallet deleted successfully');
        onGetAllWallets();
      },
    );
  }

  void onIsEventViewActive(bool isActive) async {
    emit(state.copyWith(isEventViewActive: isActive));
  }
}
