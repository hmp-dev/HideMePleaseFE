import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/home_benefits_item_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BenefitsWidget extends StatefulWidget {
  const BenefitsWidget({super.key});

  @override
  State<BenefitsWidget> createState() => _BenefitsWidgetState();
}

class _BenefitsWidgetState extends State<BenefitsWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        if (state.nftBenefitList.isEmpty) {
          return Column(
            children: [
              Text(LocaleKeys.memberShipBenefits.tr(),
                  style: fontTitle06Medium()),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Text(LocaleKeys.memberShipBenefits.tr(),
                      style: fontTitle06Medium()),
                  const HorizontalSpace(10),
                  Text("${state.nftBenefitList.length}", style: fontTitle07()),
                ],
              ),
              const VerticalSpace(20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: state.nftBenefitList.length,
                itemBuilder: (context, index) {
                  return HomeBenefitItemWidget(
                      nftBenefitEntity: state.nftBenefitList[index]);
                },
              )
            ],
          );
        }
      },
    );
  }
}
