import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/views/home_view_after_login_with_nft.dart';
import 'package:mobile/features/home/presentation/views/home_view_after_login_without_nft.dart';
import 'package:mobile/features/home/presentation/views/home_view_before_login.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

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
    _w3mService = W3MService(
      projectId: 'd6223273b0f5e67884a57b6a43c97a2f',
      //'3af62df0996c7fb3356b1cdb6bbf1028',
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
    await _w3mService.init();
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
}
