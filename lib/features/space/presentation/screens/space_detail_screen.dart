import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/helpers/map_utils.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/widgets/build_hiding_count_widget.dart';
import 'package:mobile/features/space/presentation/widgets/space_benefit_list_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SpaceDetailScreen extends StatefulWidget {
  const SpaceDetailScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpaceDetailScreen(),
      ),
    );
  }

  @override
  State<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends State<SpaceDetailScreen> {
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
          zoom: 8.151926040649414,
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
    return Scaffold(
      body: SingleChildScrollView(
        child: BlocConsumer<SpaceCubit, SpaceState>(
          bloc: getIt<SpaceCubit>(),
          listener: (context, state) {
            if (state.submitStatus == RequestStatus.success) {
              // fetch Space related Benefits
              getIt<SpaceCubit>()
                  .onGetSpaceBenefits(spaceId: state.currentSpaceId);
            }
          },
          builder: (context, state) {
            return state.submitStatus == RequestStatus.loading
                ? const Center(child: SizedBox.shrink())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          state.spaceDetailEntity.image == ""
                              ? CustomImageView(
                                  imagePath:
                                      "assets/images/place_holder_card.png",
                                  width: MediaQuery.of(context).size.width,
                                  height: 250,
                                  radius: BorderRadius.circular(2),
                                  fit: BoxFit.cover,
                                )
                              : CustomImageView(
                                  url: state.spaceDetailEntity.image,
                                  width: MediaQuery.of(context).size.width,
                                  height: 250,
                                  radius: BorderRadius.circular(2),
                                  fit: BoxFit.cover,
                                ),
                          buildBackArrowIconButton(context),
                          const BuildHidingCountWidget(hidingCount: 0),
                        ],
                      ),
                      buildNameTypeRow(state),
                      buildOpenTimeRow(state),
                      Padding(
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
                      ),
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
                              state.spaceDetailEntity.introduction,
                              style: fontTitle05(),
                            ),
                            const VerticalSpace(10),
                            Text(
                              state.spaceDetailEntity.locationDescription,
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
                                Text(
                                  state.spaceDetailEntity.address,
                                  style: fontCompactSmBold(),
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

                            final latLong = LatLng(
                                state.spaceDetailEntity.latitude,
                                state.spaceDetailEntity.longitude);
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
                            MapUtils.openMap(state.spaceDetailEntity.latitude,
                                state.spaceDetailEntity.longitude);
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VerticalSpace(30),
                            SpaceBenefitListWidget(),
                            VerticalSpace(50),
                          ],
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Padding buildNameTypeRow(SpaceState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            state.spaceDetailEntity.name,
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
                      "assets/icons/ic_space_category_${state.spaceDetailEntity.category.toLowerCase()}.svg",
                  width: 16,
                  height: 16,
                ),
                const HorizontalSpace(3),
                Text(
                  getLocalCategoryName(state.spaceDetailEntity.category),
                  style: fontCompactSm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding buildOpenTimeRow(SpaceState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 4,
            height: 4,
            decoration:
                const BoxDecoration(color: hmpBlue, shape: BoxShape.circle),
          ),
          Text(
            LocaleKeys.open.tr(),
            style: fontCompactSm(color: hmpBlue),
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
            getBusinessHours(state.spaceDetailEntity.businessHoursStart,
                state.spaceDetailEntity.businessHoursEnd),
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
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.001),
              spreadRadius: 10,
              blurRadius: 8,
              offset: const Offset(-2, 0),
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
      return "Invalid input: start or end time is null";
    }

    try {
      // Parse the input times
      DateTime businessStart = DateFormat('HH:mm:ss').parse(start);
      DateTime businessEnd = DateFormat('HH:mm:ss').parse(end);

      // Format the new times back into strings
      String formattedNewStart = DateFormat('HH:mm').format(businessStart);
      String formattedNewEnd = DateFormat('HH:mm').format(businessEnd);

      // Return the new time range as a string
      return "$formattedNewStart ~ $formattedNewEnd";
    } catch (e) {
      return "$start ~ $end";
    }
  }
}
