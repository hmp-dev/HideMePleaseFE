import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/home/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/home/presentation/views/home_view_after_login_with_nft.dart';
import 'package:mobile/features/home/presentation/views/home_view_after_login_without_nft.dart';
import 'package:mobile/features/home/presentation/views/home_view_before_login.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:mobile/app/core/constants/wallet_connects_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late W3MService _w3mService;

  @override
  void initState() {
    initializeState();
    super.initState();
  }

  initializeState() async {
    var w3mService = W3MService(
      logLevel: LogLevel.info,
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
    await _w3mService.init();

    _w3mService.onSessionEventEvent.subscribe(_onSessionEvent);
    _w3mService.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    _w3mService.onSessionExpireEvent.subscribe(_onSessionExpired);
    _w3mService.onModalError.subscribe(_onModalError);
    _w3mService.onModalConnect.subscribe(_onModalConnect);
    _w3mService.onModalDisconnect.subscribe(_onModalDisconnect);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      bloc: getIt<HomeCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return SingleChildScrollView(
          child: getHomeView(state.homeViewType),
        );
      },
    );
  }

  getHomeView(HomeViewType homeViewType) {
    if (homeViewType == HomeViewType.AfterLoginWithOutNFT) {
      return const HomeViewAfterLoginWithOutNFT();
    } else if (homeViewType == HomeViewType.AfterLoginWithNFT) {
      return const HomeViewAfterLoginWithNFT();
    } else {
      return HomeViewBeforeLogin(w3mService: _w3mService);
    }
  }

  void _onSessionEvent(SessionEvent? args) {
    Log.info('[$runtimeType] onSessionEvent $args');
    if (args?.name == EventsConstants.chainChanged) {
      final chainId = args?.data.toString() ?? '';
      if (W3MChainPresets.chains.containsKey(chainId)) {
        final chain = W3MChainPresets.chains[chainId];

        Log.info('onSessionEvent Chain: $chain');
      }
    }
  }

  void _onSessionUpdate(SessionUpdate? args) {
    Log.info('[$runtimeType] onSessionUpdate $args');
    //getIt<HomeCubit>().onUpdateHomeViewType(HomeViewType.AfterLoginWithNFT);
  }

  void _onSessionExpired(SessionExpire? args) {
    Log.info('[$runtimeType] onSessionExpired $args');
  }

  void _onModalError(ModalError? args) {
    Log.info('[$runtimeType] onModalError $args');
  }

  void _onModalConnect(ModalConnect? args) {
    Log.info('[$runtimeType] onModalConnect ${args?.session.address}');
    final publicAddress = args?.session.address ?? '';
    final provider = args?.session.connectedWalletName?.toUpperCase() ?? '';

    getIt<WalletsCubit>().onPostWallet(
        saveWalletRequestDto: SaveWalletRequestDto(
            publicAddress: publicAddress, provider: provider));
  }

  void _onModalDisconnect(ModalDisconnect? args) {
    Log.info('[$runtimeType] onModalDisconnect $args');
  }
}
