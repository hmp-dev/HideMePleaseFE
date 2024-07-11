import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/presentation/cubit/nearby_spaces_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BenefitRedeemInitiateWidget extends StatelessWidget {
  const BenefitRedeemInitiateWidget({
    super.key,
    required this.childWidget,
    required this.tokenAddress,
    required this.onAlertCancel,
    required this.selectedBenefitEntity,
    this.space,
  });

  final Widget childWidget;
  final String tokenAddress;
  final VoidCallback onAlertCancel;
  final BenefitEntity selectedBenefitEntity;
  final SpaceDetailEntity? space;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NearBySpacesCubit, NearBySpacesState>(
      bloc: getIt<NearBySpacesCubit>(),
      listener: (context, nearBySpacesState) {},
      builder: (context, nearBySpacesState) {
        return BlocConsumer<EnableLocationCubit, EnableLocationState>(
          bloc: getIt<EnableLocationCubit>()..checkLocationEnabled(),
          listener: (context, state) {},
          builder: (context, state) {
            return GestureDetector(
              onTap: nearBySpacesState.submitStatus == RequestStatus.loading
                  ? () {}
                  : selectedBenefitEntity.state != "available"
                      ? () {}
                      : () {
                          if (!state.isLocationDenied) {
                            if (space != null) {
                              getIt<NearBySpacesCubit>().onSetSelectedSpace(
                                  space ?? const SpaceDetailEntity.empty());
                            } else {
                              getIt<NearBySpacesCubit>().onReSetSelectedSpace();
                            }

                            getIt<NearBySpacesCubit>()
                                .onSetSelectedBenefitEntity(
                                    selectedBenefitEntity);

                            getIt<NearBySpacesCubit>()
                                .onGetNearBySpacesListData(
                                    tokenAddress: tokenAddress);
                          } else {
                            // open Alert Dialogue to Show Info and Ask to enable Location
                            showEnableLocationAlertDialog(
                              context: context,
                              title: LocaleKeys.enableLocationAlertMessage.tr(),
                              onConfirm: () {
                                getIt<EnableLocationCubit>()
                                    .onAskDeviceLocationWithOpenSettings();
                              },
                              onCancel: onAlertCancel,
                            );
                          }

                          "latitude: ${state.latitude}".log();
                          "longitude: ${state.longitude}".log();
                        },
              child: Container(
                child: childWidget,
              ),
            );
          },
        );
      },
    );
  }
}
