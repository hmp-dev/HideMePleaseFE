import '../models/character_profile.dart';

/// Predefined character combinations for onboarding
class PredefinedCharacters {
  static final List<CharacterProfile> characters = [
    // Female Character 1 - Cute Pink Style
    CharacterProfile(
      gender: 'female',
      background: 'assets/character/background/basic/pink_red_bg.png',
      body: 'assets/character/body/basic/peach_normal_body.png',
      clothes: 'assets/character/clothes(female)/basic/red_hanbok_clothes(female).png',
      eyes: 'assets/character/eyes(female)/basic/black_longeyelashes_eyes(female).png',
      hair: 'assets/character/hair(female)/basic/black_long_normal_hair(female).png',
      nose: 'assets/character/nose/basic/pink_nose.png',
      earAccessory: 'assets/character/ear_accessory/basic/pinkflower_ear_accessory.png',
    ),

    // Male Character 1 - Cool Blue Style
    CharacterProfile(
      gender: 'male',
      background: 'assets/character/background/basic/skyblue_bg.png',
      body: 'assets/character/body/basic/lightpeach_normal_body.png',
      clothes: 'assets/character/clothes(unisex)/basic/blue_hoodie_clothes(unisex).png',
      eyes: 'assets/character/eyes(unisex)/basic/blackpupils_normal1_eyes(unisex).png',
      hair: 'assets/character/hair(male)/basic/black_normal_hair(male).png',
      nose: 'assets/character/nose/basic/blue_nose.png',
    ),

    // Female Character 2 - Yellow Cheerful Style
    CharacterProfile(
      gender: 'female',
      background: 'assets/character/background/basic/peachpink_bg.png',
      body: 'assets/character/body/basic/darkpeach_normal_body.png',
      clothes: 'assets/character/clothes(unisex)/basic/purple_stripe_hoodie_clothes(unisex).png',
      eyes: 'assets/character/eyes(female)/basic/blue_doubleeyelid_eyes(female).png',
      hair: 'assets/character/hair(female)/basic/purple_twintails_hair(female).png',
      nose: 'assets/character/nose/basic/purple_nose.png',
      earAccessory: 'assets/character/ear_accessory/basic/white_doublerings_ear_accessory.png',
    ),

    // Male Character 2 - Street Style
    CharacterProfile(
      gender: 'male',
      background: 'assets/character/background/basic/orange_yellow_bg.png',
      body: 'assets/character/body/basic/brown_normal_body.png',
      clothes: 'assets/character/clothes(unisex)/basic/red_hoodie_clothes(unisex).png',
      eyes: 'assets/character/eyes(unisex)/basic/black_sunglasses_eyes(unisex).png',
      hair: 'assets/character/hair(unisex)/basic/black_bluebackwardscap_hair(unisex).png',
      nose: 'assets/character/nose/basic/red_nose.png',
      earAccessory: 'assets/character/ear_accessory/basic/small_gold_ball_ear_accessory.png',
    ),

    // Female Character 3 - Casual Style
    CharacterProfile(
      gender: 'female',
      background: 'assets/character/background/basic/lightgreen_orange_bg.png',
      body: 'assets/character/body/basic/lightbrown_freckles_body.png',
      clothes: 'assets/character/clothes(unisex)/basic/blue_overalls_clothes(unisex).png',
      eyes: 'assets/character/eyes(female)/basic/darkbrown_longeyelashes_eyes(female).png',
      hair: 'assets/character/hair(female)/basic/yellow_short_hair(female).png',
      nose: 'assets/character/nose/basic/brightorange_nose.png',
      earAccessory: 'assets/character/ear_accessory/basic/red_ball_ear_accessory.png',
    ),

    // Male Character 3 - Vintage Style
    CharacterProfile(
      gender: 'male',
      background: 'assets/character/background/basic/mustard_bg.png',
      body: 'assets/character/body/basic/chocolate_normal_body.png',
      clothes: 'assets/character/clothes(unisex)/basic/brown_cardigan_clothes(unisex).png',
      eyes: 'assets/character/eyes(unisex)/basic/green_roundeyeglasses_small_eyes(unisex).png',
      hair: 'assets/character/hair(male)/basic/gray_painter_hair(male).png',
      nose: 'assets/character/nose/basic/kiwi_nose.png',
    ),

    // Female Character 4 - Business Style
    CharacterProfile(
      gender: 'female',
      background: 'assets/character/background/basic/lightblue_softpink_bg.png',
      body: 'assets/character/body/basic/white_normal_body.png',
      clothes: 'assets/character/clothes(unisex)/basic/black_suit_clothes(unisex).png',
      eyes: 'assets/character/eyes(female)/basic/green_sharpglasses_eyes(female).png',
      hair: 'assets/character/hair(female)/basic/black_short_hair(female).png',
      nose: 'assets/character/nose/basic/bright_nose.png',
      earAccessory: 'assets/character/ear_accessory/basic/silver_doublerings_ear_accessory.png',
    ),

    // Male Character 4 - Cool Style
    CharacterProfile(
      gender: 'male',
      background: 'assets/character/background/basic/skyblue_purple_bg.png',
      body: 'assets/character/body/basic/lightpeach_normal_body.png',
      clothes: 'assets/character/clothes(unisex)/basic/navy_hoodie_clothes(unisex).png',
      eyes: 'assets/character/eyes(unisex)/basic/movieglasses_eyes(unisex).png',
      hair: 'assets/character/hair(male)/basic/skyblue_parted_hair(male).png',
      nose: 'assets/character/nose/basic/skyblue_nose.png',
      earAccessory: 'assets/character/ear_accessory/basic/white_airpods_ear_accessory.png',
    ),

    // Female Character 5 - Sporty Style
    CharacterProfile(
      gender: 'female',
      background: 'assets/character/background/basic/yellow_green_bg.png',
      body: 'assets/character/body/basic/peach_rosy_body.png',
      clothes: 'assets/character/clothes(unisex)/basic/green_shortsleeve_clothes(unisex).png',
      eyes: 'assets/character/eyes(female)/basic/blackpupils_shorteyelashes_eyes(female).png',
      hair: 'assets/character/hair(female)/basic/brown_hat_hair(female).png',
      nose: 'assets/character/nose/basic/green_nose.png',
      earAccessory: 'assets/character/ear_accessory/basic/lime_ball_ear_accessory.png',
    ),

    // Male Character 5 - Formal Style
    CharacterProfile(
      gender: 'male',
      background: 'assets/character/background/basic/blue_beige_bg.png',
      body: 'assets/character/body/basic/softbrown_normal_body.png',
      clothes: 'assets/character/clothes(unisex)/basic/blue_suit_tie_clothes(unisex).png',
      eyes: 'assets/character/eyes(unisex)/basic/gray_roundeyeglasses1_small_eyes(unisex).png',
      hair: 'assets/character/hair(male)/basic/deepbrown_normal_hair(male).png',
      nose: 'assets/character/nose/basic/blue_nose.png',
      earAccessory: 'assets/character/ear_accessory/basic/small_white_ball_ear_accessory.png',
    ),
  ];
}