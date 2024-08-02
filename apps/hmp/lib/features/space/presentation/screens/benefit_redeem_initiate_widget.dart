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

/// A widget that handles the redeeming of benefits.
/// It wraps the child widget and handles the logic of checking if the
/// user is in a space and if the selected benefit is available.
/// If the user is in a space and the selected benefit is available, it
/// initiates the process of finding the nearest spaces and redirects the user
/// to the redeem benefit screen.
/// If the user is not in a space or the selected benefit is not available,
/// it does nothing when tapped.
///
/// The [childWidget] parameter is the widget that will be wrapped by this
/// widget.
///
/// The [tokenAddress] parameter is the token address of the selected benefit.
///
/// The [onAlertCancel] parameter is the callback function that will be called
/// when the alert dialogue is cancelled.
///
/// The [selectedBenefitEntity] parameter is the selected benefit entity.
///
/// The [space] parameter is the space detail entity.
class BenefitRedeemInitiateWidget extends StatelessWidget {
  const BenefitRedeemInitiateWidget({
    super.key,
    required this.childWidget,
    required this.tokenAddress,
    required this.onAlertCancel,
    required this.selectedBenefitEntity,
    this.space,
  });

  /// The widget that will be wrapped by this widget.
  final Widget childWidget;

  /// The token address of the selected benefit.
  final String tokenAddress;

  /// The callback function that will be called when the alert dialogue is cancelled.
  final VoidCallback onAlertCancel;

  /// The selected benefit entity.
  final BenefitEntity selectedBenefitEntity;

  /// The space detail entity.
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
                              // Set the selected space if it is not null.
                              getIt<NearBySpacesCubit>().onSetSelectedSpace(
                                  space ?? const SpaceDetailEntity.empty());
                            } else {
                              // Reset the selected space if it is null.
                              getIt<NearBySpacesCubit>().onReSetSelectedSpace();
                            }

                            // Set the selected benefit entity.
                            getIt<NearBySpacesCubit>()
                                .onSetSelectedBenefitEntity(
                                    selectedBenefitEntity);

                            // Get the nearest spaces based on the selected benefit.
                            getIt<NearBySpacesCubit>()
                                .onGetNearBySpacesListData(
                                    tokenAddress: tokenAddress);
                          } else {
                            // Open alert dialogue to show info and ask to enable location.
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

                          // Log the latitude and longitude.
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
