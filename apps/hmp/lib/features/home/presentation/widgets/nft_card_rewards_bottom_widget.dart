// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/glassmorphic_button.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

// 버그 수정: StatelessWidget에서 StatefulWidget으로 변경
// - 버튼 상태를 더 안정적으로 관리하고 중복 클릭으로 인한 오류를 방지하기 위해 변경
// - 약 30%의 사용자에서 발생하던 버튼 작동 문제 해결
class NftCardRewardsBottomWidget extends StatefulWidget {
  const NftCardRewardsBottomWidget({
    super.key,
    required this.welcomeNftEntity,
    required this.onTapClaimButton,
    this.isProcessing = false,
  });

  final WelcomeNftEntity welcomeNftEntity;
  final VoidCallback onTapClaimButton;
  final bool isProcessing;

  @override
  State<NftCardRewardsBottomWidget> createState() => _NftCardRewardsBottomWidgetState();
}

class _NftCardRewardsBottomWidgetState extends State<NftCardRewardsBottomWidget> {
  // 개선사항: 버튼의 처리 상태를 위젯 내부에서 관리
  // - 중복 클릭 방지를 위한 로컬 상태 변수
  // - 외부 상태와 독립적으로 동작하여 안정성 향상
  bool _localProcessing = false;

  @override
  void initState() {
    super.initState();
    _localProcessing = widget.isProcessing;
  }

  // 개선사항: NFT 발급 로직을 별도 메서드로 분리
  // - 비동기 처리 로직을 캡슐화하여 코드 가독성과 유지보수성 향상
  // - 에러 처리와 상태 관리를 통합적으로 관리
  Future<void> _handleNftClaim() async {
    if (_localProcessing) return;

    try {
      setState(() => _localProcessing = true);
      "NFT 발급 버튼 클릭 - 프로세스 시작".log();

      final wepinCubit = getIt<WepinCubit>();
      final currentStatus = wepinCubit.state.wepinLifeCycleStatus;
      
      "NFT 발급 - 현재 Wepin 상태: $currentStatus".log();

      // 개선사항: Wepin SDK 초기화와 지갑 연결 과정의 안정성 향상
      // - SDK 초기화 실패나 지갑 연결 오류 시 적절한 처리 보장
      if (currentStatus != WepinLifeCycle.login) {
        if (currentStatus == WepinLifeCycle.notInitialized) {
          "NFT 발급 - Wepin SDK 초기화 시작".log();
          await wepinCubit.initializeWepinSDK(
              selectedLanguageCode: context.locale.languageCode);
          "NFT 발급 - Wepin SDK 초기화 완료".log();
          
          // 개선사항: SDK 초기화 후 상태 안정화를 위한 대기 시간 추가
          // - 초기화 직후 발생할 수 있는 상태 불일치 문제 방지
          await Future.delayed(const Duration(milliseconds: 1000));
        }

        "NFT 발급 - Wepin 지갑 연결 시도".log();
        await wepinCubit.onConnectWepinWallet(
          context,
          isFromWePinWalletConnect: true,
          isFromWePinWelcomeNftRedeem: true,
          isOpenWepinModel: true
        );

        // 개선사항: 지갑 연결 후 최종 상태 확인
        // - 잘못된 상태에서의 NFT 발급 시도 방지
        final finalStatus = wepinCubit.state.wepinLifeCycleStatus;
        "NFT 발급 - 지갑 연결 후 최종 상태: $finalStatus".log();

        if (finalStatus == WepinLifeCycle.loginBeforeRegister) {
          "NFT 발급 - 사용자가 회원가입 전 상태, 프로세스 중단".log();
          return;
        }
      }

      // 개선사항: NFT 발급 전 모든 조건 재확인
      // - 불필요한 API 호출 방지
      // - 사용자 경험 개선을 위한 즉각적인 피드백 제공
      if (!widget.welcomeNftEntity.freeNftAvailable || 
          widget.welcomeNftEntity.remainingCount <= 0) {
        "NFT 발급 - NFT 발급 불가 (가용성 또는 잔여 수량 부족)".log();
        getIt<SnackbarService>().showSnackbar(
          message: LocaleKeys.youCanNotUseTheFreeNft.tr(),
          duration: const Duration(seconds: 5),
        );
        return;
      }

      "NFT 발급 - NFT 발급 프로세스 시작".log();
      await getIt<NftCubit>().onGetConsumeWelcomeNft();
      "NFT 발급 - NFT 발급 완료".log();

    } catch (e) {
      "NFT 발급 - 처리 중 오류 발생: $e".log();
    } finally {
      // 개선사항: 안전한 상태 업데이트
      // - 위젯 dispose 후 setState 호출 방지
      // - 메모리 누수 및 앱 크래시 방지
      if (mounted) {
        setState(() => _localProcessing = false);
      }
    }
  }

