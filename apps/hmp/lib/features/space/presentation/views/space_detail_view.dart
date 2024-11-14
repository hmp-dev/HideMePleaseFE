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

/// A widget that displays the details of a space.
///
/// This widget is used to display the details of a [SpaceDetailEntity].
/// It takes a [SpaceDetailEntity] object as a parameter in its constructor
/// and uses it to display the details of the space.
///
/// The [SpaceDetailView] class is a [StatefulWidget] and extends the
/// [StatefulWidget] class. It has a single property, [space], which is of type
/// [SpaceDetailEntity] and is required.
///
/// The [SpaceDetailView] widget is created with the [SpaceDetailView]
/// constructor. It takes a single argument, [key], which is of type [Key] and
/// is optional. It also takes a required argument, [space], which is of type
/// [SpaceDetailEntity].
///
/// The [SpaceDetailView] widget creates a [State] object using the
/// [createState] method. The created state is of type [_SpaceDetailViewState]
/// and is returned.
///
/// The [_SpaceDetailViewState] class is a [State] subclass that extends the
/// [State] class. It has a single property, [allMarkers], which is a list of
/// [Marker] objects. It also has a property, [_controller], which is of type
/// [GoogleMapController].
///
/// The [_SpaceDetailViewState] class overrides the [createState] method to
/// create a new instance of itself.
///
/// The [_SpaceDetailViewState] class overrides the [initState] method to
/// initialize the state of the widget. It initializes the [_controller]
/// property to a new instance of [GoogleMapController].
///
/// The [_SpaceDetailViewState] class overrides the [dispose] method to
/// dispose of the resources used by the widget. It calls the [dispose] method
/// of the [_controller] property.
///
/// The [_SpaceDetailViewState] class defines a number of methods that are used
/// to build the UI of the widget. These methods are used to display the details
/// of the space, such as the name, address, and image.
///
/// The [build] method is overridden to build the UI of the widget. It returns
/// a [Scaffold] widget that contains a [GoogleMap] widget and a number of
/// other widgets that display the details of the space.
class SpaceDetailView extends StatefulWidget {
  /// Creates a [SpaceDetailView] widget.
  ///
  /// The [key] parameter is used to uniquely identify the widget. It is optional.
  /// The [space] parameter is the [SpaceDetailEntity] object that contains the
  /// details of the space to be displayed. It is required.
  const SpaceDetailView({super.key, required this.space});

  /// The [SpaceDetailEntity] object that contains the details of the space.
  final SpaceDetailEntity space;

  /// Creates the mutable state for this widget at a given location in the tree.
  ///
  /// This method is called when inflating a widget and creating its
  /// associated state. It should return a new instance of the state.
  ///
  /// The framework will call this method multiple times, potentially
  /// in parallel, with distinct [BuildContext] arguments. It is the
  /// responsibility of the implementer to ensure that the returned
  /// instances are independent and do not share resources.
  ///
  /// The [State] instance returned by this method will be
  /// initialized with a reference to the [BuildContext] that the widget
  /// is going to be inflated in.
  ///
  /// Once the [State] object is created, the framework retains only a
  /// weak reference to the [State] object. The [State] object is
  /// considered to be inactive when it does not have an associated
  /// build context.
  ///
  /// See also:
  ///
  ///  * [StatefulWidget.createState]
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
            if (widget.space.hidingCount > 0)
              BuildHidingCountWidget(hidingCount: widget.space.hidingCount),
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

  /// Builds a row that displays the name and type of the space.
  ///
  /// The row contains the name of the space in a [Text] widget, and the type of
  /// the space in a [Container] widget with a decoration and a [Row] child.
  /// The type is displayed as an image and a text.
  ///
  /// The padding of the row is 20 on the left, right, and top sides.
  ///
  /// Returns a [Padding] widget that wraps the row.
  Padding buildNameTypeRow(SpaceDetailEntity spaceDetailEntity) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
        // Aligns the children to the start of the row.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Displays the name of the space.
          Text(
            spaceDetailEntity.name,
            style: fontTitle05Bold(),
          ),
          // Displays the type of the space.
          Container(
            // Padding of the container.
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            decoration: BoxDecoration(
              // Color of the background.
              color: fore5,
              // Border radius of the container.
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              // Children of the row.
              children: [
                // Displays an image based on the category of the space.
                (spaceDetailEntity.category.toLowerCase() == "walkerhill")
                    ? DefaultImage(
                        path: "assets/icons/walkerhill.png",
                        width: 16,
                        height: 16,
                      )
                    : DefaultImage(
                        path:
                            "assets/icons/ic_space_category_${spaceDetailEntity.category.toLowerCase()}.svg",
                        width: 16,
                        height: 16,
                      ),
                //Spacing between the image and the text.
                const HorizontalSpace(3),
                // Displays the localized name of the category of the space.
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

  /// Builds a row that displays the opening time of the space.
  ///
  /// The row contains a small circle color-coded based on whether the space is
  /// open or closed, followed by the opening time as a string. The opening time
  /// is obtained by calling the [getOpenCloseString] function.
  ///
  /// Parameters:
  ///   - [spaceDetailEntity]: The [SpaceDetailEntity] object containing the
  ///     details of the space, including the start and end times of business
  ///     hours and whether the space is open or closed.
  ///
  /// Returns a [Padding] widget that wraps a [Row] widget.
  Padding buildOpenTimeRow(SpaceDetailEntity spaceDetailEntity) {
    // Extract the start and end times of business hours from the space detail entity.
    final start = spaceDetailEntity.businessHoursStart;
    final end = spaceDetailEntity.businessHoursEnd;

    // Determine whether the space is open or closed.
    bool isSpaceOpen = spaceDetailEntity.spaceOpen == true;
    Color color = isSpaceOpen ? hmpBlue : fore3;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Small circle color-coded based on whether the space is open or closed.
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          // Text indicating whether the space is open or closed.
          Text(
            getOpenCloseString(start, end),
            style: fontCompactSm(color: color),
          ),
          // Small vertical line.
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            width: 2,
            height: 2,
            decoration: const BoxDecoration(
              color: fore4,
              shape: BoxShape.circle,
            ),
          ),
          // Text indicating the start and end times of business hours.
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
