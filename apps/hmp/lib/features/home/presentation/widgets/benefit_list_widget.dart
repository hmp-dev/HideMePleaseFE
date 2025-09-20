import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/home_benefits_item_widget.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BenefitListWidget extends StatefulWidget {
  const BenefitListWidget({
    super.key,
  });

  @override
  State<BenefitListWidget> createState() => _BenefitListWidgetState();
}

class _BenefitListWidgetState extends State<BenefitListWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NftBenefitsCubit, NftBenefitsState>(
      bloc: getIt<NftBenefitsCubit>(),
      builder: (context, state) {
        if (state.submitStatus == RequestStatus.loading) {
          return Center(
            child: Lottie.asset(
              'assets/lottie/loader.json',
            ),
          );
        }
        if (state.submitStatus == RequestStatus.success &&
            state.nftBenefitList.isEmpty) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerticalSpace(10),
                Text(LocaleKeys.memberShipBenefits.tr(),
                    style: fontTitle06Medium()),
                const VerticalSpace(20),
              ],
            ),
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VerticalSpace(10),
              Row(
                children: [
                  Text(LocaleKeys.memberShipBenefits.tr(),
                      style: fontTitle06Medium()),
                  const HorizontalSpace(10),
                  Text("${state.totalBenefitCount}", style: fontTitle07()),
                ],
              ),
              const VerticalSpace(20),
              // Use Column instead of ListView when items are few and shrinkWrap is true
              ...state.nftBenefitList.map((benefit) => HomeBenefitItemWidget(
                benefitEntity: benefit,
              )),
              state.loadingMoreStatus == RequestStatus.loading
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Lottie.asset('assets/lottie/loader.json'),
                    )
                  : const SizedBox.shrink(),
            ],
          );
        }
      },
    );
  }
}