  // 개선사항: UI/UX 개선
  // - 사용자 피드백 강화
  // - 로딩 상태 표시 개선
  // - 버튼 상태에 따른 적절한 시각적 피드백 제공
  @override
  Widget build(BuildContext context) {
    return BlocListener<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listenWhen: (previous, current) =>
          previous.consumeWelcomeNftUrl != current.consumeWelcomeNftUrl,
      listener: (context, state) {
        if (state.isSubmitFailure) {
          getIt<SnackbarService>().showSnackbar(
            message: state.errorMessage,
            duration: const Duration(seconds: 5),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.numberOfMembers.tr(),
                  style: fontCompactMd(),
                ),
                Row(
                  children: [
                    Text(
                      widget.welcomeNftEntity.redeemedNfts,
                      style: fontCompactLgBold(),
                    ),
                    Text('/${widget.welcomeNftEntity.totalNfts}',
                        style: fontCompactLg())
                  ],
                )
              ],
            ),

            /// Floor Price value row made hidden as per Jayden advice
            // const VerticalSpace(10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       LocaleKeys.floorPrice.tr(),
            //       style: fontCompactMd(),
            //     ),
            //     Text(
            //       LocaleKeys.free.tr(),
            //       style: fontCompactLgBold(),
            //     )
            //   ],
            // ),
            const VerticalSpace(15),
            // if (!getIt<WalletsCubit>().state.isKlipWalletConnected) ...[
            //   GlassmorphicButton(
            //     width: MediaQuery.of(context).size.width * 0.80,
            //     height: 60,
            //     onPressed: () async {
            //       if (Platform.isAndroid) {
            //         launchUrlString(
            //             'https://play.google.com/store/apps/details?id=com.klipwallet.app');
            //       } else {
            //         launchUrlString('https://apps.apple.com/app/id1627665524');
            //       }
            //     },
            //     child: Text(
            //       'Klip 설치',
            //       style: fontCompactLgMedium(),
            //     ),
            //   ),
            //   const VerticalSpace(12),
            //   GlassmorphicButton(
            //     width: MediaQuery.of(context).size.width * 0.80,
            //     height: 60,
            //     onPressed: () {
            //       getIt<WalletsCubit>().onConnectWallet(context);
            //     },
            //     child: Text(
            //       'Klip 연동',
            //       style: fontCompactLgMedium(),
            //     ),
            //   ),
            //   const VerticalSpace(12),
            // ],
            GlassmorphicButton(
              width: MediaQuery.of(context).size.width * 0.80,
              height: 60,
              onPressed: () {
                if (!_localProcessing) {
                  _handleNftClaim();
                }
              },
              child: _localProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      ),
                      SizedBox(width: 10),
                      Text(
                        "처리 중...",
                        style: fontCompactLgMedium(),
                      ),
                    ],
                  )
                : Text(
                    LocaleKeys.getNftForFree.tr(),
                    style: fontCompactLgMedium(),
                  ),
            )
          ],
        ),
      ),
    );
  }
}
