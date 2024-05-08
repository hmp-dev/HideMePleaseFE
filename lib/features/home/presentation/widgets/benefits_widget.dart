import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/nft_benefit_entity.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_available_text.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_used_text.dart';

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
              Text("멤버십 혜택", style: fontTitle06Medium()),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Text("멤버십 혜택", style: fontTitle06Medium()),
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

class HomeBenefitItemWidget extends StatelessWidget {
  const HomeBenefitItemWidget({
    super.key,
    required this.nftBenefitEntity,
  });

  final NftBenefitEntity nftBenefitEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CustomImageView(
              url: nftBenefitEntity.spaceImage,
              width: 54,
              height: 54,
              radius: BorderRadius.circular(2),
            ),
            const HorizontalSpace(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nftBenefitEntity.description,
                    style: fontCompactMdMedium()),
                const VerticalSpace(5),
                Text(nftBenefitEntity.spaceName,
                    style: fontCompactSm(color: fore3)),
              ],
            ),
            const Spacer(),
            nftBenefitEntity.used
                ? const BenefitUsedText()
                : const BenefitAvailableText(),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: fore5),
        )
      ],
    );
  }
}
