import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/helpers/map_utils.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/presentation/widgets/build_hiding_count_widget.dart';
import 'package:mobile/features/space/presentation/widgets/space_benefit_list_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SpaceDetailView extends StatefulWidget {
  const SpaceDetailView({super.key, required this.space});

  final SpaceDetailEntity space;

  @override
  State<SpaceDetailView> createState() => _SpaceDetailViewState();
}

class _SpaceDetailViewState extends State<SpaceDetailView> with RouteAware {
  List<Marker> allMarkers = [];

  late GoogleMapController _controller;

  String transactionNote = "";
  String receiptImgUrl = "";

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5518911, 126.9917937),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
  }

  Future<void> moveAnimateToAddress(LatLng position) async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 92.8334901395799,
          target: position,
          tilt: 9.440717697143555,
          zoom: 18.151926040649414,
        ),
      ),
    );
  }

  Future<void> addMarker(LatLng position) async {
    allMarkers
        .add(Marker(markerId: const MarkerId('myMarker'), position: position));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            widget.space.image == ""
                ? CustomImageView(
                    imagePath: "assets/images/place_holder_card.png",
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    radius: BorderRadius.circular(2),
                    fit: BoxFit.cover,
                  )
                : CustomImageView(
                    url: widget.space.image,
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    radius: BorderRadius.circular(2),
                    fit: BoxFit.cover,
                  ),
            buildBackArrowIconButton(context),
            const BuildHidingCountWidget(hidingCount: 0),
          ],
        ),
        buildNameTypeRow(widget.space),
        buildOpenTimeRow(widget.space),
        //const TempPlaceHolerForEventsFeature(),
        const VerticalSpace(10),
        const Divider(
          thickness: 8,
          color: fore5,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.space.introduction,
                style: fontTitle05(),
              ),
              const VerticalSpace(10),
              Text(
                widget.space.locationDescription,
                style: fontBodySm(),
              ),
              const VerticalSpace(30),
              Row(
                children: [
                  Text(
                    LocaleKeys.location.tr(),
                    style: fontCompactSm(),
                  ),
                  const HorizontalSpace(10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      widget.space.address,
                      style: fontCompactSmBold(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 250,
          child: GoogleMap(
            initialCameraPosition: _kGooglePlex,
            markers: Set.from(allMarkers),
            onMapCreated: (GoogleMapController controller) async {
              setState(() {
                _controller = controller;
              });

              final latLong =
                  LatLng(widget.space.latitude, widget.space.longitude);
              await moveAnimateToAddress(latLong);
              await addMarker(latLong);
            },
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: false,
            scrollGesturesEnabled: false,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: false,
            indoorViewEnabled: true,
            onTap: (argument) {
              MapUtils.openMap(widget.space.latitude, widget.space.longitude);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerticalSpace(30),
              SpaceBenefitListWidget(spaceDetailEntity: widget.space),
              const VerticalSpace(30),
            ],
          ),
        ),
      ],
    );
  }

  Padding buildNameTypeRow(SpaceDetailEntity spaceDetailEntity) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            spaceDetailEntity.name,
            style: fontTitle05Bold(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            decoration: BoxDecoration(
              color: fore5,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                DefaultImage(
                  path:
                      "assets/icons/ic_space_category_${spaceDetailEntity.category.toLowerCase()}.svg",
                  width: 16,
                  height: 16,
                ),
                const HorizontalSpace(3),
                Text(
                  getLocalCategoryName(spaceDetailEntity.category),
                  style: fontCompactSm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding buildOpenTimeRow(SpaceDetailEntity spaceDetailEntity) {
    final start = spaceDetailEntity.businessHoursStart;
    final end = spaceDetailEntity.businessHoursEnd;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: (getOpenCloseString(start, end) ==
                      LocaleKeys.businessClosed.tr())
                  ? fore3
                  : hmpBlue,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            getOpenCloseString(start, end),
            style: (getOpenCloseString(start, end) ==
                    LocaleKeys.businessClosed.tr())
                ? fontCompactSm(color: fore3)
                : fontCompactSm(color: hmpBlue),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            width: 2,
            height: 2,
            decoration: const BoxDecoration(
              color: fore4,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            getBusinessHours(spaceDetailEntity.businessHoursStart,
                spaceDetailEntity.businessHoursEnd),
            style: fontCompactSm(color: fore2),
          )
        ],
      ),
    );
  }

  Positioned buildBackArrowIconButton(BuildContext context) {
    return Positioned(
      top: 40,
      left: 28,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 10,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: DefaultImage(
              path: "assets/icons/img_icon_arrow.svg",
              width: 32,
              height: 32,
            ),
          ),
        ),
      ),
    );
  }

  String getBusinessHours(String? start, String? end) {
    // Check for null values
    if (start == null || end == null) {
      return "";
    }

    return "$start ~ $end";
  }

  String getOpenCloseString(String? start, String? end) {
    // Check for null values
    if (start == null || end == null) {
      return LocaleKeys.openingHours.tr();
    }

    try {
      // Extract the hour part from the start and end times
      int startHour = int.parse(start.split(':')[0]);
      int endHour = int.parse(end.split(':')[0]);

      // Get the current hour
      DateTime now = DateTime.now();
      int currentHour = now.hour;

      // Check if current hour is within the business hours
      if (currentHour >= startHour && currentHour < endHour) {
        return LocaleKeys.open.tr();
      } else {
        return LocaleKeys.businessClosed.tr();
      }
    } catch (e) {
      return LocaleKeys.openingHours.tr();
    }
  }
}

class TempPlaceHolerForEventsFeature extends StatelessWidget {
  const TempPlaceHolerForEventsFeature({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.upcomingEvents.tr(),
            style: fontTitle06Medium(),
          ),
          const VerticalSpace(10),
          CustomImageView(
            imagePath: "assets/images/space_placeholder.png",
            width: MediaQuery.of(context).size.width,
            height: 250,
            radius: BorderRadius.circular(2),
            fit: BoxFit.fill,
          )
        ],
      ),
    );
  }
}
