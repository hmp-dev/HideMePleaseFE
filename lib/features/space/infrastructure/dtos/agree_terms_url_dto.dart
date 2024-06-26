import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AgreeTermsVisitedUrlDto {
  final String userId;
  final String termsUrl;

  AgreeTermsVisitedUrlDto({required this.userId, required this.termsUrl});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'termsUrl': termsUrl,
      };

  factory AgreeTermsVisitedUrlDto.fromJson(Map<String, dynamic> json) {
    return AgreeTermsVisitedUrlDto(
      userId: json['userId'],
      termsUrl: json['termsUrl'],
    );
  }
}

// Save list of objects
Future<void> saveAgreeTermsVisitedUrlDtoList(List<AgreeTermsVisitedUrlDto> objectList) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> jsonStringList =
      objectList.map((obj) => jsonEncode(obj.toJson())).toList();
  await prefs.setStringList('agree_terms_visited_url_list', jsonStringList);
}

// Retrieve list of objects
Future<List<AgreeTermsVisitedUrlDto>> getAgreeTermsVisitedUrlDtoList() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? jsonStringList =
      prefs.getStringList('agree_terms_visited_url_list');
  if (jsonStringList != null) {
    return jsonStringList
        .map((jsonString) =>
            AgreeTermsVisitedUrlDto.fromJson(jsonDecode(jsonString)))
        .toList();
  }
  return []; // Return an empty list if no objects are found
}

// Function to check if the URL is already saved and save if not
Future<bool> isUrlAlreadySaved(String userId, String termsUrl) async {
  List<AgreeTermsVisitedUrlDto> objectList = await getAgreeTermsVisitedUrlDtoList();
  for (var obj in objectList) {
    if (obj.userId == userId && obj.termsUrl == termsUrl) {
      return true;
    }
  }

  // If not found, save the new object
  AgreeTermsVisitedUrlDto newObject =
      AgreeTermsVisitedUrlDto(userId: userId, termsUrl: termsUrl);
  objectList.add(newObject);
  await saveAgreeTermsVisitedUrlDtoList(objectList);
  return false;
}
