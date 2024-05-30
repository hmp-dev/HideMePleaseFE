import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/load_more_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/home_benefits_item_widget.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SpaceBenefitListWidget extends StatefulWidget {
  const SpaceBenefitListWidget({super.key});

  @override
  State<SpaceBenefitListWidget> createState() => _SpaceBenefitListWidgetState();
}

class _SpaceBenefitListWidgetState extends State<SpaceBenefitListWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpaceCubit, SpaceState>(
      bloc: getIt<SpaceCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        if (state.benefitsGroupEntity.benefits.isEmpty) {
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
                  DefaultImage(
                    path: "assets/icons/ic_tick_badge.svg",
                    width: 20,
                    height: 20,
                  ),
                  const HorizontalSpace(8),
                  Text(
                    LocaleKeys.benefitInfo.tr(),
                    style: fontTitle06Medium(),
                  ),
                  const HorizontalSpace(8),
                  Text(
                    '${state.benefitsGroupEntity.benefits.length}',
                    style: fontTitle07(color: fore2),
                  )
                ],
              ),
              const VerticalSpace(20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: state.benefitsGroupEntity.benefits.length,
                itemBuilder: (context, index) {
                  return HomeBenefitItemWidget(
                    isShowImage: false,
                    nftBenefitEntity: state.benefitsGroupEntity.benefits[index],
                  );
                },
              ),
              if (state.benefitsGroupEntity.next != '')
                LoadMoreIconButton(
                  onTap: () {
                    getIt<SpaceCubit>().onGetSpaceBenefits(
                      spaceId: state.benefitsGroupEntity.benefits[0].spaceId,
                      isLoadingMore: true,
                      nextCursor: state.benefitsGroupEntity.next,
                    );
                  },
                ),
            ],
          );
        }
      },
    );
  }
}
