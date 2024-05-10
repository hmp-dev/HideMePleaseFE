import 'package:flutter/material.dart';
import 'package:mobile/app/core/constants/wallet_connects_constants.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/views/home_view_after_wallet_connected.dart';
import 'package:mobile/features/home/presentation/views/home_view_before_login.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late W3MService _w3mService;

  late ScrollController _scrollController;
  bool _isVisible = true;

  @override
  void initState() {
    initializeState();
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    getIt<EnableLocationCubit>().onAskDeviceLocation();
  }

  void _scrollListener() {
    "ScrollController: ${_scrollController.offset}".log();
    if (_scrollController.offset >= 100 && _isVisible) {
      setState(() {
        _isVisible = false;
      });
    } else if (_scrollController.offset < 100 && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
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
    return BlocListener<WalletsCubit, WalletsState>(
      bloc: getIt<WalletsCubit>(),
      listener: (context, state) {
        if (state.isSuccess) {
          // call to get nft collections
          getIt<NftCubit>().onGetNftCollections();
          // show the AfterLoginWithNFT screen
          getIt<HomeCubit>()
              .onUpdateHomeViewType(HomeViewType.afterWalletConnected);
          // navigate to MyMembershipSettingsScreen
          MyMembershipSettingsScreen.push(context);
        }
      },
      child: BlocConsumer<HomeCubit, HomeState>(
        bloc: getIt<HomeCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: getHomeView(state.homeViewType),
          );
        },
      ),
    );
  }

  getHomeView(HomeViewType homeViewType) {
    if (homeViewType == HomeViewType.afterWalletConnected) {
      return const HomeViewAfterWalletConnected();
    } else {
      return HomeViewBeforeLogin(w3mService: _w3mService);
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
    //getIt<HomeCubit>().onUpdateHomeViewType(HomeViewType.AfterLoginWithNFT);
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

    getIt<WalletsCubit>().onPostWallet(
        saveWalletRequestDto: SaveWalletRequestDto(
            publicAddress: publicAddress, provider: providerName));
  }

  void _onModalDisconnect(ModalDisconnect? args) {
    ('[$runtimeType] onModalDisconnect $args').log();
  }
}
