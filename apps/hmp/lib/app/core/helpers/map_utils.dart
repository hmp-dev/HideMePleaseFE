import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  static Future<void> openMapWithNavigation(
      double destLatitude, double destLongitude) async {
    // Get current location
    final position = await Geolocator.getCurrentPosition();
    final startLatitude = position.latitude;
    final startLongitude = position.longitude;

    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$startLatitude,$startLongitude&destination=$destLatitude,$destLongitude&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map for navigation.';
    }
  }

  static void navigateTo(double lat, double lng) async {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }
}
