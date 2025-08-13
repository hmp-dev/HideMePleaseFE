import 'dart:math' as math;
import '../models/character_profile.dart';
import '../data/character_assets.dart';

/// Utility class for generating random character combinations
class CharacterGenerator {
  static final _random = math.Random();

  /// Generates a random character profile
  static CharacterProfile generateRandomCharacter() {
    // Randomly choose gender (50/50)
    final gender = _random.nextBool() ? 'female' : 'male';
    
    // Random background
    final background = CharacterAssets.backgrounds[_random.nextInt(CharacterAssets.backgrounds.length)];
    
    // Random body
    final body = CharacterAssets.bodies[_random.nextInt(CharacterAssets.bodies.length)];
    
    // Random clothes - combine female/unisex for all genders
    final allClothes = [...CharacterAssets.femaleClothes, ...CharacterAssets.unisexClothes];
    // Ensure we have clothes to select from
    final clothes = allClothes.isNotEmpty 
        ? allClothes[_random.nextInt(allClothes.length)]
        : 'assets/images/onboarding/pfp/clothes/default_clothes.png'; // Fallback default
    
    // Random eyes - combine female/unisex for all genders
    final allEyes = [...CharacterAssets.femaleEyes, ...CharacterAssets.unisexEyes];
    final eyes = allEyes[_random.nextInt(allEyes.length)];
    
    // Random hair - combine all types based on gender
    List<String> availableHair;
    if (gender == 'female') {
      availableHair = [...CharacterAssets.femaleHair, ...CharacterAssets.unisexHair];
    } else {
      availableHair = [...CharacterAssets.maleHair, ...CharacterAssets.unisexHair];
    }
    final hair = availableHair[_random.nextInt(availableHair.length)];
    
    // Random nose
    final nose = CharacterAssets.noses[_random.nextInt(CharacterAssets.noses.length)];
    
    // Random ear accessory (70% chance to have one)
    String? earAccessory;
    if (_random.nextDouble() < 0.7) {
      earAccessory = CharacterAssets.earAccessories[_random.nextInt(CharacterAssets.earAccessories.length)];
    }
    
    return CharacterProfile(
      gender: gender,
      background: background,
      body: body,
      clothes: clothes,
      eyes: eyes,
      hair: hair,
      nose: nose,
      earAccessory: earAccessory,
    );
  }

  /// Generates a list of random characters
  static List<CharacterProfile> generateRandomCharacters(int count) {
    return List.generate(count, (_) => generateRandomCharacter());
  }
}