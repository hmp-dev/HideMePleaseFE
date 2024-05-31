import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/constants/wallet_connects_constants.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/features/wallets/domain/entities/connected_wallet_entity.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/domain/repositories/wallets_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

part 'wallets_state.dart';

@lazySingleton
class WalletsCubit extends BaseCubit<WalletsState> {
  final WalletsRepository _walletsRepository;
  W3MService? _w3mService;

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
    // disconnect W3MService
    onDisconnectW3MService();

    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _walletsRepository.saveWallet(
        saveWalletRequestDto: saveWalletRequestDto);

    response.fold(
      (err) {
        if (err.message == "Wallet already exists") {
          emit(state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ));
          // fetch All Wallets
          onGetAllWallets();
        } else {
          emit(state.copyWith(
            submitStatus: RequestStatus.failure,
            errorMessage: LocaleKeys.somethingError.tr(),
          ));
        }
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

  Future<void> initW3MService() async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    try {
      var w3mService = W3MService(
        logLevel: LogLevel.debug,
        featuredWalletIds: Web3Constants.allowedWalletIds,
        includedWalletIds: Web3Constants.allowedWalletIds,
        projectId: Web3Constants.projectId,
        metadata: const PairingMetadata(
          name: 'HideMePlease',
          description: 'Hide Me Please App',
          url: 'https://hidemeplease.xyz/',
          icons: ['https://walletconnect.com/walletconnect-logo.png'],
          redirect: Redirect(
            native: 'web3modalflutter://',
            universal: 'HideMePlease',
          ),
        ),
      );

      _w3mService = w3mService;
      await _w3mService!.init();

      // Subscribe to events
      _w3mService!.onSessionEventEvent.subscribe(_onSessionEvent);
      _w3mService!.onSessionUpdateEvent.subscribe(_onSessionUpdate);
      _w3mService!.onSessionExpireEvent.subscribe(_onSessionExpired);
      _w3mService!.onModalError.subscribe(_onModalError);
      _w3mService!.onModalConnect.subscribe(_onModalConnect);
      _w3mService!.onModalDisconnect.subscribe(_onModalDisconnect);

      emit(state.copyWith(
        w3mService: w3mService,
        submitStatus: RequestStatus.success,
      )); // Emit success state
    } catch (e) {
      emit(state.copyWith(
        submitStatus: RequestStatus.failure,
        errorMessage: LocaleKeys.somethingError.tr(),
      )); // Emit failure state with error message
    }
  }

  void _onSessionEvent(SessionEvent? args) {
    if (args?.name == EventsConstants.chainChanged) {
      final chainId = args?.data.toString() ?? '';
      if (W3MChainPresets.chains.containsKey(chainId)) {
        final chain = W3MChainPresets.chains[chainId];

        ('onSessionEvent Chain: $chain').log();
      }
    }
  }

  void _onSessionUpdate(SessionUpdate? args) {
    ('[$runtimeType] onSessionUpdate $args').log();
  }

  void _onSessionExpired(SessionExpire? args) {
    ('[$runtimeType] onSessionExpired $args').log();
  }

  void _onModalError(ModalError? args) {
    ('[$runtimeType] onModalError $args');
  }

  void _onModalConnect(ModalConnect? args) {
    ('[$runtimeType] onModalConnect ${args?.session.address}').log();
    final publicAddress = args?.session.address ?? '';
    final connectedWalletName =
        args?.session.connectedWalletName?.toUpperCase() ?? '';

    final providerName = getWalletProvider(connectedWalletName);

    onPostWallet(
        saveWalletRequestDto: SaveWalletRequestDto(
            publicAddress: publicAddress, provider: providerName));
  }

  void _onModalDisconnect(ModalDisconnect? args) {
    ('[$runtimeType] onModalDisconnect $args').log();
  }

  onConnectWallet(BuildContext context) {
    state.w3mService!.openModal(context);
  }

  onDisconnectW3MService() {
    "onDisconnectW3MService is called**********************".log();
    if (state.w3mService != null) {
      state.w3mService!.disconnect();
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
        // fetch All Wallets
        onGetAllWallets();
      },
    );
  }
}
