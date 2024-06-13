import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BenefitRedeemInitiateWidget extends StatelessWidget {
  const BenefitRedeemInitiateWidget({
    super.key,
    required this.childWidget,
    required this.tokenAddress,
    required this.onAlertCancel,
  });

  final Widget childWidget;
  final String tokenAddress;
  final VoidCallback onAlertCancel;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnableLocationCubit, EnableLocationState>(
      bloc: getIt<EnableLocationCubit>()..checkLocationEnabled(),
      listener: (context, state) {},
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (!state.isLocationDenied) {
              getIt<SpaceCubit>().onGetSpacesData(
                tokenAddress: tokenAddress,
                latitude: 2.0, //state.latitude,
                longitude: 2.0, //state.longitude,
              );
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
  }
}
